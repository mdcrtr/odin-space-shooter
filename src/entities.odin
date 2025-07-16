package main

import rl "vendor:raylib"

Entities :: struct {
	entities: [dynamic]Entity,
}

entities_free :: proc(self: ^Entities) {
	delete(self.entities)
}

entities_add :: proc(self: ^Entities, e: Entity) {
	append(&self.entities, e)
}

entities_remove :: proc(self: ^Entities, index: int) {
	unordered_remove(&self.entities, index)
}

entities_remove_dead :: proc(self: ^Entities) {
	for i := len(self.entities) - 1; i >= 0; i -= 1 {
		if self.entities[i].health <= 0 {
			entities_remove(self, i)
		}
	}
}

entities_get_enemies :: proc(self: ^Entities) -> []^Entity {
	enemies: [dynamic]^Entity
	for &entity in self.entities {
		if entity.kind == .ENT_ENEMY || entity.kind == .ENT_ENEMY_SHOOTER {
			append(&enemies, &entity)
		}
	}
	return enemies[:]
}

entities_update :: proc(self: ^Entities, dt: f32, player: ^Entity) {
	enemies := entities_get_enemies(self)
	defer delete(enemies)

	for &e in self.entities {
		#partial switch (e.kind) {
		case .ENT_ENEMY:
			enemy_update(&e, dt, player)
		case .ENT_ENEMY_SHOOTER:
			enemy_shooter_update(&e, dt, player, self)
		case .ENT_ROCK:
			rock_update(&e, dt, player)
		case .ENT_PICKUP:
			pickup_update(&e, dt, player)
		case .ENT_PLAYER_BULLET:
			player_bullet_update(&e, dt, player, enemies[:])
		case .ENT_ENEMY_BULLET:
			enemy_bullet_update(&e, dt, player)
		case:
		}
	}
}

entities_draw :: proc(self: ^Entities, spritesheet: rl.Texture2D) {
	for &e in self.entities {
		entity_draw(&e, spritesheet)
	}
}
