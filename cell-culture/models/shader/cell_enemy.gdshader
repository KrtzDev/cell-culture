shader_type spatial;

uniform vec4 Color : hint_color;
uniform float strength = 1;
uniform float Roughness = 0.17;



void fragment() 
{	
	float alpha = Color.a;
	vec2 offset = SCREEN_UV;
	float xNorm = NORMAL.x;
	float yNorm = NORMAL.y;
	offset.x += NORMAL.z * xNorm * strength * 0.01;
	offset.y += NORMAL.z * yNorm * strength * -0.01;

	ALBEDO = (texture(SCREEN_TEXTURE, offset).xyz * (1.0 - Color.a)) + (Color.xyz * Color.a);
	ALPHA = alpha;
	ROUGHNESS = Roughness;
}

vec4 mod289(vec4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
    return mod289(((x * 34.0) + 1.0) * x);
}

vec4 taylorInvSqrt(vec4 r) {
    return 1.79284291400159 - 0.85373472095314 * r;
}

vec2 fade(vec2 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float pnoise(vec2 P, vec2 rep) {
    vec4 Pi = floor(vec4(P, P)) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(vec4(P, P)) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod(Pi, vec4(rep, rep)); // To create noise with explicit period
    Pi = mod289(Pi); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;
    
    vec4 i = permute(permute(ix) + iy);
    
    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    vec4 gy = abs(gx) - 0.5 ;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
    
    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);
    
    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;

    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
    
    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

float fbm(vec2 x) 
{
  float height = 0.0;
  float amplitude = 0.00001;
  float frequency = TIME/6.0;
  for (int i = 0; i < 6; i++){
    height += pnoise(x * frequency,vec2(4, 8))*0.2+0.1*amplitude;
  }
  return height;
}

void vertex()
{
	float height = fbm(VERTEX.xz * 3.0f);
	VERTEX += height * 0.05 * NORMAL;
}