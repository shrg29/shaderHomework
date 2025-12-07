shader_type spatial;
render_mode unshaded;

uniform float grid_scale = 3.0;
uniform int octaves : hint_range(1, 8) = 5;
uniform float lacunarity : hint_range(1.0, 4.0) = 3.0;
uniform float gain : hint_range(0.0, 1.0) = 0.5;

vec2 random(vec2 uv){

  uv = vec2( dot(uv, vec2(151.7, 289.3)),
             dot(uv, vec2(317.5, 197.9)));
  return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise2D(vec2 uv){
  uv *= grid_scale;
  vec2 gridIndex = floor(uv);
  vec2 gridFract = fract(uv);

  vec2 blur = smoothstep(0.0, 1.0, gridFract);

  vec2 bl = gridIndex + vec2(0.0, 0.0);
  vec2 br = gridIndex + vec2(1.0, 0.0);
  vec2 tl = gridIndex + vec2(0.0, 1.0);
  vec2 tr = gridIndex + vec2(1.0, 1.0);

  vec2 gradBL = random(bl);
  vec2 gradBR = random(br);
  vec2 gradTL = random(tl);
  vec2 gradTR = random(tr);

  vec2 distToPixelFromBL = gridFract - vec2(0.0, 0.0);
  vec2 distToPixelFromBR = gridFract - vec2(1.0, 0.0);
  vec2 distToPixelFromTL = gridFract - vec2(0.0, 1.0);
  vec2 distToPixelFromTR = gridFract - vec2(1.0, 1.0);

  float dotBL = dot(gradBL, distToPixelFromBL);
  float dotBR = dot(gradBR, distToPixelFromBR);
  float dotTL = dot(gradTL, distToPixelFromTL);
  float dotTR = dot(gradTR, distToPixelFromTR);

  return mix(mix(dotBL, dotBR, blur.x), mix(dotTL, dotTR, blur.x), blur.y);
}

void vertex() {
  COLOR.rgb = vec3(UV, 0.0);
}

float fbm(vec2 uv) {
  float value = 0.0;
  float amplitude = 1.0;
  float frequency = 1.0;

  for (int i = 0; i < octaves; i++) {
    value += noise2D(uv * frequency) * amplitude;
    frequency *= lacunarity;  
    amplitude *= gain;      
  }

  return value;
}

void fragment() {
  float noise_value = fbm(UV);
//emphasizing peaks for volcanic effect
    noise_value = pow(noise_value * 0.9 + 0.5, 2.0);

  vec3 color;
  if (noise_value < 0.3) {
    color = vec3(0.05, 0.05, 0.05);  //dark rock
  } else if (noise_value < 0.5) {
    color = vec3(0.3, 0.05, 0.0);  //glowing rock
  } else if (noise_value < 0.7) {
    color = vec3(0.8, 0.3, 0.0);  //orang-y lava
  } else {
    color = vec3(1.0, 0.8, 0.1);  //molten fire
  }

  ALBEDO = color;
}

