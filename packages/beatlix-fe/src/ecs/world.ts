import {
  computed, reactive,
} from 'vue';
import type {
  ComponentMap,
} from './components/types';
import type {
  EntityDefinition, EntityId,
} from './entities/types';
import {
  computeVisibility,
} from './effects/visibility';
import type {
  VisibilityResult,
} from './effects/visibility';

export type World = ReturnType<typeof createWorld>;

export function createWorld () {
  const entities = reactive(new Map<EntityId, EntityDefinition>());
  const stores = createStores();

  function spawn (definition: EntityDefinition) {
    entities.set(definition.id, definition);
    for (const [
      key,
      value,
    ] of Object.entries(definition.components)) {
      const store = stores[key as keyof ComponentMap];

      if (store && value) {
        store.set(definition.id, value as never);
      }
    }
  }

  function despawn (id: EntityId) {
    entities.delete(id);
    for (const store of Object.values(stores)) {
      store.delete(id);
    }
  }

  function getEntitiesWithComponents<K extends keyof ComponentMap> (...keys: K[]) {
    const [
      first,
      ...rest
    ] = keys;
    const ids = [...stores[first].keys()];

    return ids.filter((id) => rest.every((key) => stores[key].has(id)));
  }

  function getComponent<K extends keyof ComponentMap> (id: EntityId, key: K): ComponentMap[K] {
    return stores[key].get(id) as ComponentMap[K];
  }

  const visibility = computed<VisibilityResult>(() => {
    const lightIds = getEntitiesWithComponents('lightEmitter');
    const occluderIds = getEntitiesWithComponents('position', 'lightOccluder');
    const casterIds = getEntitiesWithComponents('position', 'shadowCaster');
    const receiverIds = getEntitiesWithComponents('position', 'shadowReceiver');

    return computeVisibility({
      lights: lightIds.map((id) => ({
        id,
        lightEmitter: getComponent(id, 'lightEmitter'),
      })),
      occluders: occluderIds.map((id) => ({
        id,
        position: getComponent(id, 'position'),
        lightOccluder: getComponent(id, 'lightOccluder'),
      })),
      casters: casterIds.map((id) => ({
        id,
        position: getComponent(id, 'position'),
        shadowCaster: getComponent(id, 'shadowCaster'),
      })),
      receivers: receiverIds.map((id) => ({
        id,
        position: getComponent(id, 'position'),
      })),
    });
  });

  return {
    entities,
    stores,
    spawn,
    despawn,
    getEntitiesWithComponents,
    getComponent,
    visibility,
  };
}

type Store<T> = Map<EntityId, T>;

function createStores (): { [K in keyof ComponentMap]: Store<ComponentMap[K]> } {
  return {
    position: reactive(new Map()),
    shadowCaster: reactive(new Map()),
    shadowReceiver: reactive(new Map()),
    lightEmitter: reactive(new Map()),
    lightOccluder: reactive(new Map()),
  };
}
