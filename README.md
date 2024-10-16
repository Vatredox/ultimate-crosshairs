# Ultimate Crosshairs
## Dynamic procedural crosshairs for Godot

This addon provides a very simple and customizable way to implement crosshairs in the form of a Control node.

## How to use

- Download the addon and place it in your Godot project
- Add `UltimateCrosshairs.gd` to a Control node in your scene
- Adjust `spread_pixels` to change the size of the crosshairs
  - Alternatively, call `set_spread_degrees(angle, vertical_fov)` to space the crosshairs correctly, given a cone angle.