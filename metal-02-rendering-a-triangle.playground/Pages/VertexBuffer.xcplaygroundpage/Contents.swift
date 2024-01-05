import PlaygroundSupport
import MetalKit

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("No GPU?")
}

let frame = CGRect(x: 0, y: 0, width: 450, height: 450)
let view = MTKView(frame: frame, device: device)

view.clearColor = MTLClearColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)

let vertices: [Float] = [
    0, 1, 0,
    -1, -1, 0,
    1, -1, 0]


guard let vertexBuffer = device.makeBuffer(bytes: vertices,
                                     length: MemoryLayout<Float>.stride * vertices.count,
                                     options: []) else {
    fatalError("Could not create the vertex buffer")
}

let shaderCode = """
#include <metal_stdlib>
using namespace metal;

vertex float4 vertex_main(constant packed_float3 *pos [[buffer(0)]],
                          uint index [[vertex_id]]) {
    return float4(pos[index], 1.0);
}

fragment float4 fragment_main() {
    return float4(0.0, 0.0, 1.0, 1.0);
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

