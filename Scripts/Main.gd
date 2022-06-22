extends Control

onready var AddButton = $HBoxContainer/AddTaskButton
onready var ToDoContainer = $ListContainers/ToDoScroll/ToDoContainer
onready var ProgressContainer = $ListContainers/ProgressScroll/ProgressContainer
onready var ReviewContainer = $ListContainers/ReviewScroll/ReviewContainer
onready var DoneContainer = $ListContainers/DoneScroll/DoneTaskContainer
onready var NewTaskPopUp = $NewTaskPopUp
onready var ConfirmButton = $NewTaskPopUp/ConfirmButton
onready var NewTaskText = $NewTaskPopUp/NewTaskText
onready var SearchTask = $HBoxContainer/SearchTask
onready var StoreButton = $StoreButton
onready var NewBoardButton = $NewBoardButton
onready var LoadBoardButton = $LoadBoardButton
onready var BoardName = $HBoxContainer/BoardName
onready var FileBox = $FileDialog
onready var ImportanceOptions = $NewTaskPopUp/ImportanceOptions
onready var AssignName = $NewTaskPopUp/AssignName
onready var EstimatedTime = $EstimatedTime
onready var EstTime = $NewTaskPopUp/EstTime
onready var CompleteBar = $CompleteBar
onready var TestingBar = $TestingBar
onready var InProgressBar = $InProgressBar
onready var ToDoBar = $ToDoBar

var NewTask = load("res://Scenes/NewTask.tscn")
var ImportanceItems := ["low", "medium", "high"]
var TotalProjectTime:int = 0
var UserGuessTime:int = 0
var RiskBuffer:float = 0.25
var TimeEaters:float = 0.2


func calculate_bars():
	var ToDoCount:float = ToDoContainer.get_children().size()-1
	var ProgressCount:float = ProgressContainer.get_children().size()-1
	var TestingCount:float = ReviewContainer.get_children().size()-1
	var CompleteCount:float = DoneContainer.get_children().size()-1
	var TotalChildren:float = 0.0
	
	for n in [ToDoCount, ProgressCount, TestingCount, CompleteCount]:
		TotalChildren += n
	
	set_bars([ToDoCount, ProgressCount, TestingCount, CompleteCount, TotalChildren])


func set_bars(bars:Array):
	ToDoBar.value = (bars[0]/bars[4]) * 100
	InProgressBar.value = ToDoBar.value + ((bars[1]/bars[4]) * 100)
	TestingBar.value = InProgressBar.value + ((bars[2]/bars[4]) * 100)
	CompleteBar.value = TestingBar.value + ((bars[3]/bars[4]) * 100)


func reset_bars():
	ToDoBar.value = 0
	InProgressBar.value = 0
	TestingBar.value = 0
	CompleteBar.value = 0


func _ready():
	yield(get_tree(),"idle_frame")
	add_importance_options(ImportanceItems)
	connect_signals()
	reset_bars()


func connect_signals():
	AddButton.connect("pressed", self, "_on_add_task_pressed")
	ConfirmButton.connect("pressed", self, "_on_confirm_pressed")
	NewTaskText.connect("text_entered", self, "_on_new_text_entered")
	NewTaskText.connect("text_changed", self, "_on_text_changed")
	EstTime.connect("text_changed", self, "_on_text_changed")
	NewTaskPopUp.connect("popup_hide", self, "_on_task_popup_hide")
	SearchTask.connect("text_changed", self, "_on_search_text")
	StoreButton.connect("pressed", self, "_on_save")
	NewBoardButton.connect("pressed", self, "_on_new_board_pressed")
	LoadBoardButton.connect("pressed", self, "_on_load_board_pressed")
	FileBox.connect("file_selected", self, "_on_file_selected")
	ImportanceOptions.connect("item_selected", self, "_on_importance_selected")


func _on_task_popup_hide():
	NewTaskText.clear()
	ImportanceOptions.select(0)


func _on_importance_selected(_idx):
	check_new_task_requirements()


func add_importance_options(options:PoolStringArray):
	ImportanceOptions.add_item("Select Importance Option")
	ImportanceOptions.set_item_disabled(0, true)
	for o in options:
		ImportanceOptions.add_item(o)


func check_new_task_requirements():
	if NewTaskText.text != "" and int(ImportanceOptions.get_selected_id()) != 0 and EstTime.text != "":
		NewTaskPopUp.get_node("ConfirmButton").disabled = false
		return true


func _on_file_selected(file):
	Global.load_data(file)
	load_tasks()


func _on_load_board_pressed():
	FileBox.popup_centered()


func _on_new_board_pressed():
	Empty_Board([ToDoContainer.get_children(),
	ProgressContainer.get_children(),
	ReviewContainer.get_children(),
	DoneContainer.get_children()])
	
	BoardName.clear()


func Empty_Board(list:Array):
	for cont in list:
		for child in cont:
			if not child.name == "Footer":
				child.queue_free()
	
	reset_bars()
	UserGuessTime = 0
	EstimatedTime.text = "Total Estimated Project Time: 00:00 - 00:00"


