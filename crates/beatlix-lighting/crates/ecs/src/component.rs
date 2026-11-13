use std::sync::{OnceLock, atomic::AtomicUsize};

/* ECS Component representing a certain capability of entities */
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub struct EcsComponentId(usize);

impl EcsComponentId {
  #[inline]
  pub(crate) fn index(&self) -> usize {
    self.0
  }
}

static INTERNAL_ECS_COMPONENT_ID_COUNTER: AtomicUsize = AtomicUsize::new(0);
pub trait EcsComponent: Copy + Send + Sync + 'static {
  fn get_id() -> EcsComponentId {
    static ID: OnceLock<EcsComponentId> = OnceLock::new();
    *ID.get_or_init(|| {
      let id = INTERNAL_ECS_COMPONENT_ID_COUNTER.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
      EcsComponentId(id)
    })
  }
}
