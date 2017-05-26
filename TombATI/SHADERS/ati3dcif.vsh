#version 330 core

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inTexCoords;
layout(location = 2) in vec4 inColor;

uniform mat4 matProjection;
uniform mat4 matModelView;

out vec4 vertColor;
flat out vec4 vertColorFlat;
out vec3 vertTexCoords;

void main(void) {
    gl_Position = matProjection * matModelView * vec4(inPosition, 1);
    
    // normalize colors
    vertColor = inColor / 255.0;
    vertColorFlat = vertColor;
    
    vertTexCoords = inTexCoords;
}