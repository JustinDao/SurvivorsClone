extends Node2D

@export var spawns: Array[SpawnInfo] = []

@onready var player = get_tree().get_first_node_in_group("player")

var time = 0

func _on_timer_timeout() -> void:
  time += 1
  var enemy_spawns = spawns
  for spawn in enemy_spawns:
    if time >= spawn.time_start and time <= spawn.time_end:
      if spawn.spawn_delay_counter < spawn.enemy_spawn_delay:
        spawn.spawn_delay_counter += 1
      else:
        spawn.spawn_delay_counter = 0
        var enemy: Resource = load(spawn.enemy.resource_path)
        for count in range(spawn.enemy_num):
          var new_enemy = enemy.instantiate()
          new_enemy.global_position = get_random_position()
          add_child(new_enemy)


func get_random_position() -> Vector2:
  var vpr = get_viewport_rect().size * randf_range(1.1, 1.4)
  var top_left = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y - vpr.y / 2)
  var top_right = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y - vpr.y / 2)
  var bottom_left = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y + vpr.y / 2)
  var bottom_right = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y + vpr.y / 2)
  var pos_side = ["up", "down", "right", "left"].pick_random()
  var spawn_pos1 = Vector2.ZERO
  var spawn_pos2 = Vector2.ZERO

  match pos_side:
    "up":
      spawn_pos1 = top_left
      spawn_pos2 = top_right
    "down":
      spawn_pos1 = bottom_left
      spawn_pos2 = bottom_right
    "right":
      spawn_pos1 = top_right
      spawn_pos2 = bottom_right
    "left":
      spawn_pos1 = top_left
      spawn_pos2 = bottom_left
  
  var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
  var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)

  return Vector2(x_spawn, y_spawn)