func load_tasks():
	Empty_Board([ToDoContainer.get_children(),
	ProgressContainer.get_children(),
	ReviewContainer.get_children(),
	DoneContainer.get_children()])
	
	if Global.Data:
		for task in Global.Data.keys():
			
			match int(Global.Data[task]["PriorityLevel"]):
				
				0:
					add_task(Global.Data[task]["Task"], ToDoContainer, 0, Color("ffa9a9"), int(Global.Data[task]["ImportanceLevel"]), Global.Data[task]["TaskRequirements"], Global.Data[task]["AssignedName"], Global.Data[task]["TaskLength"])

				1:
					add_task(Global.Data[task]["Task"], ProgressContainer, 1, Color('a9b4ff'), int(Global.Data[task]["ImportanceLevel"]), Global.Data[task]["TaskRequirements"], Global.Data[task]["AssignedName"], Global.Data[task]["TaskLength"])

				2:
					add_task(Global.Data[task]["Task"], ReviewContainer, 2, Color('d6a9ff'), int(Global.Data[task]["ImportanceLevel"]), Global.Data[task]["TaskRequirements"], Global.Data[task]["AssignedName"], Global.Data[task]["TaskLength"])

				3:
					add_task(Global.Data[task]["Task"], DoneContainer, 3, Color('a9ffac'), int(Global.Data[task]["ImportanceLevel"]), Global.Data[task]["TaskRequirements"], Global.Data[task]["AssignedName"], Global.Data[task]["TaskLength"])
		
		BoardName.text = Global.CurrentBoard
		calculate_bars()


func _on_save():
	Global.store_data([ToDoContainer.get_children(),
	ProgressContainer.get_children(),
	ReviewContainer.get_children(),
	DoneContainer.get_children()],
	BoardName.text)


func _on_search_text(new_text):
	search_list([ToDoContainer.get_children(),
	ProgressContainer.get_children(),
	ReviewContainer.get_children(),
	DoneContainer.get_children()],
	new_text)


func search_list(list:Array, target:String):
	if !target == "":
		
		for cont in list:
			
			for child in cont:
				if child.name != "Footer":
					if !target.to_lower() in child.TaskTitle.text.to_lower() and !target.to_lower() in child.get_node("AssignedUser").text.to_lower():
						child.visible = false
					
					else:
						child.visible = true
	
	else:
		
		for cont in list:
			
			for child in cont:
				child.visible = true


func _on_text_changed(_new_text):
	check_new_task_requirements()


func _on_new_text_entered(_new_text):
	if check_new_task_requirements():
		_on_confirm_pressed()


func _on_add_task_pressed():
	show_new_task_popoup()



func show_new_task_popoup():
	NewTaskPopUp.get_node("ConfirmButton").disabled = true
	NewTaskPopUp.window_title = "Create New Task"
	NewTaskPopUp.popup_centered()
	NewTaskText.grab_focus()


func _on_confirm_pressed():
	add_task(NewTaskText.text, ToDoContainer, 0, Color('ffa9a9'), ImportanceOptions.get_selected_id()-1, "", AssignName.text, EstTime.text.to_int())
	NewTaskText.clear()
	AssignName.clear()
	EstTime.clear()
	ImportanceOptions.select(0)
	NewTaskPopUp.hide()
	
	calculate_bars()


func move_footer(container):
	container.move_child(container.get_node("Footer"), container.get_children().size())


func add_task(tasktitle:String, container = ToDoContainer, prior := 0, colour := Color('ffa9a9'), importancelevel = 0, taskrequirement:String = "", nameassigned:String = "", length:int = 0):
	var NewTaskInst = NewTask.instance()
	NewTaskInst.PriorityLevel = prior
	NewTaskInst.ImportanceLevel = importancelevel
	NewTaskInst.TaskRequirements = taskrequirement
	container.add_child(NewTaskInst)
	NewTaskInst.TaskTitle.text = tasktitle
	NewTaskInst.SepColour.color = colour
	NewTaskInst.AssignedName = nameassigned
	NewTaskInst.TaskLength = length
	NewTaskInst.get_node("AssignedUser").text = nameassigned
	move_footer(container)
	UserGuessTime += length
	update_estimated_time()


func update_estimated_time():
	var min_hour:int = int(UserGuessTime/60)
	var min_minute:int = UserGuessTime - (min_hour * 60)
	TotalProjectTime = UserGuessTime + UserGuessTime * RiskBuffer + UserGuessTime * TimeEaters
	var max_hour:int = TotalProjectTime/60
	var max_minute:int = TotalProjectTime - (max_hour * 60)
	EstimatedTime.text = "Total Estimated Project Time: %02d:%02d - %02d:%02d" %[min_hour, min_minute, max_hour, max_minute]


func Move_Task(task):
	match task.PriorityLevel:
		
		0:
			ProgressContainer.remove_child(task)
			ToDoContainer.add_child(task)
			move_footer(ToDoContainer)
		
		1:
			if task in ToDoContainer.get_children():
				ToDoContainer.remove_child(task)
				ProgressContainer.add_child(task)
				move_footer(ProgressContainer)
				
			else:
				ReviewContainer.remove_child(task)
				ProgressContainer.add_child(task)
				move_footer(ProgressContainer)
		
		2:
			if task in ProgressContainer.get_children():
				ProgressContainer.remove_child(task)
				ReviewContainer.add_child(task)
				move_footer(ReviewContainer)
				
			else:
				DoneContainer.remove_child(task)
				ReviewContainer.add_child(task)
				move_footer(ReviewContainer)
		
		3:
			if task in ReviewContainer.get_children():
				ReviewContainer.remove_child(task)
				DoneContainer.add_child(task)
				move_footer(DoneContainer)
	
	calculate_bars()
