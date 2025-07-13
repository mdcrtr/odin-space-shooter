package main

import rl "vendor:raylib"

SceneState :: enum {
	Menu,
	Game,
	NewGame,
	ContinueGame,
}

process_menu :: proc(menu: ^Menu, scene_state: ^SceneState) {
	menu_update(menu)
	menu_draw(menu^)

	#partial switch menu.command {
	case .Continue:
		scene_state^ = .ContinueGame
	case .Start:
		scene_state^ = .NewGame
	}

	menu.command = .None
}

process_game :: proc(game: ^Game, scene_state: ^SceneState) {
	game_update(game)
	game_draw(game)

	if game.command == .Menu {
		scene_state^ = .Menu
	}

	game.command = .None
}

main :: proc() {
	screen_width := GAME_WIDTH * 5
	screen_height := GAME_HEIGHT * 5
	rl.InitWindow(i32(screen_width), i32(screen_height), "Space Shooter")
	rl.SetTargetFPS(60)

	tex := rl.LoadTexture("assets/spritesheet.png")

	scene_state := SceneState.Menu
	game: Game
	menu: Menu

	for !rl.WindowShouldClose() {
		switch scene_state {
		case .Menu:
			process_menu(&menu, &scene_state)
		case .Game:
			process_game(&game, &scene_state)
		case .ContinueGame:
			scene_state = .Game
		case .NewGame:
			game_free(&game)
			game = game_create(tex)
			menu.can_continue = true
			scene_state = .Game
		}
	}

	game_free(&game)

	rl.UnloadTexture(tex)
	rl.CloseWindow()
}
