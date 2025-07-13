package main

SpawnFunc :: proc() -> Entity

Spawner :: struct {
	cooldown:         f32,
	interval:         f32,
	initial_interval: f32,
	interval_step:    f32,
	spawn_func:       SpawnFunc,
}

spawner_create :: proc(
	delay: f32,
	interval: f32,
	interval_step: f32,
	spawn_func: SpawnFunc,
) -> Spawner {
	return {
		cooldown = delay,
		interval = interval,
		initial_interval = interval,
		interval_step = interval_step,
		spawn_func = spawn_func,
	}
}

spawner_update :: proc(self: ^Spawner, dt: f32, entities: ^Entities) {
	self.cooldown -= dt
	if self.cooldown > 0 {
		return
	}

	self.cooldown = self.interval
	entities_add(entities, self.spawn_func())

}

spawner_change_interval :: proc(self: ^Spawner) {
	self.interval = clamp(
		self.interval + self.interval_step,
		self.initial_interval * 0.25,
		self.initial_interval * 2,
	)
}
