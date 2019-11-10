extends KinematicBody2D

const maxForwardThrust = 250
var forwardThrust = 0
var velocity = Vector2.ZERO

func _ready():
	rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("position", MultiplayerAPI.RPC_MODE_PUPPET)
	
	rset_config("forwardThrust", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("visible", MultiplayerAPI.RPC_MODE_PUPPET)
	
	if(is_network_master()):
		set_process_input(true)
	else:
		set_process_input(false)

func _input(event):
	if(event.is_action_pressed("ui_accept")):
		if(self.visible):
			rpc("shoot")
		else:
			rpc("respawn")

func _physics_process(delta):
	var rotationDirection = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var forwardDirection = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	
	forwardThrust = maxForwardThrust * delta * forwardDirection
	velocity += Vector2(cos(rotation - PI / 2), sin(rotation - PI / 2)) * forwardThrust
	
	self.move_and_slide(velocity)
	self.rotate(rotationDirection * PI * delta)
	
	if(self.position.x < 0): self.position.x = 1000
	if(self.position.x > 1024): self.position.x = 0
	if(self.position.y < 0): self.position.y = 600
	if(self.position.y > 600): self.position.y = 0
	
	if(is_network_master()):
		synchronize()

func synchronize():
	rset("position", position)
	rset("rotation", rotation)
	rset("forwardThrust", forwardThrust)
	rset("visible", visible)

remotesync func shoot():
	var projectile = preload("res://Projectile.tscn")
	var projInst = projectile.instance()
	projInst.position = self.position
	projInst.rotation = self.rotation
	projInst.ignoredBodies.append(self)
	self.get_parent().add_child(projInst)

remotesync func die():
	self.visible = false

remotesync func respawn():
	var spawn
	if(self.get_network_master() == 1):
		spawn = get_parent().get_node("P1_Spawn")
	else:
		spawn = get_parent().get_node("P2_Spawn")
	
	self.position = spawn.position
	self.rotation = spawn.rotation
	self.visible = true
