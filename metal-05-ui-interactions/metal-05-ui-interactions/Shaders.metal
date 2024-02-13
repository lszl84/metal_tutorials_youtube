#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct FragmentInput {
    float4 position [[position]];
    float4 color;
};

vertex FragmentInput vertex_main(Vertex v [[stage_in]],
                                 constant float4x4 &matrix [[buffer(1)]]) {
    return {
        .position { matrix * v.position },
        .color { v.color }
    };
}

fragment float4 fragment_main(FragmentInput input [[stage_in]]) {
    return input.color;
}

