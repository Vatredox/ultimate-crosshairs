@tool
@icon("res://addons/ultimate_crosshairs/icon.png")
class_name UltimateCrosshairs extends Control

##A control that draws a customizable crosshair to the screen.

enum CrosshairStyle {
	##Displays only a dot.
	DOT_ONLY = 0,
	##Displays lines radiating out from a central point.
	STANDARD = 1,
	##Displays a circle, segmented into multiple arcs.
	SHOTGUN = 2 
}

@export_group("Spacing")
##Spread of crosshairs, in pixels.
##[br]
##[br]This value can be assigned through code directly with [member spread_pixels], or by using [member set_spread_degrees(angle, vertical_fov)].
@export var spread_pixels: float = 50.0:
	get:
		return spread_pixels
	set(value):
		spread_pixels = value
		queue_redraw()
		

@export_group("Style")
##The style of the crosshairs.
@export var style := CrosshairStyle.STANDARD:
	get:
		return style
	set(value):
		style = value
		queue_redraw()

##Should a center dot be drawn?
@export var center_dot: bool = true:
	get:
		return center_dot
	set(value):
		center_dot = value
		queue_redraw()

##Color of the inside of the lines.
@export var foreground_color: Color = Color(1.0, 1.0, 1.0):
	get:
		return foreground_color
	set(value):
		foreground_color = value
		queue_redraw()
		
##Color of the edges of the lines.
@export var outline_color: Color = Color(0.0, 0.0, 0.0):
	get:
		return outline_color
	set(value):
		outline_color = value
		queue_redraw()

##Thickness of the inside of the lines, in pixels.
@export var foreground_thickness: float = 4.0:
	get:
		return foreground_thickness
	set(value):
		foreground_thickness = value
		queue_redraw()

##Thickness of the edges of lines, in pixels.	
@export var outline_thickness: float = 2.0:
	get:
		return outline_thickness
	set(value):
		outline_thickness = value
		queue_redraw()

##Rotation offset percentage. Inspector values snap to allow odd segment counts to be perpendicular with the screen. The actual rotation in degrees depends on the value of [member standard_line_count] or [member shotgun_arc_count].
@export_range(0.00, 0.75, 0.25) var rotation_offset: float = 0.00:
	get:
		return rotation_offset
	set(value):
		rotation_offset = value
		queue_redraw()
		
@export_subgroup("Standard Style")
##How long each line is, in pixels. Requires [member style] to be [enum CrosshairStyle.STANDARD].
@export var standard_line_length: float = 10.0:
	get:
		return standard_line_length
	set(value):
		standard_line_length = value
		queue_redraw()
##The number of lines to draw. Requires [member style] to be [enum CrosshairStyle.STANDARD].
@export_range(1, 99) var standard_line_count: int = 4:
	get:
		return standard_line_count
	set(value):
		standard_line_count = value
		queue_redraw()
		
@export_subgroup("Shotgun Style")
##How long each arc is, in degrees. Requires [member style] to be [enum CrosshairStyle.SHOTGUN].
@export var shotgun_arc_degrees: float = 30.0:
	get:
		return shotgun_arc_degrees
	set(value):
		shotgun_arc_degrees = value
		queue_redraw()
		
##The number of arcs/segments. Requires [member style] to be [enum CrosshairStyle.SHOTGUN].		
@export_range(1, 99) var shotgun_arc_count: int = 4:
	get:
		return shotgun_arc_count
	set(value):
		shotgun_arc_count = value
		queue_redraw()
##The number of segments used when drawing line arcs. Requires [member style] to be [enum CrosshairStyle.SHOTGUN].
@export_range(1, 99) var shotgun_arc_detail: int = 8:
	get:
		return shotgun_arc_detail
	set(value):
		shotgun_arc_detail = value
		queue_redraw()

##Sets [member spread_pixels] so that the crosshair aligns with an imaginary cone of [param angle] degrees.
##[br]
##[br]Only perfectly accurate if the crosshair is placed at the center of the screen.
##[br]
##[br][param vertical_fov] should be the [member fov] property of the [Camera3D] used to render your game.
func set_spread_degrees(angle: float, vertical_fov: float) -> void:
	spread_pixels = _cone_angle_to_spread_pixels(angle, vertical_fov)

