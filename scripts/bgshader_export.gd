@tool
class_name BGShaderExport
extends EditorScript

# Node Path relative to root
var node_target: String = "Background/SubViewportContainer/SubViewport/BGShader01"

# File Path including filename
var bg_type: String = "cone" # circle, spiral, cone
var bg_index: String = "01" # 2 digits
var export_shader: String = "res://shaders/bgshader_configs/bg_" + bg_type + "_" + bg_index + ".tres"
var export_preview: String = "res://graphics/bgshaders/screenshots/bg_" + bg_type + "_" + bg_index + ".png"

# Use SubViewport to grab Shader Preview
var subviewport: SubViewport
var image: Image

func _run():
	var root_node: Node = get_scene()
	var target: ColorRect = root_node.get_node(node_target) as ColorRect
	var shader_path: String = target.material.shader.get_path()
	var material: ShaderMaterial = target.material
	var uniforms: Array = target.material.shader.get_shader_uniform_list()
	var bgshader_result: BGShader
	var save_result: Error
	
	if FileAccess.file_exists(export_preview + ".import"):
		if "circle" in shader_path:
			var circle: BGShaderCircle = BGShaderCircle.new()
			var properties: Array = []
			for property in circle.get_property_list():
				properties.append(property.name)
			for uniform in uniforms:
				if uniform.name.to_snake_case() in properties:
					circle.set(uniform.name.to_snake_case(), material.get_shader_parameter(uniform.name))
			circle.shader_file = material.shader as VisualShader
			circle.screenshot =  load(export_preview)
			save_result = ResourceSaver.save(circle,export_shader)
			bgshader_result = circle
			
		elif "cone" in shader_path:
			var cone: BGShaderCone = BGShaderCone.new()
			var properties: Array = []
			for property in cone.get_property_list():
				properties.append(property.name)
			for uniform in uniforms:
				if uniform.name.to_snake_case() in properties:
					cone.set(uniform.name.to_snake_case(), material.get_shader_parameter(uniform.name))
			cone.shader_file = material.shader as VisualShader
			cone.screenshot =  load(export_preview)
			save_result = ResourceSaver.save(cone,export_shader)
			bgshader_result = cone
			
		else:
			print_rich("[color=red][b]Shadertype not recognized[/b][/color]")
		
		
		if save_result != OK:
			print(save_result)
			for property in bgshader_result.get_property_list():
				if bgshader_result.get(property.name) != null:
					print(property.name + ": " + str(bgshader_result.get(property.name)))
				else:
					print(property.name + ": " + "null")
		else:
			print_rich("[color=green][b]Shader Config created successfully![/b][/color]")
	else:
		# Generate Preview Image
		subviewport = target.get_viewport()
		image = subviewport.get_texture().get_image()
		image.resize(320,200,3)
		image.save_png(export_preview)
		print_rich("[color=green][b]Screenshot created, please run script again to save the shader.[/b][/color]")
		
	EditorInterface.get_resource_filesystem().scan()
