use std::alloc::{self, Layout};
use std::ptr;

use crate::{EcsArchetypeId, EcsComponent, EcsComponentId};

use super::EcsComponentStorage;

/// Newtype for a slot position within an archetype
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) struct EntityComponentSlot(usize);

impl EntityComponentSlot {
  #[inline]
  pub(crate) fn index(&self) -> usize {
    self.0
  }
}

/// Dense storage for all archetypes
pub(crate) struct EcsArchetypeStorage {
  archetypes: Vec<ArchetypeData>,
}

impl EcsArchetypeStorage {
  pub(crate) fn new() -> Self {
    Self {
      archetypes: Vec::new(),
    }
  }

  pub(crate) fn register(
    &mut self,
    archetype_id: EcsArchetypeId,
    component_ids: &[EcsComponentId],
    component_storage: &EcsComponentStorage,
  ) {
    let index = archetype_id.index();
    if index >= self.archetypes.len() {
      self.archetypes.resize_with(index + 1, ArchetypeData::empty);
    }
    self.archetypes[index] = ArchetypeData::new(component_ids, component_storage);
  }

  /// Allocate a zero-initialized slot, returns the slot position
  pub(crate) fn allocate_slot(&mut self, archetype_id: EcsArchetypeId) -> EntityComponentSlot {
    self.archetypes[archetype_id.index()].allocate_slot()
  }

  /// Swap-remove a slot, returns whether the last slot was moved
  pub(crate) fn remove_slot(
    &mut self,
    archetype_id: EcsArchetypeId,
    slot: EntityComponentSlot,
  ) -> bool {
    self.archetypes[archetype_id.index()].remove_slot(slot)
  }

  /// Set a component value at a specific slot
  #[inline]
  pub(crate) fn set_entity_component<T: EcsComponent>(
    &mut self,
    archetype_id: EcsArchetypeId,
    slot: EntityComponentSlot,
    component_id: EcsComponentId,
    value: T,
  ) {
    self.archetypes[archetype_id.index()].set_entity_component_slot(slot, component_id, value);
  }

  /// Read a component value at a specific slot
  #[inline]
  pub(crate) fn get_entity_component_slot<T: EcsComponent>(
    &self,
    archetype_id: EcsArchetypeId,
    slot: EntityComponentSlot,
    component_id: EcsComponentId,
  ) -> &T {
    self.archetypes[archetype_id.index()].get_entity_component_slot(slot, component_id)
  }

  /// Get a typed slice of all values for a component in an archetype
  #[inline]
  pub(crate) fn get_component_slot_slice<T: EcsComponent>(
    &self,
    archetype_id: EcsArchetypeId,
    component_id: EcsComponentId,
  ) -> Option<&[T]> {
    self.archetypes[archetype_id.index()].get_component_slot_slice(component_id)
  }
}

/// Dense storage for a single archetype
struct ArchetypeData {
  /// Sparse map from EcsComponentId to index in component_data
  component_to_component_data_index: Vec<Option<usize>>,
  component_data: Vec<BlobVec>,
  slot_count: usize,
}

impl ArchetypeData {
  fn empty() -> Self {
    Self {
      component_to_component_data_index: Vec::new(),
      component_data: Vec::new(),
      slot_count: 0,
    }
  }

  fn new(component_ids: &[EcsComponentId], component_storage: &EcsComponentStorage) -> Self {
    let mut sorted_ids: Vec<_> = component_ids.to_vec();
    sorted_ids.sort_by_key(|id| id.index());

    let component_data: Vec<_> = sorted_ids
      .iter()
      .map(|id| BlobVec::new(component_storage.get_layout(*id)))
      .collect();

    let max = sorted_ids.iter().map(|id| id.index()).max().unwrap_or(0);
    let mut component_to_component_data_index = vec![None; max + 1];
    for (position, id) in sorted_ids.iter().enumerate() {
      component_to_component_data_index[id.index()] = Some(position);
    }

    Self {
      component_to_component_data_index,
      component_data,
      slot_count: 0,
    }
  }

  #[inline]
  fn lookup_component(&self, component_id: EcsComponentId) -> Option<usize> {
    self
      .component_to_component_data_index
      .get(component_id.index())
      .copied()
      .flatten()
  }

  fn allocate_slot(&mut self) -> EntityComponentSlot {
    let slot = EntityComponentSlot(self.slot_count);
    for data in &mut self.component_data {
      data.push_zeroed();
    }
    self.slot_count += 1;
    slot
  }

  fn remove_slot(&mut self, slot: EntityComponentSlot) -> bool {
    assert!(slot.index() < self.slot_count, "slot index out of bounds");
    let mut swapped = false;
    for data in &mut self.component_data {
      swapped = data.swap_remove(slot.index());
    }
    self.slot_count -= 1;
    swapped
  }

