use std::marker::PhantomData;

use crate::EcsArchetype;

/// Internal generational entity handle
#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq, Default)]
pub struct EcsEntityId {
  generation: u32,
  index: u32,
}

impl EcsEntityId {
  #[inline]
  pub(crate) fn new(generation: u32, index: u32) -> Self {
    Self { generation, index }
  }

  #[inline]
  pub(crate) fn generation(&self) -> usize {
    self.generation as usize
  }

  #[inline]
  pub(crate) fn index(&self) -> usize {
    self.index as usize
  }
}

/// Typed entity handle that carries its archetype at compile time
#[derive(Debug, Hash, PartialEq, Eq, Clone, Copy)]
pub struct EcsEntity<A: EcsArchetype> {
  id: EcsEntityId,
  _archetype: PhantomData<A>,
}

impl<A: EcsArchetype> EcsEntity<A> {
  #[inline]
  pub(crate) fn new(id: EcsEntityId) -> Self {
    Self {
      id,
      _archetype: PhantomData,
    }
  }

  #[inline]
  pub(crate) fn id(&self) -> EcsEntityId {
    self.id
  }
}
