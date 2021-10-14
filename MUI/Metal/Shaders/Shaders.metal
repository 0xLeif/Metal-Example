#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
};
struct VertexOut {
  float4 position [[ position ]];
  float4 color;
};
struct ModelConstraints {
  float4x4 modelMatrix;
};

vertex VertexOut basic_vertex_function(VertexIn vIn [[ stage_in ]],
                                       const device VertexIn *vertices [[ buffer(0) ]],
                                       constant ModelConstraints &modelConstants [[ buffer(1) ]],
                                       uint vertexID [[ vertex_id  ]]) {
  VertexOut vOut;
  vOut.position = modelConstants.modelMatrix * float4(vIn.position,1);
  vOut.color = vertices[vertexID].color;
  return vOut;
}
fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]]) {
  return vIn.color;
}