  #[inline]
  fn set_entity_component_slot<T: EcsComponent>(
    &mut self,
    slot: EntityComponentSlot,
    component_id: EcsComponentId,
    value: T,
  ) {
    let index = self
      .lookup_component(component_id)
      .expect("component not in archetype");
    // SAFETY: caller guarantees T matches the component type
    let ptr = unsafe { &mut *(self.component_data[index].get_raw_mut(slot.index()) as *mut T) };
    *ptr = value;
  }

  #[inline]
  fn get_entity_component_slot<T: EcsComponent>(
    &self,
    slot: EntityComponentSlot,
    component_id: EcsComponentId,
  ) -> &T {
    let index = self
      .lookup_component(component_id)
      .expect("component not in archetype");
    // SAFETY: caller guarantees T matches the component type
    unsafe { &*(self.component_data[index].get_raw(slot.index()) as *const T) }
  }

  #[inline]
  fn get_component_slot_slice<T: EcsComponent>(
    &self,
    component_id: EcsComponentId,
  ) -> Option<&[T]> {
    let index = self.lookup_component(component_id)?;
    // SAFETY: caller guarantees T matches the component type
    Some(unsafe { self.component_data[index].as_slice::<T>() })
  }
}

/// Aligned, type-erased, growable flat array for Copy types
struct BlobVec {
  item_layout: Layout,
  data: ptr::NonNull<u8>,
  capacity: usize,
  len: usize,
}

impl BlobVec {
  fn new(item_layout: Layout) -> Self {
    Self {
      item_layout,
      data: ptr::NonNull::dangling(),
      capacity: 0,
      len: 0,
    }
  }

  fn push_zeroed(&mut self) {
    if self.len == self.capacity {
      self.grow();
    }
    let destination = self.get_ptr(self.len);
    // SAFETY: destination is within allocated capacity
    unsafe {
      ptr::write_bytes(destination, 0, self.item_layout.size());
    }
    self.len += 1;
  }

  fn swap_remove(&mut self, index: usize) -> bool {
    assert!(
      index < self.len,
      "index {index} out of bounds (len {})",
      self.len
    );
    let swapped = index != self.len - 1;
    if swapped {
      // SAFETY: both indices are within bounds, non-overlapping
      unsafe {
        ptr::copy_nonoverlapping(
          self.get_ptr(self.len - 1),
          self.get_ptr(index),
          self.item_layout.size(),
        );
      }
    }
    self.len -= 1;
    swapped
  }

  #[inline]
  fn get_raw(&self, index: usize) -> *const u8 {
    assert!(
      index < self.len,
      "index {index} out of bounds (len {})",
      self.len
    );
    self.get_ptr(index)
  }

  #[inline]
  fn get_raw_mut(&mut self, index: usize) -> *mut u8 {
    assert!(
      index < self.len,
      "index {index} out of bounds (len {})",
      self.len
    );
    self.get_ptr(index)
  }

  /// # Safety
  /// Caller must ensure T matches the element type
  unsafe fn as_slice<T>(&self) -> &[T] {
    if self.len == 0 {
      return &[];
    }
    unsafe { std::slice::from_raw_parts(self.data.as_ptr() as *const T, self.len) }
  }

  fn padded_item_size(&self) -> usize {
    self
      .item_layout
      .size()
      .next_multiple_of(self.item_layout.align())
  }

  fn array_layout(&self, capacity: usize) -> Layout {
    Layout::from_size_align(self.padded_item_size() * capacity, self.item_layout.align())
      .expect("invalid layout")
  }

  fn grow(&mut self) {
    let new_capacity = if self.capacity == 0 {
      4
    } else {
      self.capacity * 2
    };
    let new_layout = self.array_layout(new_capacity);
    let new_data = if new_layout.size() == 0 {
      ptr::NonNull::dangling()
    } else if self.capacity == 0 {
      // SAFETY: new_layout has non-zero size
      let raw = unsafe { alloc::alloc(new_layout) };
      ptr::NonNull::new(raw).expect("allocation failed")
    } else {
      let old_layout = self.array_layout(self.capacity);
      // SAFETY: data was allocated with old_layout, new size is non-zero
      let raw = unsafe { alloc::realloc(self.data.as_ptr(), old_layout, new_layout.size()) };
      ptr::NonNull::new(raw).expect("reallocation failed")
    };
    self.data = new_data;
    self.capacity = new_capacity;
  }

  #[inline]
  fn get_ptr(&self, index: usize) -> *mut u8 {
    // SAFETY: pointer arithmetic within allocated region (caller checks bounds)
    unsafe { self.data.as_ptr().add(index * self.padded_item_size()) }
  }
}

impl Drop for BlobVec {
  fn drop(&mut self) {
    if self.capacity > 0 {
      let layout = self.array_layout(self.capacity);
      if layout.size() > 0 {
        // SAFETY: data was allocated with this layout
        unsafe { alloc::dealloc(self.data.as_ptr(), layout) };
      }
    }
  }
}
