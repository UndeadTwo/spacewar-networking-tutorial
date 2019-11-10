extends Area2D

var lifetime = 0.75
const speed = 375

var ignoredBodies = []

func _ready():
	set_network_master(1)
	rset_config("position", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)
	
	if(is_network_master()):
		rset("rotation", rotation)
	
	connect("body_entered", self, "body_entered")

func _physics_process(delta):
	self.position += Vector2(cos(rotation - PI/2), sin(rotation - PI/2)) * delta * speed
	self.lifetime -= delta
	
	if(is_network_master()):
		if(self.lifetime <= 0):
			rpc("die")
		
		rset("position", position)

func body_entered(body):
	if(!body in ignoredBodies):
		if(body.has_method("die")):
			body.call("die")

remotesync func die():
	self.get_parent().remove_child(self)
