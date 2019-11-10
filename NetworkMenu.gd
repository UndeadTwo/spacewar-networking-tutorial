extends Panel

onready var Host = get_node("Host")
onready var HostPort = get_node("Host/Port")

onready var Join = get_node("Join")
onready var JoinAddress = get_node("Join/Address")
onready var JoinPort = get_node("Join/Port")

func _ready():
	Host.connect("button_down", self, "host_pressed")
	Join.connect("button_down", self, "join_pressed")

func host_pressed():
	var Port = int(HostPort.text)
	NetworkSingleton.create_server(Port)

func join_pressed():
	var Address = JoinAddress.text
	var Port = int(JoinPort.text)
	NetworkSingleton.create_client(Address, Port)
