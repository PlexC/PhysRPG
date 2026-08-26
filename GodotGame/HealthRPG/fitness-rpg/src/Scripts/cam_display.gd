extends TextureRect

var camera: CameraFeed

func _ready():
	# 1. Look at what the user selected in the Settings Autoload
	var target_camera_name = Savemanager.settings.get("camera_name", "")
	
	# 2. Find that specific camera (ignores OBS if they didn't pick it)
	var feeds = CameraServer.feeds()
	if feeds.is_empty():
		print("No cameras plugged in at all.")
		return
		
	for feed in feeds:
		if feed.get_name() == target_camera_name:
			camera = feed
			break
			
	# Fallback: If their saved camera isn't found, just grab the first one that ISN'T OBS
	if camera == null:
		for feed in feeds:
			if "OBS" not in feed.get_name():
				camera = feed
				break
				
	# 3. Turn it on and apply it to the TextureRect!
	if camera != null:
		camera.set_active(true)
		var cam_texture = CameraTexture.new()
		cam_texture.camera_feed_id = camera.get_id()
		self.texture = cam_texture # The video appears instantly
