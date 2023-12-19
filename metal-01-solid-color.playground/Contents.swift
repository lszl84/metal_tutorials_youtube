import PlaygroundSupport
import MetalKit

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("No GPU?")
}

// setting up the MetalKit View
let frame = CGRect(x: 0, y: 0, width: 450, height: 450)
let view = MTKView(frame: frame, device: device)

view.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1)

// queue, buffer, and render pass
guard let commandQueue = device.makeCommandQueue(),
      let commandBuffer = commandQueue.makeCommandBuffer() else {
    fatalError("Could not create a command buffer or queue")
}

guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
    fatalError("No default render pass descriptor")
}
let current = renderPassDescriptor.colorAttachments[0].loadAction
print("Current load action: \(current)")
renderPassDescriptor.colorAttachments[0].loadAction = .clear
//renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)

// the rendering commands will go to the encoder
guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
    fatalError("Could not create a render encoder")
}

renderEncoder.endEncoding() // endEncoding() marks the end of the rendering command for the render pass

// selecting the destination to draw to
guard let drawable = view.currentDrawable else {
    fatalError("Cannot select drawing destination")
}

commandBuffer.present(drawable)
commandBuffer.commit() // this sends the commands to the GPU and draws everything

PlaygroundPage.current.liveView = view
