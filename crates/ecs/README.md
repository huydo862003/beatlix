# Intended Usage

```rust
#[ecs::component]
struct Position { x: f32, y: f32 }

#[ecs::component]
struct Velocity { x: f32, y: f32 }

#[ecs::component]
struct LightOccluder { vertices: VertexSlice }

#[ecs::component]
struct LightReceiver { vertices: VertexSlice }

#[ecs::archetype]
struct Particle {
  position: Position,
  velocity: Velocity,
}

#[ecs::archetype]
struct LightBlocker {
  occluder: LightOccluder,
  receiver: LightReceiver,
}

#[ecs::world]
struct GameWorld {
  storage: EcsStorage,
  vertex_pool: VertexPool,
}

fn main() {
  let mut world = GameWorld::new(VertexPool::new());

  // spawn returns Entity<Particle>, type-safe handle (Copy)
  let entity = world.spawn(Particle {
    position: Position { x: 0.0, y: 0.0 },
    velocity: Velocity { x: 1.0, y: 1.0 },
  });

  // Compile-time checked: Position is in Particle
  let position = world.get::<Position>(entity);
  world.set(entity, Position { x: 5.0, y: 5.0 });

  // COMPILE ERROR: LightOccluder is not in Particle
  // world.get::<LightOccluder>(entity);

  // Iterate all position components in the Particle archetype
  for position in world.component_slice::<Particle, Position>() {
    // ...
  }

  world.despawn(entity);

  // Custom state accessible directly
  world.vertex_pool.clear();
}
```
