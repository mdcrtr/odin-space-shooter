package main

import rl "vendor:raylib"

ENEMY_SHOOT_INTERVAL :: 1.0

T_PLAYER :: rl.Rectangle{0, 0, 16, 16}
T_ENEMY_0 :: rl.Rectangle{16, 0, 16, 16}
T_ENEMY_1 :: rl.Rectangle{32, 0, 16, 16}
T_ROCK :: rl.Rectangle{48, 0, 16, 16}
T_BULLET_0 :: rl.Rectangle{0, 16, 16, 16}
T_BULLET_1 :: rl.Rectangle{16, 16, 16, 16}
T_PICKUP :: rl.Rectangle{32, 16, 16, 16}
T_STAR_0 :: rl.Rectangle{48, 16, 1, 1}
T_STAR_1 :: rl.Rectangle{48, 18, 1, 1}
T_STAR_2 :: rl.Rectangle{48, 20, 3, 3}
T_STAR_3 :: rl.Rectangle{50, 16, 3, 3}
T_PARTICLE_0 :: rl.Rectangle{56, 16, 2, 2}
T_PARTICLE_1 :: rl.Rectangle{7, 22, 2, 2}

EntityKind :: enum {
	ENT_NONE,
	ENT_PLAYER,
	ENT_PICKUP,
	ENT_ENEMY,
	ENT_ENEMY_SHOOTER,
	ENT_ROCK,
	ENT_PLAYER_BULLET,
	ENT_ENEMY_BULLET,
}

Player :: struct {
	shoot_cooldown:        f32,
	damage_cooldown:       f32,
	health_decay_cooldown: f32,
	score:                 int,
}

EnemyShooter :: struct {
	shoot_cooldown: f32,
}

Entity :: struct {
	kind:    EntityKind,
	pos:     rl.Vector2,
	vel:     rl.Vector2,
	tex:     rl.Rectangle,
	health:  int,
	variant: union {
		EnemyShooter,
		Player,
	},
}

rand_x :: proc() -> f32 {
	return cast(f32)rl.GetRandomValue(0, GAME_WIDTH - 16)
}

is_colliding :: proc(e1: Entity, e2: Entity) -> bool {
	r1: rl.Rectangle = {e1.pos.x + 4, e1.pos.y + 4, e1.tex.width - 8, e1.tex.height - 8}
	r2: rl.Rectangle = {e2.pos.x + 4, e2.pos.y + 4, e2.tex.width - 8, e2.tex.height - 8}
	collision_rect := rl.GetCollisionRec(r1, r2)
	return collision_rect.width > 0 || collision_rect.height > 0
}

create_falling_entity :: proc(kind: EntityKind, tex: rl.Rectangle) -> Entity {
	return {kind = kind, pos = {rand_x(), 0}, vel = {0, 60}, tex = tex, health = 40}
}

create_rock :: proc() -> Entity {return create_falling_entity(.ENT_ROCK, T_ROCK)}

create_enemy :: proc() -> Entity {return create_falling_entity(.ENT_ENEMY, T_ENEMY_0)}

create_pickup :: proc() -> Entity {return create_falling_entity(.ENT_PICKUP, T_PICKUP)}

create_enemy_shooter :: proc() -> Entity {
	return {
		kind = .ENT_ENEMY_SHOOTER,
		pos = {rand_x(), 0},
		vel = {0, 60},
		tex = T_ENEMY_1,
		health = 40,
		variant = EnemyShooter{shoot_cooldown = 0.1},
	}
}

create_enemy_bullet :: proc(pos: rl.Vector2) -> Entity {
	return {kind = .ENT_ENEMY_BULLET, pos = pos, vel = {0, 120}, tex = T_BULLET_1, health = 20}
}

create_player_bullet :: proc(pos: rl.Vector2) -> Entity {
	return {kind = .ENT_PLAYER_BULLET, pos = pos, vel = {0, -120}, tex = T_BULLET_0, health = 20}
}

entity_update :: proc(self: ^Entity, dt: f32) {
	dist := self.vel * dt
	self.pos += dist
	if self.pos.y > GAME_HEIGHT || self.pos.y < 0 {
		self.health = 0
	}
}

enemy_update :: proc(self: ^Entity, dt: f32, player: ^Entity) {
	entity_update(self, dt)

	if is_colliding(self^, player^) {
		player_hit(player, 30)
		self.health = 0
	}
}

enemy_shooter_update :: proc(self: ^Entity, dt: f32, player: ^Entity, entities: ^Entities) {
	entity_update(self, dt)
	v := &self.variant.(EnemyShooter)

	if v.shoot_cooldown > 0 {
		v.shoot_cooldown -= dt
	}

	if v.shoot_cooldown < 0 {
		entities_add(entities, create_enemy_bullet(self.pos))
		v.shoot_cooldown = ENEMY_SHOOT_INTERVAL
	}

	if is_colliding(self^, player^) {
		player_hit(player, 30)
		self.health = 0
	}
}

rock_update :: proc(self: ^Entity, dt: f32, player: ^Entity) {
	entity_update(self, dt)

	if is_colliding(self^, player^) {
		player_hit(player, 40)
		self.health = 0
	}
}

pickup_update :: proc(self: ^Entity, dt: f32, player: ^Entity) {
	entity_update(self, dt)

	if is_colliding(self^, player^) {
		player_add_health(player, 50)
		self.health = 0
	}
}

enemy_bullet_update :: proc(self: ^Entity, dt: f32, player: ^Entity) {
	entity_update(self, dt)
	if is_colliding(self^, player^) {
		player_hit(player, 15)
		self.health = 0
	}
}

entity_draw :: proc(self: ^Entity, spritesheet: rl.Texture2D) {
	rl.DrawTextureRec(spritesheet, self.tex, self.pos, rl.WHITE)
}
