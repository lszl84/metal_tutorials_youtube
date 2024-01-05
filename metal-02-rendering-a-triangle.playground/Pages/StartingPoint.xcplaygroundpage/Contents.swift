import PlaygroundSupport
import MetalKit

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("No GPU?")
}

let frame = CGRect(x: 0, y: 0, width: 450, height: 450)
let view = MTKView(frame: frame, device: device)

view.clearColor = MTLClearColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)

guard let commandQueue = device.makeCommandQueue(),
      let commandBuffer = commandQueue.makeCommandBuffer() else {
    fatalError("Could not create a command buffer or queue")
}

guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
    fatalError("No default render pass descriptor")
}

guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
    fatalError("Could not create a render encoder")
}

renderEncoder.endEncoding()

guard let drawable = view.currentDrawable else {
    fatalError("Cannot select drawing destination")
}

commandBuffer.present(drawable)
commandBuffer.commit()

PlaygroundPage.current.liveView = view
