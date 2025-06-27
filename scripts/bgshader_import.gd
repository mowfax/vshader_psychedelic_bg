@tool
class_name BGShaderImport
extends EditorScript

# Node Path relative to root
var node_target: String = "BGShader"

# File Path including filename
var bg_type: String = "circle" # circle, spiral, cone
var bg_index: String = "00" # 2 digits
var import_shader: String = "res://params/bg_" + bg_type + "_" + bg_index + ".tres"


func _run():
	var root_node: Node = get_scene()
	var target: ColorRect = root_node.get_node(node_target) as ColorRect
	var material: ShaderMaterial = target.material
	
	if FileAccess.file_exists(import_shader):
		if ("circle" in import_shader) or ("spiral" in import_shader):
			var circle: BGShaderCircle = load(import_shader) as BGShaderCircle
			var properties: Array = []
			for property in circle.get_property_list():
				properties.append(property.name)
			material.shader = circle.shader_file
			var uniforms: Array = target.material.shader.get_shader_uniform_list()
			for uniform in uniforms:
				if uniform.name.to_snake_case() in properties:
					material.set_shader_parameter(uniform.name, circle.get(uniform.name.to_snake_case()))
			
		elif "cone" in import_shader:
			var cone: BGShaderCone = load(import_shader) as BGShaderCone
			var properties: Array = []
			for property in cone.get_property_list():
				properties.append(property.name)
			material.shader = cone.shader_file
			var uniforms: Array = target.material.shader.get_shader_uniform_list()
			for uniform in uniforms:
				if uniform.name.to_snake_case() in properties:
					material.set_shader_parameter(uniform.name, cone.get(uniform.name.to_snake_case()))
			
		else:
			print_rich("[color=red][b]Shadertype not recognized[/b][/color]")
		
		print_rich("[color=green][b]Shader Config loaded successfully![/b][/color]")
	else:
		print_rich("[color=red][b]Shader could not be loaded.[/b][/color]")
		
