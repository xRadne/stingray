precision highp float;
varying vec3 rayTarget;
uniform vec4 sphere;

float SDF_sphere(vec3 p, vec4 sphere) {
  return length(p - sphere.xyz) - sphere.w;
}

vec3 normal_sphere(vec3 p, vec4 sphere) {
  return sphere.xyz - p;
}

vec3 march(vec3 rayOrigin, vec3 rayDirection, vec4 sphere) {
  //int maxSteps = 20;
  float t = 0.;
  float minDist = 0.001;
  float d;
  for(int i = 0; i <= 20; i++) {
    d = SDF_sphere(rayOrigin + t * rayDirection, sphere);
    if (d < minDist) {
      break;
    }
    t += d;
  }
  return rayOrigin + t * rayDirection;
}

void main() {
  vec3 rayOrigin = vec3(0., 0., -6.);
  vec3 rayDirection = normalize(rayTarget - rayOrigin);

  vec3 hit = march(rayOrigin, rayDirection, sphere);
  vec3 normal = normal_sphere(hit, sphere);

  gl_FragColor = vec4(hit.x, hit.y, hit.z, 1.0);
}