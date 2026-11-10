use crate::{EcsArchetype, EcsArchetypeWithComponent, EcsComponent, EcsEntity, EcsStorage};

/// World contains entities, archetypes, and components
pub trait EcsWorld {
  fn storage(&self) -> &EcsStorage;
  fn storage_mut(&mut self) -> &mut EcsStorage;

  /// Create a new entity with all component values provided upfront
  fn spawn<A: EcsArchetype>(&mut self, archetype: A) -> EcsEntity<A> {
    let id = self.storage_mut().create_entity::<A>();
    archetype.write_to_storage(self.storage_mut(), id);
    EcsEntity::new(id)
  }

  /// Delete an entity
  fn despawn<A: EcsArchetype>(&mut self, entity: EcsEntity<A>) -> bool {
    self.storage_mut().delete_entity(entity.id())
  }

  /// Set a component value on an entity
  fn set<C: EcsComponent, A: EcsArchetypeWithComponent<C>>(
    &mut self,
    entity: EcsEntity<A>,
    value: C,
  ) {
    self
      .storage_mut()
      .set_entity_component_slot(entity.id(), value);
  }

  /// Get a component value from an entity
  fn get<C: EcsComponent, A: EcsArchetypeWithComponent<C>>(
    &self,
    entity: EcsEntity<A>,
  ) -> Option<&C> {
    self.storage().get_entity_component_slot(entity.id())
  }

  /// Get a typed slice of all values for a component in an archetype
  fn component_slice<A: EcsArchetypeWithComponent<C>, C: EcsComponent>(&self) -> Option<&[C]> {
    self.storage().get_component_slice::<A, C>()
  }
}
