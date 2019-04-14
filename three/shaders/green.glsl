uniform vec3 colorA; 
uniform vec3 colorB; 
varying vec3 vUv;

void main() {
  gl_FragColor = vec4(mix(colorA, vec3(0.0, 1.0, 0.0), vUv.z + 0.5), 1.0);
}