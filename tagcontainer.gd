extends Control

var kvedit = load("res://keyvalueedit.tscn")
var tagbox = load("res://tagcontainer.tscn")

@export var title: String

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text=title
	name=title
	#hide the panelbar for children
	$PanelContainer.hide()

func add_attr(attr_node):
	add_child(attr_node, true)

func add_child_tag(child_name):
	$PanelContainer.show()
	var child = tagbox.instantiate()
	child.title = child_name
	$PanelContainer/VBoxContainer.add_child(child, true)

func showpanel():
	$PanelContainer.show()
