mod archetype_storage;
mod component_storage;
mod entity_storage;

pub(crate) use archetype_storage::EcsArchetypeStorage;
pub(crate) use component_storage::EcsComponentStorage;
pub(crate) use entity_storage::EcsEntityStorage;

use std::alloc::Layout;

use crate::{
  ArchetypeInventoryEntry, ComponentInventoryEntry, EcsArchetype, EcsComponent, EcsEntityId,
};

pub struct EcsStorage {
  components: EcsComponentStorage,
  archetypes: EcsArchetypeStorage,
  entities: EcsEntityStorage,
}

impl EcsStorage {
  pub fn new() -> Self {
    let mut storage = Self {
      components: EcsComponentStorage::new(),
      archetypes: EcsArchetypeStorage::new(),
      entities: EcsEntityStorage::new(),
    };

    for entry in inventory::iter::<ComponentInventoryEntry> {
      (entry.register)(&mut storage);
    }

    for entry in inventory::iter::<ArchetypeInventoryEntry> {
      (entry.register)(&mut storage);
    }

    storage
  }

  pub fn register_component<T: EcsComponent>(&mut self) {
    self.components.register(T::get_id(), Layout::new::<T>());
  }

  pub fn register_archetype<A: EcsArchetype>(&mut self) {
    let component_ids = A::component_ids();
    self
      .archetypes
      .register(A::get_id(), &component_ids, &self.components);
    self.entities.add_archetype();
  }

  #[inline]
  pub(crate) fn create_entity<A: EcsArchetype>(&mut self) -> EcsEntityId {
    let archetype_id = A::get_id();
    let slot = self.archetypes.allocate_slot(archetype_id);
    self.entities.create_entity(archetype_id, slot)
  }

  #[inline]
  pub(crate) fn delete_entity(&mut self, entity_id: EcsEntityId) -> bool {
    let Some((archetype_id, slot)) = self.entities.delete_entity(entity_id) else {
      return false;
    };
    self.archetypes.remove_slot(archetype_id, slot);
    true
  }

  #[doc(hidden)]
  #[inline]
  pub fn set_entity_component_slot<T: EcsComponent>(&mut self, entity_id: EcsEntityId, value: T) {
    let (archetype_id, slot) = self.entities.resolve(entity_id).expect("entity not found");
    self
      .archetypes
      .set_entity_component(archetype_id, slot, T::get_id(), value);
  }

  #[inline]
  pub(crate) fn get_entity_component_slot<T: EcsComponent>(
    &self,
    entity_id: EcsEntityId,
  ) -> Option<&T> {
    let (archetype_id, slot) = self.entities.resolve(entity_id)?;
    Some(
      self
        .archetypes
        .get_entity_component_slot(archetype_id, slot, T::get_id()),
    )
  }

  #[inline]
  pub(crate) fn get_component_slice<A: EcsArchetype, T: EcsComponent>(&self) -> Option<&[T]> {
    self
      .archetypes
      .get_component_slot_slice(A::get_id(), T::get_id())
  }
}

impl Default for EcsStorage {
  fn default() -> Self {
    Self::new()
  }
}
