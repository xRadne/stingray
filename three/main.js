var scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 0.1, 1000 );

var canvas = document.getElementById('canvas')
var renderer = new THREE.WebGLRenderer({canvas: canvas});

// renderer.setSize( window.innerWidth, window.innerHeight );

var geometry = new THREE.BoxGeometry( 1, 1, 1 );

// var material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
let uniforms = {
  colorA: {type: 'vec3', value: new THREE.Color(0xff0000)},
  colorB: {type: 'vec3', value: new THREE.Color(0x0000ff)}
}

var material = new THREE.ShaderMaterial(
  {
    uniforms: uniforms,
    vertexShader: vertexShader,
    fragmentShader: fragmentShader
  }
)
var cube = new THREE.Mesh( geometry, material );
scene.add( cube );
// sceneObjects.push(cube);

camera.position.z = 5;
let iteration = 0;
var animate = function () {
  requestAnimationFrame( animate );

  iteration++;
  uniforms.colorA.value = new THREE.Color(1, Math.cos(iteration * Math.PI / 100)/2 + 0.5, 0)
  cube.rotation.x += 0.01;
  cube.rotation.y += 0.01;
  
  if (resizeRendererToDisplaySize(renderer)) {
    const canvas = renderer.domElement;
    camera.aspect = canvas.clientWidth / canvas.clientHeight;
    camera.updateProjectionMatrix();
  }

  renderer.render( scene, camera );
};

function resizeRendererToDisplaySize(renderer) {
  const canvas = renderer.domElement;
  const width = canvas.clientWidth;
  const height = canvas.clientHeight;
  const needResize = canvas.width !== width || canvas.height !== height;
  if (needResize) {
    renderer.setSize(width, height, false);
  }
  return needResize;
}

animate();