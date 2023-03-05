#@tool
#extends EditorScript
extends Node

var testcase="""
<type number=3 coords="3 3 3" "spaced attr"=word space1= "0.5" space2 = '0.2' space3 =0.5>
	<type1 number=2>
	<type2 number=1></type1>
</type>
"""

#gets the tags and nests them.
func nest_tags(tags):
	var open_tags=[]
	var children=[]
	var open_tag_name=""
	for tag in tags:
		if tag["type"][0]=="/": #closing tag
			open_tag_name=tag["type"].substr(1)
			var open_tags_inv=open_tags.duplicate() #invert list
			open_tags_inv.reverse()
			for i in range(len(open_tags_inv)):
				var btag=open_tags_inv[i]
				if btag["type"]==open_tag_name:
					btag["children"]=children
					children=[]
					open_tag_name=""
					break
				else:
					children.append(btag)
					open_tags.remove_at(len(open_tags_inv)-i-1)
		else:
			open_tags.append(tag)
	return open_tags
			

#parses full text and outputs a dict.
func find_tags(text):
	var parsed_tag=[] #to store the tag data temporarily
	var tag_text="" #to store text from tag.
	var in_tag=false #are we in a tag?
	var char_index=0 #which character are we parsing right now?
	var tag_start_index #where does the tag start?
	#Note:Doesn't support quotes yet. eg. if your attribute has a string with < in it, that will cause issues.
	for i in text:
		if i=="<" :
			in_tag=true
			tag_start_index=char_index
		elif i==">":
			in_tag=false
			parsed_tag.append(parse_tag(tag_text, tag_start_index))
			tag_text=""
		else: #regular text
			if in_tag:
				tag_text+=i #add to tag text
		char_index+=1 #increment char index
	return parsed_tag

func parse_tag(tag, tag_start_index):
	var dic = process_tag(split_tag(tag))
	var old_dic={}
	var indexed_dic={}
	
	for key in dic:
		if key!="type":
			old_dic[key]=dic[key][0]
			indexed_dic[key]=[dic[key][0],dic[key][1]+tag_start_index]
		else:
			old_dic[key]=dic[key]
			indexed_dic[key]=dic[key]
	
	return indexed_dic
	
#gets the list from split_tag, then turns it into a nice dict.
func process_tag(tag_list):
	var dic={}
	dic["type"]=tag_list[0][0]

	var i=1
	var key
	var val
	var delta_index
	while i<len(tag_list):
		if "=" in tag_list[i][0]:
			if tag_list[i][0].split("=")[1]!="": # attr=3
				key=tag_list[i][0].split("=")[0]
				val=tag_list[i][0].split("=")[1]
				#figuring out the index delta
				delta_index=tag_list[i][1]+len(key)+1
				i+=1
			else: # attr= 3
				key=tag_list[i][0].left(1)
				val=tag_list[i+1][0]
				#index delta
				delta_index=tag_list[i+1][1]
				i+=2
		elif tag_list[i+1][0]=="=": # attr = 3
			key=tag_list[i][0]
			val=tag_list[i+2][0]
			#index delta
			delta_index=tag_list[i+2][1]
			i+=3
		elif "=" in tag_list[i+1][0]: # attr =3
			key=tag_list[i][0]
			val=tag_list[i+1][0].right(1)
			#index delta
			delta_index=tag_list[i+1][1]+1
			i+=2
		print(str(key)+" has "+str(val)+" and has delta index: "+str(delta_index))
		dic[key]=[val,delta_index+2] #add 2 to the index, 1 for the quote sign, 1 to have it work

	return dic
	
#split the text in between the <>. returns a list with the element type, attrs and their values.
func split_tag(tag):
	var word=""
	var lis=[]
	var insquote=false #in single or double quotes?
	var indquote=false
	var delta_index=0 #which character are we parsing?
	var wstart_index=0 #index pointing to word beginning
	var wstart_set:bool=false #have we started parsing the word?
	if tag[-1]=="/":
		tag=tag.left(len(tag)-1)
	for i in tag:
		if i == " " and not insquote and not indquote:
			if word:
				lis.append([word,wstart_index])
				word=""
				wstart_set=false
		elif i == "'":
			insquote=not insquote
		elif i == '"':
			indquote=not indquote
		else:
			word+=i
			if not wstart_set:
				wstart_index=delta_index
				wstart_set=true
		delta_index+=1 #increment index
	if word:
		lis.append([word,wstart_index]) #add last element
	return lis



func parse(raw):
	return nest_tags(find_tags(raw))[0]

#func _run():
#	var raw=testcase #input()
#	var out=find_tags(raw)
#	print(nest_tags(out))
