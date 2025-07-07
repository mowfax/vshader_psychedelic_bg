@tool
class_name BGShaderTool
extends Control

@export_enum("circle", "cone", "spiral") var bg_type: String = "circle"
@export_enum("00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10") var bg_index: String = "00" # 2 digits

@export_tool_button("Import BGShader Material")
var import_action = bgshader_import

@export_tool_button("Export BGShader Material")
var export_action = bgshader_export


func bgshader_import():
	var import_shader: String = "res://params/bg_" + bg_type + "_" + bg_index + ".tres"
	var bgmaterial: ShaderMaterial = self.material
	
	if FileAccess.file_exists(import_shader):
		if ("circle" in import_shader) or ("spiral" in import_shader):
			var circle: BGShaderCircle = load(import_shader) as BGShaderCircle
			var properties: Array = []
			for property in circle.get_property_list():
				properties.append(property.name)
			bgmaterial.shader = circle.shader_file
			var uniforms: Array = self.material.shader.get_shader_uniform_list()
			for uniform in uniforms:
				if uniform.name.to_snake_case() in properties:
					material.set_shader_parameter(uniform.name, circle.get(uniform.name.to_snake_case()))
			
		elif "cone" in import_shader:
			var cone: BGShaderCone = load(import_shader) as BGShaderCone
			var properties: Array = []
			for property in cone.get_property_list():
				properties.append(property.name)
			bgmaterial.shader = cone.shader_file
			var uniforms: Array = self.material.shader.get_shader_uniform_list()
			for uniform in uniforms:
				if uniform.name.to_snake_case() in properties:
					bgmaterial.set_shader_parameter(uniform.name, cone.get(uniform.name.to_snake_case()))
			
		else:
			print_rich("[color=red][b]Shadertype not recognized[/b][/color]")
		
		print_rich("[color=green][b]Shader Config loaded successfully![/b][/color]")
	else:
		print_rich("[color=red][b]Shader could not be loaded.[/b][/color]")
		

func bgshader_export():
	# Use SubViewport to grab Shader Preview
	var subviewport: SubViewport
	var image: Image
	
	var export_shader: String = "res://params/bg_" + bg_type + "_" + bg_index + ".tres"
	var export_preview: String = "res://screenshots/bg_" + bg_type + "_" + bg_index + ".png"
	

	var shader_path: String = self.material.shader.get_path()
	var bgmaterial: ShaderMaterial = self.material
	var uniforms: Array = self.material.shader.get_shader_uniform_list()
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
					circle.set(uniform.name.to_snake_case(), bgmaterial.get_shader_parameter(uniform.name))
			circle.shader_file = bgmaterial.shader as VisualShader
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
					cone.set(uniform.name.to_snake_case(), bgmaterial.get_shader_parameter(uniform.name))
			cone.shader_file = bgmaterial.shader as VisualShader
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
		subviewport = get_parent().get_viewport()
		image = subviewport.get_texture().get_image()
		image.resize(320,200,Image.INTERPOLATE_TRILINEAR)
		image.save_png(export_preview)
		print_rich("[color=green][b]Screenshot created, please run script again to save the shader.[/b][/color]")
		
	EditorInterface.get_resource_filesystem().scan()
