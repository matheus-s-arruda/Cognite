@tool
class_name CogniteRoutine extends Resource


var modus: String
var event: String


func _init(routine: Dictionary):
	modus = routine.modus; event = routine.event
	
	if not routine.has("body"):
		return
	
	if routine.body is String:
		pass
	
	for member in routine.body:
		if member == "value":
			continue
		
		if routine.body[member].has("ifs"):
			pass
			#code += "	".repeat(identation) + "if "+ member + ":\n"
			#code += build_routine(routine.body[member].ifs, identation + 1)
			
			if routine.body[member].has("else"):
				pass
				#code += "	".repeat(identation) + "else:\n"
				#code += build_routine(body[member].else, identation + 1)
		
		elif routine.body[member].has("else"):
			pass
			#code += "	".repeat(identation) + "if not "+ member + ":\n"
			#code += build_routine(body[member].else, identation + 1)
		
		if routine.body[member].has("bigger"):
			pass
			#code += "	".repeat(identation) + "if "+ member+ " > " + str(body[member].bigger.value) + ":\n"
			#code += build_routine(body[member].bigger, identation + 1)
		
		if routine.body[member].has("smaller"):
			pass
			#code += "	".repeat(identation) + "if "+ member+ " < " + str(body[member].smaller.value) + ":\n"
			#code += build_routine(body[member].smaller, identation + 1)
