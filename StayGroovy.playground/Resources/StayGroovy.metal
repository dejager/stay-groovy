#include <metal_stdlib>
using namespace metal;

#define pi 3.141592653589793

float2x2 rotation(float angle) {
  return float2x2(cos(angle), -sin(angle),
                  sin(angle), cos(angle));
}

float random(float2 st) {
  return fract(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
}

float between(float minV, float maxV, float v) {
  return minV + v * (maxV - minV);
}

kernel void keepOnTruckin(texture2d<float, access::write> o[[texture(0)]],
                          constant float &time [[buffer(0)]],
                          constant float2 *touchEvent [[buffer(1)]],
                          constant int &numberOfTouches [[buffer(2)]],
                          ushort2 gid [[thread_position_in_grid]]) {

  // config

  float tiles = 3.0;
  const float2 velocity = float2(1.0, 0.0);
  const float4 pink = float4(200, 54, 96, 255) / 255;
  const float4 blue = float4(0, 88, 255, 255) / 255;

  // colors
  float4 color1 = pink;
  float4 color2 = blue;

  // coordinates
  int width = o.get_width();
  int height = o.get_height();
  float2 res = float2(width, height);
  float2 uv = (float2(gid) * 2.0 - res.xy) / res.y;

  // wave
  float2 wave = uv;
  wave.x += sin(uv.y * 5.0 + time) * 0.1;
  wave.y += cos(uv.x * 5.0 + time) * 0.1;
  uv += wave;

  uv *= rotation(pi / 3.2 * time);
  uv *= float2(between(0.7, 1.5, (1.0 + sin(time)) / 2.0));
  uv += float2(between(5.0, 10.0, time / 1.4));

  float2 index = floor(tiles * uv) / tiles;
  float t = floor(random(index) * 4.0) / 4.0;

  uv = 2.0 * fract(tiles * uv) - 1.0;
  uv *= rotation(t * pi * 2.0);

  float c = step(uv.x, uv.y) * 0.9;
  c = abs(sin(5.0 + fract((random(index + c) + 0.1))));

  float4 color = random(float2(c)) > 0.5 ? color1 : color2;
  color = float4((c * 0.5 + 0.5) * color.xyz, 1.0);

  o.write(color, gid);
}
