use std::alloc::Layout;

use crate::EcsComponentId;

/// Component metadata, indexed by EcsComponentId
pub(crate) struct EcsComponentStorage {
  layouts: Vec<Layout>,
}

impl EcsComponentStorage {
  pub(crate) fn new() -> Self {
    Self {
      layouts: Vec::new(),
    }
  }

  pub(crate) fn register(&mut self, component_id: EcsComponentId, layout: Layout) {
    let index = component_id.index();
    if index >= self.layouts.len() {
      self.layouts.resize(index + 1, Layout::new::<()>());
    }
    self.layouts[index] = layout;
  }

  #[inline]
  pub(crate) fn get_layout(&self, component_id: EcsComponentId) -> Layout {
    self.layouts[component_id.index()]
  }
}
