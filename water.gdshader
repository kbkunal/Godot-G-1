shader_type spatial;

render_mode blend_mix,

cull_disabled,
diffuse_burley,
specular_schlick_ggx;

uniform sampler2D normal_map1 : hint_normal;
uniform sampler2D normal_map2 : hint_normal;

uniform vec4 shallow_color : source_color = vec4(0.20,0.60,0.80,0.45);
uniform vec4 deep_color : source_color = vec4(0.03,0.15,0.30,0.80);

uniform float wave_speed = 0.05;
uniform float wave_scale = 4.0;
uniform float normal_strength = 1.2;

uniform float metallic = 0.0;
uniform float roughness = 0.05;

uniform float fresnel_power = 5.0;
uniform float transparency = 0.6;

uniform float depth_distance = 5.0;

uniform vec4 foam_color : source_color = vec4(1.0);
uniform float foam_strength = 0.8;
uniform float foam_distance = 0.5;

void fragment()
{
    vec2 uv1 = UV * wave_scale + vec2(TIME * wave_speed, 0.0);
    vec2 uv2 = UV * wave_scale * 1.4 - vec2(0.0, TIME * wave_speed * 0.8);

    vec3 n1 = texture(normal_map1, uv1).rgb;
    vec3 n2 = texture(normal_map2, uv2).rgb;

    NORMAL_MAP = mix(n1, n2, 0.5);
    NORMAL_MAP_DEPTH = normal_strength;

    float depth =
        clamp((FRAGCOORD.z / FRAGCOORD.w) / depth_distance,0.0,1.0);

    vec4 water_color =
        mix(shallow_color, deep_color, depth);

    float fresnel =
        pow(1.0 - dot(NORMAL, VIEW), fresnel_power);

    ALBEDO =
        mix(water_color.rgb,
            vec3(1.0),
            fresnel * 0.25);

    METALLIC = metallic;
    ROUGHNESS = roughness;

    ALPHA =
        water_color.a * transparency;

    float foam =
        smoothstep(
            foam_distance,
            0.0,
            depth);

    ALBEDO +=
        foam * foam_strength * foam_color.rgb;
}