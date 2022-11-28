extends Control

var urdf_parser=load("res://urdf_parser.gd").new()
var urdf_renderer=load("res://urdf_renderer.gd").new()
var kvedit=load("res://keyvalueedit.tscn")
var tagbox=load("res://tagcontainer.tscn")

var attrs_list=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	var result=urdf_parser.parse($HBoxContainer/InputPanel/TextEdit.text)
	add_to_sidebar(result)

func add_to_sidebar(parsed,parents=[]):
	for i in parsed:
		if i=="children":
			var tagnode=get_node_or_null("HBoxContainer/Sidebar/"+build_node_addr(parents)+parsed["type"])
			tagnode.showpanel()
			for child in parsed[i]:
				add_to_sidebar(child, parents+[parsed["type"]])
		else:
			var newkv=kvedit.instance()
			attrs_list.append(newkv)
			#if numeric
			if parsed[i][0].is_valid_float():
				newkv.attr_type=1
				newkv.attr_val=float(parsed[i][0])
			#if triple-numeric
			elif len(parsed[i][0].split(" "))==3:
				newkv.attr_type=2
				newkv.attr_val=parsed[i][0]
			#if quadruple-numeric
			elif len(parsed[i][0].split(" "))==4:
				newkv.attr_type=3
				newkv.attr_val=parsed[i][0]
			#if text
			else:
				newkv.attr_type=0
				newkv.attr_val=parsed[i][0]
			newkv.attr_name=String(i)
			newkv.attr_index=parsed[i][1]
			
			var tagnode=get_node_or_null("HBoxContainer/Sidebar/"+build_node_addr(parents)+parsed["type"])
			#var tagnode=get_node_or_null("HBoxContainer/Sidebar/"+parsed["type"])
			if tagnode != null:
				tagnode.add_attr(newkv)
			else:
				var newtag = tagbox.instance()
				newtag.title=parsed["type"]
				var parentaddr="HBoxContainer/Sidebar/"+build_node_addr(parents).rstrip("/")
				print(parentaddr)
				get_node(parentaddr).add_child(newtag, true)
			print("Added: ",i," = ",parsed[i], " under ", parents)

# appends all parent nodes together.
func build_node_addr(listy):
	var dat=""
	for i in listy:
		dat=dat+i+"/PanelContainer/VBoxContainer/"
	return dat

func edit_val(index, oldlen, delta_len, oldval, newval):
	#update value in text
	var textnode=$HBoxContainer/InputPanel/TextEdit
	textnode.text=(textnode.text).left(index)+newval+(textnode.text).right(index+oldlen)
	#update affected indices
	for attr in attrs_list:
		if attr.attr_index>index:
			attr.attr_index+=delta_len
	print("Value edited: "+str(oldval)+" changed to "+str(newval)+" on index "+str(index))
	

# fill in the textbox with a sample input.
func _on_TestButton_pressed():
	var test_urdf="""<link name="my_link">
   <visual>
	 <origin xyz="0 0 0" rpy="0 0 0" />
	 <geometry>
	   <box size="1 1 1" />
	 </geometry>
	 <material name="Cyan">
	   <color rgba="0 1.0 1.0 1.0"/>
	 </material>
   </visual>
</link>"""
	$HBoxContainer/InputPanel/TextEdit.text=test_urdf



func _on_RenderButton_pressed():
	var result=urdf_parser.parse($HBoxContainer/InputPanel/TextEdit.text)
	var env3d=get_node("HBoxContainer/ViewportContainer/Viewport/3D_env")
	urdf_renderer.render_urdf(result, env3d)
