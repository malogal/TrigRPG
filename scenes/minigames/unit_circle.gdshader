shader_type canvas_item;


void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (tex_color.g > 0.3 && tex_color.g < 0.4) { // This condition may need tweaking
        COLOR.g = 0.0;
		COLOR.b = 0.9;
    } else {
        COLOR = tex_color;
    }
}

