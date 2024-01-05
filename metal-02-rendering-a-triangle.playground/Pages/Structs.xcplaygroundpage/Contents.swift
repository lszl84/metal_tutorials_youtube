import PlaygroundSupport
import MetalKit

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("No GPU?")
}

let frame = CGRect(x: 0, y: 0, width: 450, height: 450)
let view = MTKView(frame: frame, device: device)

view.clearColor = MTLClearColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)

struct Vertex {
    let position2d: SIMD2<Float>
    let colorRgb: SIMD3<Float>
}

let vertices: [Vertex] = [
    Vertex(position2d: [0, 1], colorRgb: [0, 0, 1]),
    Vertex(position2d: [-1, -1], colorRgb: [1, 1, 1]),
    Vertex(position2d: [1, -1], colorRgb: [1, 0, 0])]

guard let vertexBuffer = device.makeBuffer(bytes: vertices,
                                     length: MemoryLayout<Vertex>.stride * vertices.count,
                                     options: []) else {
    fatalError("Could not create the vertex buffer")
}

let shaderCode = """
#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position;
    float3 color;
};

struct FragmentInput {
    float4 position [[position]];
    float4 color;
};

vertex FragmentInput vertex_main(constant Vertex* vertices,
                          uint index [[vertex_id]]) {
    return {
        .position { float4(vertices[index].position, 1.0, 1.0) },
        .color { float4(vertices[index].color, 1.0) }
    };
}

fragment float4 fragment_main(FragmentInput input [[stage_in]]) {
    return input.color;
}
"""

let library: MTLLibrary

do {
    try library = device.makeLibrary(source:shaderCode, options:nil)
}
catch let error {
    fatalError ("Could not create Library: \(error)")
}

let vertexFunction = library.makeFunction(name: "vertex_main")
let fragmentFunction = library.makeFunction(name: "fragment_main")

let pipelineDescriptor = MTLRenderPipelineDescriptor()
pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
pipelineDescriptor.vertexFunction = vertexFunction
pipelineDescriptor.fragmentFunction = fragmentFunction

guard let pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
    fatalError("Could not create the pipeline state")
}

guard let commandQueue = device.makeCommandQueue(),
      let commandBuffer = commandQueue.makeCommandBuffer() else {
    fatalError("Could not create a command buffer or a command queue")
}

guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
    fatalError("No default render pass descriptor")
}

guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
    fatalError("Could not create a render encoder")
}

renderEncoder.setRenderPipelineState(pipelineState)
renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

renderEncoder.endEncoding()

guard let drawable = view.currentDrawable else {
    fatalError("Cannot select drawing destination")
}

commandBuffer.present(drawable)
commandBuffer.commit()

PlaygroundPage.current.liveView = view

