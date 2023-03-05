extends Node3D

var ZOOM_INCREMENT=0.1

var camfocuspos=Vector3(0,0,0)
var mouse_on_viewport=false

func _input(event):
	if mouse_on_viewport:
		if event is InputEventMouseMotion:
			if Input.is_action_pressed("cam_rotate"):
				var dist=$Camera3D.get_position().distance_to(camfocuspos)
				$Camera3D.set_position(camfocuspos)
				$Camera3D.rotate_object_local(Vector3(0,1,0), -event.relative.x/100)
				$Camera3D.rotate_object_local(Vector3(1,0,0), -event.relative.y/200)
				$Camera3D.translate(Vector3(0,0,dist))
			if Input.is_action_pressed("cam_pan"):
				var dist=$Camera3D.get_position()
				$Camera3D.translate(Vector3(-event.relative.x/100,event.relative.y/100,0))
				var trans_delta=$Camera3D.get_position()-dist
				camfocuspos+=trans_delta
				
		if event is InputEventMouseButton:
			if Input.is_action_just_released("cam_zoom_in"):
				$Camera3D.translate(Vector3(0,0,-ZOOM_INCREMENT))
			if Input.is_action_just_released("cam_zoom_out"):
				$Camera3D.translate(Vector3(0,0,ZOOM_INCREMENT))


func _on_ViewportContainer_mouse_entered():
	mouse_on_viewport=true


func _on_ViewportContainer_mouse_exited():
	mouse_on_viewport=false
