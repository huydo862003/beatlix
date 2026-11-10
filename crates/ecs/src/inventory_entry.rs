use crate::EcsStorage;

pub struct ComponentInventoryEntry {
  pub register: fn(storage: &mut EcsStorage) -> (),
}

inventory::collect!(ComponentInventoryEntry);

pub struct ArchetypeInventoryEntry {
  pub register: fn(storage: &mut EcsStorage) -> (),
}

inventory::collect!(ArchetypeInventoryEntry);
