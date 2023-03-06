extends Node

var link_class=preload("res://Link.tscn")

enum GeoTypeurdf {box,cylinder,sphere,mesh}

func create_link(link, env3d):
	if not link["type"]=="link":
		return 0 #or throw error?
	var linknode=link_class.instantiate()
	
	linknode.link_name=link["name"][0]
	
	for sublevel in link["children"]:
		match sublevel["type"]:
			"visual":
				for visproperty in sublevel["children"]:
					match visproperty["type"]:
						"origin":
							var xyz_list=visproperty["xyz"][0].split(" ")
							linknode.visual.origin.xyz=Vector3(float(xyz_list[0]),float(xyz_list[1]),float(xyz_list[2]))
							var rpy_list=visproperty["rpy"][0].split(" ")
							linknode.visual.origin.rpy=Vector3(float(rpy_list[0]),float(rpy_list[1]),float(rpy_list[2]))
						"geometry":
							var object=visproperty["children"][0]
							match object["type"]:
								"box":
									linknode.visual.geometry.type=GeoTypeurdf.box
									var size_list=object["size"][0].split(" ")
									linknode.visual.geometry.size=Vector3(float(size_list[0]),float(size_list[1]),float(size_list[2]))
								"cylinder":
									linknode.visual.geometry.type=GeoTypeurdf.cylinder
									linknode.visual.geometry.radius=object["radius"][0]
									linknode.visual.geometry.length=object["length"][0]
								"sphere":
									linknode.visual.geometry.type=GeoTypeurdf.sphere
									linknode.visual.geometry.radius=object["radius"][0]
								"mesh":
									linknode.visual.geometry.type=GeoTypeurdf.mesh
									pass
								_:
									pass
						"material":
							linknode.visual.material.matname=visproperty["name"][0]
							for matproperty in visproperty["children"]:
								match matproperty["type"]:
									"color":
										var color=matproperty["rgba"][0].split(" ")
										linknode.visual.material.color=Color(float(color[0]),float(color[1]),float(color[2]),float(color[3]))
									_:
										pass
						_:
							pass
			_:
				pass
	env3d.add_child(linknode)

# render the items in urdf_dict
# as children of the node env3d.
func render_urdf(urdf_dict, env3d):
	#clear out previous render
	for child in env3d.get_children():
		child.queue_free()
	
	#render new model
	if urdf_dict["type"]=="link":
		create_link(urdf_dict, env3d)
	else:
		for child in urdf_dict["children"]:
			render_urdf(child, env3d)
