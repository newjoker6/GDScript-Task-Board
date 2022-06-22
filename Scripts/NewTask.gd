extends Control

onready var SepColour = $ColorRect
onready var TaskTitle = $TaskTitle
onready var TaskBack = $TaskBack
onready var PopUpMenu = $PopupMenu
onready var MoveTaskMenu = $PopupMenu/MoveTaskMenu
onready var ImportanceMenu = $PopupMenu/ImportanceMenu
onready var ImportanceIcon = $ImportanceIcon
onready var CloseButton = $RequirementsControl/CloseButton
onready var RequirementsControl = $RequirementsControl
onready var RequirementsText = $RequirementsControl/Requirements
onready var AssignedUser = $AssignedUser
onready var NewName = $NewName


export var canimage: ImageTexture
export var rightarrow: ImageTexture
export var leftarrow: ImageTexture

export var lowimp: ImageTexture
export var medimp: ImageTexture
export var highimp: ImageTexture

var PriorityLevel: int
var MouseEnter: bool = false
var ImportanceLevel: int
var TaskRequirements: String
var AssignedName:String = ""
var TaskLength:int

enum Priority {
	TODO,
	INPROGRESS,
	REVIEW,
	DONE
}

enum Importance {
	LOW,
	MEDIUM
	HIGH
}


func _ready():
	set_importance_icon(ImportanceLevel)
	connect_signals()
	add_menu_items()


func connect_signals():
	TaskBack.connect("mouse_entered", self, "_on_mouse_entered")
	TaskBack.connect("mouse_exited", self, "_on_mouse_exited")
	PopUpMenu.connect("index_pressed", self, "_on_menu_index_pressed")
	MoveTaskMenu.connect("index_pressed", self, "_on_task_menu_index_pressed")
	ImportanceMenu.connect("index_pressed", self, "_on_importance_menu_index_pressed")
	CloseButton.connect("pressed", self, "_on_close_button_pressed")
	NewName.connect("text_entered", self, "_on_new_name_text")


func _on_new_name_text(new_text):
	AssignedName = new_text
	AssignedUser.text = new_text
	NewName.clear()
	NewName.hide()


func _on_close_button_pressed():
	RequirementsControl.visible = false
	TaskRequirements = RequirementsText.text


func _on_mouse_entered():
	MouseEnter = true


func _on_mouse_exited():
	MouseEnter = false


func hide_menus():
	PopUpMenu.hide()
	MoveTaskMenu.hide()


func set_importance_icon(level:int):
	match level:
		0:
			ImportanceIcon.texture = lowimp
		1:
			ImportanceIcon.texture = medimp
		2:
			ImportanceIcon.texture = highimp


func _on_importance_menu_index_pressed(idx):
	var selection = ImportanceMenu.get_item_text(idx)
	match selection:
		
		"High":
			self.ImportanceLevel = Importance.HIGH
			
		"Medium":
			self.ImportanceLevel = Importance.MEDIUM
		
		"Low":
			self.ImportanceLevel = Importance.LOW
	
	set_importance_icon(ImportanceLevel)


func _input(_event):
	if Input.is_action_just_released("Right Click") and MouseEnter:
		PopUpMenu.rect_position = get_global_mouse_position()
		PopUpMenu.visible = !PopUpMenu.visible

	elif Input.is_action_just_released("Left Click") and MouseEnter:
		RequirementsControl.visible = true
		RequirementsText.text = TaskRequirements
		


func add_menu_items():
	PopUpMenu.add_item("Reassign User")
	PopUpMenu.add_submenu_item("Move Task","MoveTaskMenu")
	PopUpMenu.add_submenu_item("Importance    ","ImportanceMenu")
	PopUpMenu.add_icon_item(canimage, "Delete")

	MoveTaskMenu.add_icon_item(rightarrow, "Advance Task")
	MoveTaskMenu.add_icon_item(leftarrow, "Retreat Task")
	
	ImportanceMenu.add_icon_item(highimp, "High")
	ImportanceMenu.add_icon_item(medimp, "Medium")
	ImportanceMenu.add_icon_item(lowimp, "Low")


func _on_menu_index_pressed(idx):
	var item = PopUpMenu.get_item_text(idx)
	
	match item:
		
		"Delete":
			delete_task()
		
		"Reassign User":
			NewName.show()
			NewName.grab_focus()


func create_texture(image_path):
	var img = Image.new()
	img.load(image_path)
	var texture = ImageTexture.new()
	texture.create_from_image(img)
	return texture


func _on_task_menu_index_pressed(idx):
	var item = MoveTaskMenu.get_item_text(idx)
	
	match item:
		
		"Advance Task":
			advance_task()
		
		"Retreat Task":
			retreat_task()


func delete_task():
	self.queue_free()


func update_priority(add_level:int):
	PriorityLevel += add_level
	update_colour()


func advance_task():
	if PriorityLevel < 3:
		update_priority(1)
		get_parent().get_parent().get_parent().get_parent().Move_Task(self)


func retreat_task():
	if PriorityLevel > 0:
		update_priority(-1)
		get_parent().get_parent().get_parent().get_parent().Move_Task(self)


func update_colour():
	match PriorityLevel:
		
		0:
			SepColour.color = Color('ffa9a9')
		
		1:
			SepColour.color = Color('a9b4ff')
		
		2:
			SepColour.color = Color('d6a9ff')
		
		3:
			SepColour.color = Color('a9ffac')
