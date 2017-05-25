#version 330 core

out vec2 vertTexCoords;

void main(void) {
    vertTexCoords = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
    gl_Position = vec4(vertTexCoords * vec2(2.0, -2.0) + vec2(-1.0, 1.0), 0.0, 1.0);
}