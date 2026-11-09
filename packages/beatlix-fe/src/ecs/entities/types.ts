import type {
  ComponentBag,
} from '../components/types';

export enum EntityCategory {
  Room = 'room',
  Placeable = 'placeable',
  Structure = 'structure',
  Surface = 'surface',
  Atmospheric = 'atmospheric',
  Light = 'light',
}

export interface EntityDefinition {
  id: EntityId;
  category: EntityCategory;
  components: ComponentBag;
}

export type EntityId = string;

export function defineEntity (
  id: EntityId,
  category: EntityCategory,
  ...componentBags: ComponentBag[]
): EntityDefinition {
  const merged: ComponentBag = {};

  for (const bag of componentBags) {
    Object.assign(merged, bag);
  }

  return {
    id,
    category,
    components: merged,
  };
}
