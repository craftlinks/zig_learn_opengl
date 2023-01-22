#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;

uniform vec3 offset;

out vec3 ourColor;
out vec3 vertPos;

void main()
{
    gl_Position = vec4(aPos * offset, 1.0f);
    ourColor = aColor;
    vertPos = aPos + offset;
}