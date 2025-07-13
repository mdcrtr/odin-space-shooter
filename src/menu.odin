package main

import rl "vendor:raylib"

MenuCommand :: enum {
	None,
	Start,
	Continue,
}

Menu :: struct {
	can_continue: bool,
	command:      MenuCommand,
}

menu_update :: proc(self: ^Menu) {
	if rl.IsKeyPressed(.Z) {
		self.command = .Start
	}

	if self.can_continue && rl.IsKeyPressed(.C) {
		self.command = .Continue
	}
}

menu_draw :: proc(self: Menu) {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.DrawText("Arrow Keys to move", 100, 80, 40, rl.YELLOW)
	rl.DrawText("X to fire", 206, 140, 40, rl.YELLOW)
	rl.DrawText("Z to start / toggle menu", 70, 200, 40, rl.YELLOW)

	if self.can_continue {
		rl.DrawText("C to continue", 160, 260, 40, rl.YELLOW)
	}

	rl.EndDrawing()
}
