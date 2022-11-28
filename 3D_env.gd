extends Spatial

var ZOOM_INCREMENT=0.1

var camfocuspos=Vector3(0,0,0)
var mouse_on_viewport=false

func _input(event):
	if mouse_on_viewport:
		if event is InputEventMouseMotion:
			if Input.is_action_pressed("cam_rotate"):
				var dist=$Camera.get_translation().distance_to(camfocuspos)
				$Camera.set_translation(camfocuspos)
				$Camera.rotate_object_local(Vector3(0,1,0), -event.relative.x/100)
				$Camera.rotate_object_local(Vector3(1,0,0), -event.relative.y/200)
				$Camera.translate(Vector3(0,0,dist))
			if Input.is_action_pressed("cam_pan"):
				var dist=$Camera.get_translation()
				$Camera.translate(Vector3(-event.relative.x/100,event.relative.y/100,0))
				var trans_delta=$Camera.get_translation()-dist
				camfocuspos+=trans_delta
				
		if event is InputEventMouseButton:
			if Input.is_action_just_released("cam_zoom_in"):
				$Camera.translate(Vector3(0,0,-ZOOM_INCREMENT))
			if Input.is_action_just_released("cam_zoom_out"):
				$Camera.translate(Vector3(0,0,ZOOM_INCREMENT))


func _on_ViewportContainer_mouse_entered():
	mouse_on_viewport=true


func _on_ViewportContainer_mouse_exited():
	mouse_on_viewport=false
