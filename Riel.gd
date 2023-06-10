tool
extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var images = []
var textureNodes = []

var spinning = false;

onready var spinTimer = $Timer
onready var startStop = $StartStop
onready var loop = $Loop
var animationPlayer: AnimationPlayer

var startSound = preload('res://assets/sounds/start.wav')
var stopSound = preload('res://assets/sounds/stop.wav')
var loopSound = preload('res://assets/sounds/loop.wav')

var spin_time = 0.1
# Called when the node enters the scene tree for the first time.
func _ready():
	setUpSymbols()
	setUpTimer()
	
	loop.stream = loopSound

func setUpTimer():
	spinTimer.connect("timeout", self, "spin")
	spinTimer.wait_time = spin_time

func setUpSymbols():
	textureNodes = self.get_node("VBoxContainer2/VBoxContainer").get_children()
	preload_images("res://assets/symbols")
	for texture in textureNodes:
		texture.texture = images[randi() % images.size()]
	
	return 


func preload_images(folder_path: String):
	var dir = Directory.new()
	if dir.open(folder_path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print(folder_path + file_name)
			else: 
				if file_name.ends_with(".png") or file_name.ends_with(".jpg"):
					images.push_front(load(folder_path +'/'+ file_name)); 
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		

func spin():
	var lastNode = textureNodes.pop_back();
	setRandomTexture(lastNode)
	
	textureNodes.push_front(lastNode)
	animate_symbol(textureNodes[0])

func setRandomTexture(textureNode):
	textureNode.texture = images[randi() % images.size()]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	if spinning:
		spinning = false
		spinTimer.stop()
		startStop.stream = stopSound
		startStop.play()
		loop.stop()
	else:
		startStop.stream = startSound
		startStop.play()
		spinTimer.start()
		spinning = true
		loop.play()

func animate_symbol(symbol):
	animationPlayer = $AnimationPlayer
	var tween = Tween.new()
	animationPlayer.add_child(tween)
	tween.interpolate_property(symbol, ":rect_scale", Vector2(1, 0), Vector2(1, 1), spin_time /2, Tween.TRANS_SINE)
	tween.start()
	
	

func _on_Loop_finished():
	if spinning:
		loop.play()

