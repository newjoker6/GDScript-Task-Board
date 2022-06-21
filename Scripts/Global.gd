extends Node


var Data := {
	
}

var CurrentBoard:String = ""


func save_data(boardname:String):
	var f = File.new()
	f.open("user://%s.json" %boardname, f.WRITE)
	f.store_line(to_json(Data))
	f.close()


func load_data(path):
	var boardname = path.get_basename().trim_prefix("user://")
	var f = File.new()
	if f.file_exists("%s" %path):
		f.open("%s" %path, f.READ)
		Data = parse_json(f.get_as_text())
		CurrentBoard = boardname
	f.close()


func store_data(list:Array, boardname:String):
	Data = {}
	for cont in list:
		
		for child in cont:
			if child.name != "Footer":
				Data[child] = {}
				Data[child]["PriorityLevel"] = child.PriorityLevel
				Data[child]["Task"] = child.TaskTitle.text
				Data[child]["ImportanceLevel"] = child.ImportanceLevel
				Data[child]["TaskRequirements"] = child.TaskRequirements
	
	save_data(boardname)
