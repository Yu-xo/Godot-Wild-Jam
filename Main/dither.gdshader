shader_type canvas_item;

uniform sampler2D u_dither_tex : repeat_enable; // Dither texture
uniform float u_contrast;        // Contrast adjustment
uniform float u_offset;          // Brightness offset
uniform int u_dither_size;       // Dither pixel size

void fragment()
{
    // Sample the screen texture at the desired output resolution (according to u_dither_size)
    vec2 screen_size = vec2(textureSize(TEXTURE, 0)) / float(u_dither_size);
    vec2 screen_sample_uv = floor(UV * screen_size) / screen_size;
    vec3 screen_col = texture(TEXTURE, screen_sample_uv).rgb;

    // Calculate pixel luminosity
    float lum = (screen_col.r * 0.299) + (screen_col.g * 0.587) + (screen_col.b * 0.114);

    // Adjust with contrast and offset parameters
    lum = (lum - 0.5 + u_offset) * u_contrast + 0.5;
    lum = clamp(lum, 0.0, 1.0);

    // Map the dither texture onto the screen
    ivec2 noise_size = textureSize(u_dither_tex, 0);
    vec2 inv_noise_size = vec2(1.0 / float(noise_size.x), 1.0 / float(noise_size.y));
    vec2 noise_uv = UV * inv_noise_size * vec2(float(screen_size.x), float(screen_size.y));
    float threshold = texture(u_dither_tex, noise_uv).r;

    // Adjust the dither threshold for better patterns
    threshold = threshold * 0.99 + 0.005;

    // Determine the dithered color based on the luminance and threshold
    vec3 dithered_color;

    // If the luminance is below the threshold, use the original color; otherwise, mix with the original color
    if (lum < threshold) {
        dithered_color = screen_col; // Keep the original color for darker pixels
    } else {
        // Blend with a lighter version of the original color to create variation
        dithered_color = mix(screen_col, screen_col + vec3(0.2), 0.5); // Modify this line to change the light color
    }

    // Return the final color
    COLOR.rgb = dithered_color; // Output color with dithering effect
}