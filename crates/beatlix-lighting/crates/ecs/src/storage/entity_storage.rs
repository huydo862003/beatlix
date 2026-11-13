use crate::{EcsArchetypeId, EcsEntityId};

use super::archetype_storage::EntityComponentSlot;

pub(crate) struct EcsEntityStorage {
  free_head: Option<usize>,
  records: Vec<EntityRecord>,
  /// Reverse index: slot_to_record[archetype_index][slot] = record index
  slot_to_record: Vec<Vec<u32>>,
}

impl EcsEntityStorage {
  pub(crate) fn new() -> Self {
    Self {
      free_head: None,
      records: Vec::new(),
      slot_to_record: Vec::new(),
    }
  }

  /// Notify storage that a new archetype was registered
  pub(crate) fn add_archetype(&mut self) {
    self.slot_to_record.push(Vec::new());
  }

  /// Allocate a new entity in the given archetype at the given slot
  pub(crate) fn create_entity(
    &mut self,
    archetype_id: EcsArchetypeId,
    slot: EntityComponentSlot,
  ) -> EcsEntityId {
    let entity_id = self.allocate_id(archetype_id, slot);
    self.slot_to_record[archetype_id.index()].push(entity_id.index() as u32);
    entity_id
  }

  /// Delete an entity, returns (archetype_id, slot) so caller can remove archetype data
  pub(crate) fn delete_entity(
    &mut self,
    entity_id: EcsEntityId,
  ) -> Option<(EcsArchetypeId, EntityComponentSlot)> {
    let (archetype_id, slot) = self.resolve(entity_id)?;

    let reverse = &mut self.slot_to_record[archetype_id.index()];
    let last_slot = reverse.len() - 1;

    if slot.index() != last_slot {
      let swapped_record_index = reverse[last_slot];
      reverse.swap_remove(slot.index());
      if let EntityRecord::Alive { archetype_slot, .. } =
        &mut self.records[swapped_record_index as usize]
      {
        *archetype_slot = slot;
      }
    } else {
      reverse.pop();
    }

    self.free_id(entity_id);
    Some((archetype_id, slot))
  }

  /// Resolve an entity id to its archetype location
  #[inline]
  pub(crate) fn resolve(
    &self,
    entity_id: EcsEntityId,
  ) -> Option<(EcsArchetypeId, EntityComponentSlot)> {
    let record = self.records.get(entity_id.index())?;
    match record {
      EntityRecord::Free { .. } => None,
      EntityRecord::Alive {
        generation,
        archetype_id,
        archetype_slot,
      } => {
        if *generation as usize != entity_id.generation() {
          return None;
        }
        Some((*archetype_id, *archetype_slot))
      }
    }
  }

  fn allocate_id(
    &mut self,
    archetype_id: EcsArchetypeId,
    slot: EntityComponentSlot,
  ) -> EcsEntityId {
    match self.free_head {
      Some(reused_index) => {
        let record = &self.records[reused_index];
        let (generation, next_free) = match record {
          EntityRecord::Free {
            generation,
            next_free,
          } => (*generation, *next_free),
          _ => unreachable!("free list pointed to alive slot at index {reused_index}"),
        };
        self.free_head = next_free;
        let new_generation = generation + 1;
        self.records[reused_index] = EntityRecord::Alive {
          generation: new_generation,
          archetype_id,
          archetype_slot: slot,
        };
        EcsEntityId::new(new_generation, reused_index as u32)
      }
      None => {
        let index = self.records.len();
        self.records.push(EntityRecord::Alive {
          generation: 0,
          archetype_id,
          archetype_slot: slot,
        });
        EcsEntityId::new(0, index as u32)
      }
    }
  }

  fn free_id(&mut self, entity_id: EcsEntityId) {
    let index = entity_id.index();
    let record = &self.records[index];
    match record {
      EntityRecord::Alive { generation, .. } => {
        self.records[index] = EntityRecord::Free {
          generation: *generation,
          next_free: self.free_head,
        };
        self.free_head = Some(index);
      }
      EntityRecord::Free { .. } => unreachable!("double free on entity"),
    }
  }
}

#[derive(Debug)]
enum EntityRecord {
  Alive {
    generation: u32,
    archetype_id: EcsArchetypeId,
    archetype_slot: EntityComponentSlot,
  },
  Free {
    generation: u32,
    next_free: Option<usize>,
  },
}
