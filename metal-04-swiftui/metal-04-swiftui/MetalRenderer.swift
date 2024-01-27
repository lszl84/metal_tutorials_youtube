//
//  MetalRenderer.swift
//  metal-04-swiftui
//
//  Created by Luke on 2024-01-27.
//

import MetalKit

class MetalRenderer: NSObject, MTKViewDelegate {
    
    let vertexBuffer: MTLBuffer
    let pipelineState: MTLRenderPipelineState
    let commandQueue: MTLCommandQueue
    let device: MTLDevice
    
    let vertices: [Vertex] = [
        Vertex(position2d: [0, 1], colorRgb: [0, 0, 1]),
        Vertex(position2d: [-1, -1], colorRgb: [1, 1, 1]),
        Vertex(position2d: [1, -1], colorRgb: [1, 0, 0])]
    
    override init() {
        device = MetalRenderer.createMetalDevice()
        commandQueue = MetalRenderer.createCommandQueue(with: device)
        vertexBuffer = MetalRenderer.createVertexBuffer(for: device, containing: vertices)
        
        let descriptor = Vertex.buildDefaultVertexDescriptor()
        let library = MetalRenderer.createDefaultMetalLibrary(with: device)
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_main")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
        pipelineDescriptor.vertexDescriptor = descriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = MetalRenderer.createPipelineState(with: device, from: pipelineDescriptor)
        
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        if let drawable = view.currentDrawable,
           let renderPassDescriptor = view.currentRenderPassDescriptor {
            
            guard let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                fatalError("Could not set up objects for render encoding")
            }
            
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            
            renderEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
    
    private static func createMetalDevice() -> MTLDevice {
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("No GPU?")
        }
        
        return defaultDevice
    }
    
    private static func createCommandQueue(with device: MTLDevice) -> MTLCommandQueue {
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create the command queue")
        }
        
        return commandQueue
    }
    
    private static func createVertexBuffer(for device: MTLDevice, containing data: [Vertex]) -> MTLBuffer {
        guard let buffer = device.makeBuffer(bytes: data,
                                             length: MemoryLayout<Vertex>.stride * data.count,
                                             options: []) else {
            fatalError("Could not create the vertex buffer")
        }
        
        return buffer
    }
    
    private static func createDefaultMetalLibrary(with device: MTLDevice) -> MTLLibrary {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("No .metal files in the Xcode project")
        }
        
        return library
    }
    
    private static func createPipelineState(with device: MTLDevice, from descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState {
        do {
            return try device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            fatalError("Could not create the pipeline state: \(error.localizedDescription)")
        }
    }
    
}
