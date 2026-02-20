precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    // Calculate luminosity using the BT.709 standard coefficients
    float lum = dot(pixColor.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec4 outCol = vec4(vec3(lum), pixColor.a);
    gl_FragColor = outCol;
}
