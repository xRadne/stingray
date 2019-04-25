precision highp float;
varying vec3 rayTarget;
uniform vec4 sphere;

#define MIN_DIST .001
#define MAX_DIST 100.
#define MAX_STEPS 1000
#define MAX_STEP_LENGTH 0.5 
#define EPSILON .000001 
#define PI 3.141592

struct BBox {
  vec3 min;
  vec3 max;
};

float SDF_sphere(vec3 p, vec4 sphere) {
  return length(p - sphere.xyz) - sphere.w;
}

float SDF(vec3 p) {
  return SDF_sphere(p, sphere);
}

vec3 normal_sphere(vec3 p, vec4 sphere) {
  return normalize(p - sphere.xyz);
}

vec3 normal(vec3 point) {
  float pDist = SDF(point);
  float x = SDF(point + vec3(EPSILON, 0., 0.));
  float y = SDF(point + vec3(0., EPSILON, 0.));
  return point;
}

// https://iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
vec3 calcNormal(vec3 p, float eps)
{
  vec2 h = vec2(eps, 0.);
  return normalize(vec3(SDF(p+h.xyy) - SDF(p-h.xyy),
                        SDF(p+h.yxy) - SDF(p-h.yxy),
                        SDF(p+h.yyx) - SDF(p-h.yyx)));
}

vec3 mirror(vec3 point, BBox mirror) {
  vec3 diff = mirror.max - mirror.min;
  vec3 relativeP = point - mirror.min;
  vec3 boundedP = mod(relativeP, (2. * diff));
  return vec3(
    (boundedP.x < diff.x) ? mirror.min.x + boundedP.x : mirror.min.x + boundedP.x - 2. * diff.x,
    (boundedP.y < diff.y) ? mirror.min.y + boundedP.y : mirror.min.y + boundedP.y - 2. * diff.y,
    (boundedP.z < diff.z) ? mirror.min.z + boundedP.z : mirror.min.z + boundedP.z - 2. * diff.z
  );
}

vec3 mirrorRay(vec3 point, vec3 rayDirection, BBox mirror) {
  vec3 diff = mirror.max - mirror.min;
  vec3 relativeP = point - mirror.min;
  vec3 boundedP = mod(relativeP, (2. * diff));
  return vec3(
    (boundedP.x < diff.x) ? rayDirection.x : -rayDirection.x,
    (boundedP.y < diff.y) ? rayDirection.y : -rayDirection.y,
    (boundedP.z < diff.z) ? rayDirection.z : -rayDirection.z
  );
}

vec3 march(vec3 rayOrigin, vec3 rayDirection, vec4 sphere) {
  BBox mirrorBox = BBox(
    vec3(0., -1., -1.), 
    vec3(1.5, 1., 1.));
  
  float t = 0.;
  float d;
  vec3 current = rayOrigin;
  for(int i = 0; i <= MAX_STEPS; i++) {
    d = SDF(current);
    if (d < MIN_DIST) return current;
    if (d > MAX_DIST) return vec3(0., 0., 0.);
    t += (d > MAX_STEP_LENGTH) ? MAX_STEP_LENGTH : d;
    current = rayOrigin + t * rayDirection;
    rayDirection = mirrorRay(current, rayDirection,  mirrorBox);
    current = mirror(current, mirrorBox);    
  }
  return current;
}

void main() {
  vec3 rayOrigin = vec3(0., 0., -6.);
  vec3 rayDirection = normalize(rayTarget - rayOrigin);

  vec3 hit = march(rayOrigin, rayDirection, sphere);
  vec3 normal = calcNormal(hit, EPSILON);

  gl_FragColor = vec4(normal.xyz, 1.0);
}