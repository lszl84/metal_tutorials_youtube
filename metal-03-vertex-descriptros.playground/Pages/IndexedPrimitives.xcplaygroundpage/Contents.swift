import PlaygroundSupport
import MetalKit

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("No GPU?")
}

let frame = CGRect(x: 0, y: 0, width: 950, height: 950)
let view = MTKView(frame: frame, device: device)

view.clearColor = MTLClearColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)

struct Vertex {
    let x: Float
    let y: Float
    let colorRgb: SIMD3<Float>
}

let vertices: [Vertex] = [
    Vertex(x: -1, y: 1, colorRgb: [0, 0, 1]),
    Vertex(x: -1, y: -1, colorRgb: [1, 1, 1]),
    Vertex(x: 1, y: -1, colorRgb: [1, 0, 0]),
    Vertex(x: 1, y: 1, colorRgb: [0, 0, 0]),
    ]
    
let indices: [UInt16] = [
    0, 1, 2,
    3, 0, 2]

guard let vertexBuffer = device.makeBuffer(bytes: vertices,
                                     length: MemoryLayout<Vertex>.stride * vertices.count,
                                     options: []) else {
    fatalError("Could not create the vertex buffer")
}

guard let indexBuffer = device.makeBuffer(bytes: indices,
                                          length: MemoryLayout<UInt16>.stride * indices.count,
                                          options: []) else {
    fatalError("Could not create the index buffer")
}

let vertexDescriptor = MTLVertexDescriptor()

vertexDescriptor.attributes[0].format = .float2
vertexDescriptor.attributes[0].offset = 0
vertexDescriptor.attributes[0].bufferIndex = 0

vertexDescriptor.attributes[1].format = .float3
vertexDescriptor.attributes[1].offset =  MemoryLayout<Vertex>.offset(of: \.colorRgb)!
vertexDescriptor.attributes[1].bufferIndex = 0

vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride

let shaderCode = """
#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position [[attribute(0)]];
    float3 color [[attribute(1)]];
};

struct FragmentInput {
    float4 position [[position]];
    float4 color;
};

vertex FragmentInput vertex_main(Vertex v [[stage_in]]) {
    return {
        .position { float4(v.position, 1.0, 1.0) },
        .color { float4(v.color, 1.0) }
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
pipelineDescriptor.vertexDescriptor = vertexDescriptor

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
renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount:indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
renderEncoder.endEncoding()

guard let drawable = view.currentDrawable else {
    fatalError("Cannot select drawing destination")
}

commandBuffer.present(drawable)
commandBuffer.commit()

PlaygroundPage.current.liveView = view

