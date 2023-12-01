@tool
class_name Cognite extends EditorPlugin

var inspector: EditorInspectorPlugin
static var alert: AcceptDialog
var main_panel: Control


func _enter_tree():
	main_panel = preload("res://addons/cognite/editor/cognite_editor.tscn").instantiate()
	main_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	get_editor_interface().get_editor_main_screen().add_child(main_panel)
	_make_visible(false)
	
	inspector = preload("res://addons/cognite/inspector.gd").new()
	inspector.main_panel = main_panel
	inspector.plugin = self
	add_inspector_plugin(inspector)
	
	add_custom_type( "CogniteNode", "Node",
			preload("res://addons/cognite/node/cognite_node.gd"),
			preload("res://addons/cognite/assets/brain.svg"))
	
	alert = AcceptDialog.new()
	alert.get_ok_button().text = "Close"
	get_editor_interface().get_base_control().add_child(alert)


func _exit_tree():
	remove_inspector_plugin(inspector)
	remove_custom_type("CogniteNode")
	if is_instance_valid(main_panel):
		main_panel.queue_free()
	if is_instance_valid(alert):
		alert.queue_free()


static func emit_alert(mensagem: String):
	alert.dialog_text = mensagem
	alert.popup_centered()


#region MAIN PANEL
func _has_main_screen():
	return true

func _make_visible(visible: bool):
	if main_panel:
		main_panel.visible = visible

func _get_plugin_name():
	return "Cognite"

func _get_plugin_icon():
	return preload("res://addons/cognite/assets/brain.svg")
#endregion


