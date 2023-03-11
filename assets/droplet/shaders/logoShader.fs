#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

uniform float alphaMult;
uniform float time;
uniform float percent;

// Output fragment color
out vec4 finalColor;

void main() {
    vec4 color = texture2D(texture0, fragTexCoord) * fragColor;

    float div = 40 + 20 * abs(0.5 - mod(time / 8, 1));

    if (fragTexCoord.y < 1 - (sin(fragTexCoord.x * 40 + time) / div + percent))
        color.r = color.g = color.b = 0.125;

    if (color.a < 1 && color.r + color.g + color.b > 0)
        color *= alphaMult;
    finalColor = color;
}