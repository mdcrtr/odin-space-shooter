package main

import rl "vendor:raylib"

PLAYER_SPEED :: 60
PLAYER_SHOOT_INTERVAL :: 0.25
PLAYER_INVULNERABILITY_TIME :: 0.5
PLAYER_HEALTH_DECAY_INTERVAL :: 2.0


player_create :: proc() -> Entity {
	return {
		kind = .ENT_PLAYER,
		pos = {GAME_WIDTH / 2 - 8, GAME_HEIGHT - 40},
		vel = {0, 0},
		tex = T_PLAYER,
		health = 100,
		variant = (Player){score = 0, shoot_cooldown = PLAYER_SHOOT_INTERVAL},
	}
}

player_update :: proc(self: ^Entity, dt: f32, entities: ^Entities) {
	pv := &self.variant.(Player)

	if pv.shoot_cooldown > 0 {
		pv.shoot_cooldown -= dt
	}

	if pv.damage_cooldown > 0 {
		pv.damage_cooldown -= dt
	}

	if pv.health_decay_cooldown > 0 {
		pv.health_decay_cooldown -= dt
	} else {
		pv.health_decay_cooldown = PLAYER_HEALTH_DECAY_INTERVAL
		self.health -= 1
	}

	if rl.IsKeyDown(.X) && pv.shoot_cooldown < 0 {
		entities_add(entities, create_player_bullet(self.pos))
		pv.shoot_cooldown = PLAYER_SHOOT_INTERVAL
	}

	self.vel = {0, 0}

	if rl.IsKeyDown(.LEFT) {
		self.vel.x = -PLAYER_SPEED
	}
	if rl.IsKeyDown(.RIGHT) {
		self.vel.x = PLAYER_SPEED
	}
	if rl.IsKeyDown(.UP) {
		self.vel.y = -PLAYER_SPEED
	}
	if rl.IsKeyDown(.DOWN) {
		self.vel.y = PLAYER_SPEED
	}

	dist := self.vel * dt
	self.pos += dist
	self.pos = rl.Vector2Clamp(self.pos, {0, 50}, {GAME_HEIGHT - 16, GAME_WIDTH - 16})
}

player_bullet_update :: proc(self: ^Entity, dt: f32, player: ^Entity, enemies: []^Entity) {
	entity_update(self, dt)

	for &enemy in enemies {
		if is_colliding(self^, enemy^) {
			self.health = 0
			points := enemy.kind == .ENT_ENEMY ? 75 : 115
			pv := &player.variant.(Player)
			pv.score += points
			enemy.health = 0
		}
	}
}

player_add_health :: proc(self: ^Entity, amount: int) {
	self.health = min(self.health + amount, 100)
}

player_hit :: proc(self: ^Entity, damage: int) {
	pv := &self.variant.(Player)
	if pv.damage_cooldown > 0 {
		return
	}
	self.health -= damage
	pv.damage_cooldown = 0.2
}
