//precision mediump float;

//uniform vec4 uColor;

varying lowp vec2 TexCoordOut; // New
uniform sampler2D Texture; // New

varying lowp vec4 DestinationColor;

void main() {
    gl_FragColor = DestinationColor * texture2D(Texture, TexCoordOut); // New
}