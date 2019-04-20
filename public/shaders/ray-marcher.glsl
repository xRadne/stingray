precision highp float;
varying vec3 rayTarget;
uniform vec4 sphere;

#define MIN_DIST .001
#define MAX_DIST 100.
#define MAX_STEPS 100
#define PI 3.141592

struct BBox {
  vec3 min;
  vec3 max;
};

float SDF_sphere(vec3 p, vec4 sphere) {
  return length(p - sphere.xyz) - sphere.w;
}

float SDF(vec3 p) {
  vec4 sphere2 = sphere + vec4(1.5, 0.0, 0.0, 0.0);
  return min(SDF_sphere(p, sphere), SDF_sphere(p, sphere2));
}

vec3 normal_sphere(vec3 p, vec4 sphere) {
  return normalize(p - sphere.xyz);
}

// vec3 array(vec3 p, BBox mirror) {

// }

vec3 mirror(vec3 p, BBox mirror) {
  vec3 diff = mirror.max - mirror.min;
  // vec3 q =  // Quotient
  // Vec3 r // Remainder
  // p.x = mirror.min.x + mod(p.x, mirror.max.x - mirror.min.x)...
  // ...
  
  return p
  // return acos(cos((mirror.min + p)*PI/diff));
}

vec3 march(vec3 rayOrigin, vec3 rayDirection, vec4 sphere) {
  BBox mirrorBox = BBox(
    vec3(-.5, -.5, -.5), 
    vec3(1., .5, 5.));
  
  float t = 0.;
  float d;
  vec3 current = rayOrigin;
  for(int i = 0; i <= MAX_STEPS; i++) {
    d = SDF(current);
    if (d < MIN_DIST) return current;
    if (d > MAX_DIST) return vec3(0., 0., 0.);
    t += d;
    current = rayOrigin + t * rayDirection;
    current = mirror(current, mirrorBox);
  }
  return current;
}

void main() {
  vec3 rayOrigin = vec3(0., 0., -6.); 
  vec3 rayDirection = normalize(rayTarget - rayOrigin);

  vec3 hit = march(rayOrigin, rayDirection, sphere);
  vec3 normal = normal_sphere(hit, sphere);

  // gl_FragColor = vec4(hit.xyz, 1.0);
  gl_FragColor = vec4(normal.xyz, 1.0);
}