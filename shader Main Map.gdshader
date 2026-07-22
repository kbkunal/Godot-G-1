shader_type spatial;
render_mode specular_schlick_ggx, diffuse_burley;

/* Height controls */
uniform float sand_height  = 0.15;
uniform float grass_height = 0.35;
uniform float rock_height  = 0.65;
uniform float snow_height  = 0.85;

uniform float blend_softness = 0.08;
uniform float slope_strength = 1.5;

/* HTerrain provided textures */
uniform sampler2D u_ground_albedo : source_color;

varying float world_height;

void vertex() {
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_height = world_pos.y;
}

void fragment() {
    vec3 base_color = texture(u_ground_albedo, UV).rgb;

    float height = world_height;
    float slope = clamp(1.0 - NORMAL.y, 0.0, 1.0);
    slope = pow(slope, slope_strength);

    /* Height masks */
    float sand_m  = 1.0 - smoothstep(sand_height, sand_height + blend_softness, height);
    float grass_m = smoothstep(sand_height, grass_height, height)
                  * (1.0 - smoothstep(grass_height, grass_height + blend_softness, height));
    float rock_m  = smoothstep(grass_height, rock_height, height)
                  * (1.0 - smoothstep(rock_height, rock_height + blend_softness, height));
    float snow_m  = smoothstep(rock_height, snow_height, height);

    rock_m += slope * 1.2;
    grass_m *= (1.0 - slope);

    float total = sand_m + grass_m + rock_m + snow_m;
    sand_m  /= total;
    grass_m /= total;
    rock_m  /= total;
    snow_m  /= total;

    /* Subtle tinting instead of replacing textures */
    vec3 sand_tint  = vec3(1.05, 1.02, 0.95);
    vec3 grass_tint = vec3(0.95, 1.05, 0.95);
    vec3 rock_tint  = vec3(0.9, 0.9, 0.9);
    vec3 snow_tint  = vec3(1.1);

    ALBEDO =
        base_color *
        (sand_tint  * sand_m +
         grass_tint * grass_m +
         rock_tint  * rock_m +
         snow_tint  * snow_m);

    ROUGHNESS =
        sand_m  * 0.9 +
        grass_m * 0.75 +
        rock_m  * 0.55 +
        snow_m  * 0.65;

    SPECULAR = 0.2;
}
