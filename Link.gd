extends Node3D

class Vec3urdf:
	var x:float
	var y:float
	var z:float

class Roturdf:
	var r:float
	var p:float
	var y:float

class Originurdf:
	var xyz:Vector3
	var rpy:Vector3

#class Colorurdf:
#	var r:float
#	var g:float
#	var b:float
#	var a:float

class Massurdf:
	var value:float

class Inertiaurdf:
	var ixx:float
	var ixy:float
	var ixz:float
	var iyy:float
	var iyz:float
	var izz:float

enum GeoTypeurdf {box,cylinder,sphere,mesh}

class Geometryurdf:
	var type:int #GeoTypeurdf, 0..3
	var size:Vector3
	var radius:float
	var length:float
	#TODO: add filename, scale here for mesh support

class Materialurdf:
	var matname:String
	var color:Color
	#TODO: add texture here for texture support

class Inertial:
	var origin:Originurdf
	var mass:Massurdf
	var inertia:Inertiaurdf
	
	func _init():
		self.origin = Originurdf.new()
		self.mass = Massurdf.new()
		self.inertia = Inertiaurdf.new()

class Visual:
	var visname:String
	var origin:Originurdf
	var geometry:Geometryurdf
	var material:Materialurdf
	
	func _init():
		self.origin = Originurdf.new()
		self.geometry = Geometryurdf.new()
		self.material = Materialurdf.new()

class Collision:
	var colname:String
	var origin:Originurdf
	var geometry:Geometryurdf
	
	func _init():
		self.origin = Originurdf.new()
		self.geometry = Geometryurdf.new()

# Declare member variables here.
var link_name:String
var inertial=Inertial.new()
var visual=Visual.new()
var collision=Collision.new()


func _ready():
	#parent node creation
	var link_node=Node3D.new()
	link_node.set_name(link_name)
	
	var vis_geo
	
	#visual node creation
	match visual.geometry.type:
		GeoTypeurdf.box:
			if visual.geometry.size:
				vis_geo = CSGBox3D.new()
				vis_geo.set_name("vis_geo")
				link_node.add_child(vis_geo)
				#set box size.
				#TODO: verify that x,y,z assignments are correct here!
				vis_geo.width=visual.geometry.size.x/2
				vis_geo.height=visual.geometry.size.y/2
				vis_geo.depth=visual.geometry.size.z/2
				#set box orientation
				vis_geo.position=visual.origin.xyz
				#TODO: verify rpy assignments are correct
				vis_geo.rotation=visual.origin.rpy
				print("box created!")
		GeoTypeurdf.cylinder:
			if visual.geometry.radius and visual.geometry.length:
				vis_geo = CSGCylinder3D.new()
				vis_geo.set_name("vis_geo")
				link_node.add_child(vis_geo)
				#set cylinder size
				vis_geo.radius=visual.geometry.radius
				vis_geo.height=visual.geometry.length
				#set cylinder orientation
				vis_geo.position=visual.origin.xyz
				#TODO: verify rpy assignments are correct
				vis_geo.rotation=visual.origin.rpy
				print("cylinder created!")
		GeoTypeurdf.sphere:
			if visual.geometry.radius:
				vis_geo = CSGSphere3D.new()
				vis_geo.set_name("vis_geo")
				link_node.add_child(vis_geo)
				#set sphere size
				vis_geo.radius=visual.geometry.radius
				#set sphere orientation
				vis_geo.position=visual.origin.xyz
				#TODO: verify rpy assignments are correct
				vis_geo.rotation=visual.origin.rpy
				print("sphere created!")
		GeoTypeurdf.mesh:
			pass #not implemented
		_:
			pass
	
	if visual.material.matname:
		vis_geo.material=StandardMaterial3D.new()
		vis_geo.material.albedo_color=visual.material.color
	
	add_child(link_node)
