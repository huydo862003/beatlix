use std::sync::{OnceLock, atomic::AtomicUsize};

use crate::{EcsComponent, EcsComponentId, EcsStorage, entity::EcsEntityId};

/* Classes of entities that share the same ECS Components */
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct EcsArchetypeId(usize);

impl EcsArchetypeId {
  #[inline]
  pub(crate) fn index(&self) -> usize {
    self.0
  }
}

static INTERNAL_ECS_ARCHETYPE_ID_COUNTER: AtomicUsize = AtomicUsize::new(0);
pub trait EcsArchetype: Send + Sync + 'static {
  fn get_id() -> EcsArchetypeId {
    static ID: OnceLock<EcsArchetypeId> = OnceLock::new();
    *ID.get_or_init(|| {
      let id = INTERNAL_ECS_ARCHETYPE_ID_COUNTER.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
      EcsArchetypeId(id)
    })
  }

  /// Returns the component ids that make up this archetype
  fn component_ids() -> Vec<EcsComponentId>;

  /// Write all component values to storage for the given entity
  fn write_to_storage(self, storage: &mut EcsStorage, entity_id: EcsEntityId);
}

/* A trait indicating that an archetype has a component */
pub trait EcsArchetypeWithComponent<C: EcsComponent>: EcsArchetype {}
