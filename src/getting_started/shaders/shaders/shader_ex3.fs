#version 330 core
out vec4 FragColor;
in vec3 ourColor;
in vec3 vertPos;
void main()
{
   FragColor = vec4(vertPos, 1.0);
};
