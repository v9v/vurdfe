extends Control

#spinbox increments. -1 for no limitation
const EPSILON=0.001

# type of the attribute, string, number, three numbers or four numbers?
enum ATTRT {text, num, xyz, rgba}
@export var attr_type: ATTRT
# name of attribute
@export var attr_name: String
# value of attribute
@export var attr_val: String
# index of where the value is located in original text
@export var attr_index: int

var prev_val: String
var root_node

func _ready():
	root_node=get_node("/root/Main")
	#update the attribute name
	$Label.text=attr_name
	name=attr_name
	prev_val=attr_val
	#dynamically add the editable portion of the element
	#a text field, a number field or three number fields
	#TODO: maybe change the spinboxes to lineedits with input validation and
	#custom drag-to-change features. These have annoying limits.
	match attr_type:
		ATTRT.text:
			var textfield=LineEdit.new()
			#configure
			textfield.name="TextField"
			textfield.custom_minimum_size.x=175
			#set attribute value
			textfield.text=attr_val
			add_child(textfield)
		ATTRT.num:
			var numfield=SpinBox.new()
			#configure
			numfield.name="NumField"
			numfield.custom_minimum_size.x=175
			numfield.allow_greater=true
			numfield.allow_lesser=true
			numfield.step=EPSILON
			#set attribute value
			numfield.value=float(attr_val)
			add_child(numfield)
		ATTRT.xyz:
			var xfield=SpinBox.new()
			var yfield=SpinBox.new()
			var zfield=SpinBox.new()
			#configure
			xfield.name="XField"
			yfield.name="YField"
			zfield.name="ZField"
			xfield.custom_minimum_size.x=50
			yfield.custom_minimum_size.x=50
			zfield.custom_minimum_size.x=50
			xfield.allow_greater=true
			xfield.allow_lesser=true
			yfield.allow_greater=true
			yfield.allow_lesser=true
			zfield.allow_greater=true
			zfield.allow_lesser=true
			xfield.step=EPSILON
			yfield.step=EPSILON
			zfield.step=EPSILON
			#set attribute values
			#split the string by spaces first
			#TODO: add checks
			var listval=attr_val.split(" ",true,3)
			xfield.value=float(listval[0])
			yfield.value=float(listval[1])
			zfield.value=float(listval[2])
			add_child(xfield)
			add_child(yfield)
			add_child(zfield)
		ATTRT.rgba:
			var rfield=SpinBox.new()
			var gfield=SpinBox.new()
			var bfield=SpinBox.new()
			var afield=SpinBox.new()
			#configure
			rfield.name="RField"
			gfield.name="GField"
			bfield.name="BField"
			afield.name="AField"
			rfield.custom_minimum_size.x=50
			gfield.custom_minimum_size.x=50
			bfield.custom_minimum_size.x=50
			afield.custom_minimum_size.x=50
			rfield.allow_greater=true
			rfield.allow_lesser=true
			gfield.allow_greater=true
			gfield.allow_lesser=true
			bfield.allow_greater=true
			bfield.allow_lesser=true
			afield.allow_greater=true
			afield.allow_lesser=true
			rfield.step=EPSILON
			gfield.step=EPSILON
			bfield.step=EPSILON
			afield.step=EPSILON
			#set attribute values
			#split the string by spaces first
			#TODO: add checks
			var listval=attr_val.split(" ",true,4)
			rfield.value=float(listval[0])
			gfield.value=float(listval[1])
			bfield.value=float(listval[2])
			afield.value=float(listval[3])
			add_child(rfield)
			add_child(gfield)
			add_child(bfield)
			add_child(afield)
	#connect to edit checking timer
	var timer=get_node("/root/Main/EditCheckTimer")
	timer.connect("timeout",Callable(self,"_on_EditCheckTimer_timeout"))

#get the attribute val in a single string.
func get_attr_val():
	match attr_type:
			ATTRT.text:
				return $TextField.text
			ATTRT.num:
				return str($NumField.value)
			ATTRT.xyz:
				return (str($XField.value)+" "+str($YField.value)+" "+str($ZField.value))
			ATTRT.rgba:
				return (str($RField.value)+" "+str($GField.value)+" "+str($BField.value)+" "+str($AField.value))

#check current value against previously stored value.
#if there is a difference, call Main.gd's function to update the code text.
func check_update():
	var new_val=get_attr_val()
	if new_val!=prev_val:
		var old_len=len(prev_val)
		var delta_len=len(new_val)-old_len
		root_node.edit_val(attr_index, old_len, delta_len, prev_val, new_val)
		prev_val=new_val

#called every second by the timer.
#run check_update.
func _on_EditCheckTimer_timeout():
	check_update()
