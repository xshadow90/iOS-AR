precision mediump float;

uniform mat4 uProjMat;
uniform mat4 uModelViewMat;
uniform mat4 uTransformMat; // for scaling

attribute vec2 TexCoordIn; // New
varying vec2 TexCoordOut; // New

attribute vec4 aPos;

uniform vec4 SourceColor;
varying vec4 DestinationColor;

void main() {
    DestinationColor = SourceColor;
    gl_Position = uProjMat * uModelViewMat * uTransformMat * aPos;
    TexCoordOut = TexCoordIn; // New
}