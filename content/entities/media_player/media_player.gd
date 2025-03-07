extends Entity

const Entity = preload("../entity.gd")

@export var image_width = 0.15

@onready var previous = $Previous
@onready var next = $Next
@onready var play = $Play
@onready var logo = $PlayingInfo/Logo
@onready var title = $PlayingInfo/Title
@onready var artist = $PlayingInfo/Artist
@onready var http_request = $PlayingInfo/HTTPRequest
@onready var slider = $Slider

var playing = false
var volume = 50


# Called when the node enters the scene tree for the first time.
func _ready():
	super()

	var stateInfo = await HomeApi.get_state(entity_id)
	set_state(stateInfo)

	await HomeApi.watch_state(entity_id, func(new_state):
		set_state(new_state)
	)

	previous.on_button_down.connect(func():
		HomeApi.set_state(entity_id, "previous")
	)

	play.on_button_down.connect(func():
		if playing:
			HomeApi.set_state(entity_id, "pause")
		else:
			HomeApi.set_state(entity_id, "play")
	)

	next.on_button_down.connect(func():
		HomeApi.set_state(entity_id, "next")
	)

	slider.on_value_changed.connect(set_volume)


func set_volume(value):
	volume = value
	HomeApi.set_state(entity_id, "volume", {"volume_level": value / 100})

func set_state(stateInfo):
	var state = stateInfo["state"]

	if state == "playing":
		if stateInfo["attributes"].has("entity_picture_local"):
			load_image(stateInfo["attributes"]["entity_picture_local"])
		title.text = stateInfo["attributes"]["media_title"]
		artist.text = stateInfo["attributes"]["media_artist"]

		volume = float(stateInfo["attributes"]["volume_level"]) * 100
		slider.value = volume
		
		playing = true
		play.label = "pause"
	else:
		playing = false
		play.label = "play_arrow"

func load_image(url: String):
	http_request.request("http://192.168.33.33:8123" + url)

	var result = await http_request.request_completed

	if result[0] != HTTPRequest.RESULT_SUCCESS:
		print("Error loading image: ", result[0], " ", result[1])
		return

	var image = Image.new()
	var error = image.load_jpg_from_buffer(result[3])

	var pixel_size = image_width / image.get_size().x

	if error != OK:
		print("Error loading image: ", error)
		return

	var texture = ImageTexture.create_from_image(image)
	logo.texture = texture
	logo.pixel_size = pixel_size