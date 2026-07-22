shader_type spatial;
render_mode unshaded, cull_disabled;

void fragment() {
    if (FRONT_FACING)
        ALBEDO = vec3(0.0, 1.0, 0.0); // green
    else
        ALBEDO = vec3(1.0, 0.0, 0.0); // red
}