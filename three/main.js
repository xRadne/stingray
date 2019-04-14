var scene = new THREE.Scene();
var camera = new THREE.PerspectiveCamera( 75, window.innerWidth/window.innerHeight, 0.1, 1000 );

var canvas = document.getElementById('canvas')
var renderer = new THREE.WebGLRenderer({canvas: canvas});

var gui = new dat.GUI();
var fragmentUrl = '';
availableFragmantUrls = { 
  Red: './shaders/red.glsl',
  Green: './shaders/green.glsl',
  Blue: './shaders/blue.glsl',
}
var urlSelector = gui.add(this, 'fragmentUrl', availableFragmantUrls)
urlSelector.onFinishChange((url) => updateShader(url));

function loadFragmentShader( fragmentUrl, callback ) {
  var req = new XMLHttpRequest();
  req.open( "GET", fragmentUrl );
  req.onload = function (e) {
    callback( e.target.responseText );
  };
  req.send();
  return req;
}

function createShader( fs ){
  var material = new THREE.ShaderMaterial({
      uniforms :{
          randomSeed:{ type:"f", value:Math.random() },
          fov:{ type:"f", value:45 },
          camera:{ type:"v3", value: camera.position },
      },
      vertexShader : "void main() {gl_Position =  vec4( position, 1.0 );}",
      fragmentShader : fs,
      transparent:true
  });

  return material;
}

var geometry = new THREE.BoxGeometry( 1, 1, 1 );

let uniforms = {
  colorA: {type: 'vec3', value: new THREE.Color(0xff0000)},
  colorB: {type: 'vec3', value: new THREE.Color(0x0000ff)}
}

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

var currentAnimationFrame;

var updateShader = function(fragmentUrl) {
  cancelAnimationFrame(currentAnimationFrame);
  
  while(scene.children.length > 0){ 
    scene.remove(scene.children[0]); 
  }
  
  loadFragmentShader(fragmentUrl, (fragmentShader) => {
    var material = new THREE.ShaderMaterial(
      {
        uniforms: uniforms,
        vertexShader: vertexShader,
        fragmentShader: fragmentShader
      }
    )
    var cube = new THREE.Mesh( geometry, material );
    scene.add( cube );
    
    camera.position.z = 5;
    let iteration = 0;
    var animate = function () {
      currentAnimationFrame = requestAnimationFrame( animate );
    
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
  
    animate();
  })
}