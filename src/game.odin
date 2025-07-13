package main

import rl "vendor:raylib"

GAME_WIDTH :: 128
GAME_HEIGHT :: 128
DIFFICULTY_INTERVAL :: 2.0

GameCommand :: enum {
	None,
	Menu,
}

Game :: struct {
	command:             GameCommand,
	entities:            Entities,
	player:              Entity,
	sprite_sheet:        rl.Texture2D,
	camera:              rl.Camera2D,
	spawners:            [4]Spawner,
	difficulty_cooldown: f32,
	inited:              bool,
}

calculate_zoom :: proc() -> f32 {
	screen_size := min(rl.GetScreenWidth(), rl.GetScreenHeight())
	return f32(screen_size / GAME_WIDTH)
}

game_create :: proc(tex: rl.Texture2D) -> Game {
	return Game {
		entities = {},
		player = player_create(),
		sprite_sheet = tex,
		camera = rl.Camera2D{zoom = calculate_zoom()},
		spawners = {
			spawner_create(2.0, 1.8, -0.01, create_enemy),
			spawner_create(4.0, 3.0, -0.02, create_enemy_shooter),
			spawner_create(0.8, 1.1, -0.02, create_rock),
			spawner_create(3.0, 4.0, 0.02, create_pickup),
		},
		inited = true,
	}
}

game_free :: proc(self: ^Game) {
	if self.inited {
		entities_free(&self.entities)
		self.inited = false
	}
}

game_update :: proc(self: ^Game) {
	if rl.IsKeyPressed(.Z) {
		self.command = .Menu
	}

	dt := rl.GetFrameTime()
	entities := &self.entities
	player := &self.player

	entities_update(entities, dt, player)
	player_update(player, dt, entities)
	entities_remove_dead(entities)

	for i := 0; i < 4; i += 1 {
		spawner_update(&self.spawners[i], dt, entities)
	}

	if self.difficulty_cooldown > 0 {
		self.difficulty_cooldown -= dt
	} else {
		game_change_difficulty(self)
	}
}

game_draw :: proc(self: ^Game) {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode2D(self.camera)
	entities_draw(&self.entities, self.sprite_sheet)
	entity_draw(&self.player, self.sprite_sheet)
	rl.EndMode2D()

	score_str := rl.TextFormat("score: %d", self.player.variant.(Player).score)
	rl.DrawText(score_str, 4, 4, 40, rl.YELLOW)
	health_str := rl.TextFormat("energy: %d", self.player.health)
	rl.DrawText(health_str, 400, 4, 40, rl.YELLOW)

	rl.EndDrawing()
}

game_change_difficulty :: proc(self: ^Game) {
	self.difficulty_cooldown = DIFFICULTY_INTERVAL
	for &spawner in self.spawners {
		spawner_change_interval(&spawner)
	}
}