func _draw() -> void:
	var distanceToCenter: float = spread_pixels / 2.0
	var lineOffset: float = 0.0
	var bgThickness: float = foreground_thickness + (outline_thickness * 2.0)

	if style == CrosshairStyle.DOT_ONLY:
		draw_circle(Vector2.ZERO, bgThickness / 2.0, outline_color)
		draw_circle(Vector2.ZERO, foreground_thickness / 2.0, foreground_color)
	
	elif style == CrosshairStyle.STANDARD:
		var rotation_between_segments: float = 360.0 / standard_line_count
		for i in range(standard_line_count):
			draw_set_transform(Vector2.ZERO, deg_to_rad((i + rotation_offset) * (rotation_between_segments)))
			_draw_rounded_line(Vector2(0.0, distanceToCenter + lineOffset), Vector2(0.0, distanceToCenter + lineOffset + standard_line_length), outline_color, bgThickness, false)
			if(center_dot):
				draw_circle(Vector2.ZERO, bgThickness / 2.0, outline_color)
		for i in range(standard_line_count):
			draw_set_transform(Vector2.ZERO, deg_to_rad((i + rotation_offset) * (rotation_between_segments)))
			_draw_rounded_line(Vector2(0.0, distanceToCenter + lineOffset), Vector2(0.0, distanceToCenter + lineOffset + standard_line_length), foreground_color, foreground_thickness, false)
			if(center_dot):
				draw_circle(Vector2.ZERO, foreground_thickness / 2.0, foreground_color)
	
	elif style == CrosshairStyle.SHOTGUN:
		var rotation_between_segments: float = 360.0 / shotgun_arc_count
		for i in range(shotgun_arc_count):
			draw_set_transform(Vector2.ZERO, deg_to_rad(90.0 + (i + rotation_offset) * (rotation_between_segments)))
			var halfArcAngle: float = deg_to_rad(shotgun_arc_degrees) / 2.0
			_draw_rounded_arc(Vector2.ZERO, distanceToCenter + lineOffset, -halfArcAngle, halfArcAngle, shotgun_arc_detail + 1, outline_color, bgThickness, false)
			if(center_dot):
				draw_circle(Vector2.ZERO, bgThickness / 2.0, outline_color)
		for i in range(shotgun_arc_count):
			draw_set_transform(Vector2.ZERO, deg_to_rad(90.0 + (i + rotation_offset) * (rotation_between_segments)))
			var halfArcAngle: float = deg_to_rad(shotgun_arc_degrees) / 2.0
			_draw_rounded_arc(Vector2.ZERO, distanceToCenter + lineOffset, -halfArcAngle, halfArcAngle, shotgun_arc_detail + 1, foreground_color, foreground_thickness, false)
			if(center_dot):
				draw_circle(Vector2.ZERO, foreground_thickness / 2.0, foreground_color)


func _cone_angle_to_spread_pixels(angle_deg: float, vertical_fov: float) -> float:
	var cone_ang = angle_deg
	
	var viewportY = 540.0
	if(is_inside_tree()):
		viewportY = get_viewport_rect().size.y * 0.5
	var camFov = vertical_fov * 0.5
		
	return 2.0 * (viewportY * tan(deg_to_rad(cone_ang * 0.5))) / tan(deg_to_rad(camFov))


func _spread_pixels_to_cone_angle(px_spread: float, vertical_fov) -> float:
	var px = px_spread * 0.5
	
	var viewportY = 540.0
	if(is_inside_tree()):
		viewportY = get_viewport_rect().size.y * 0.5
	var camFov = vertical_fov * 0.5

	return 2.0 * rad_to_deg(atan(px * tan(deg_to_rad(camFov)) / viewportY))
	
func _draw_rounded_line(from: Vector2, to: Vector2, color: Color, thickness: float, aa: bool = false) -> void:
	draw_circle(from, thickness / 2.0, color)
	draw_circle(to, thickness / 2.0, color)
	draw_line(from, to, color, thickness, aa)

func _draw_rounded_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float, aa: bool = false) -> void:
	var start_position := Vector2(0.0, radius).rotated(start_angle - deg_to_rad(90.0))
	var end_position := Vector2(0.0, radius).rotated(-start_angle - deg_to_rad(90.0))
	
	draw_circle(start_position, width / 2.0, color)
	draw_circle(end_position, width / 2.0, color)
	
	draw_arc(center, radius, start_angle, end_angle, point_count, color, width, aa)
