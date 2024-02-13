//
//  MetalView.swift
//  metal-05-ui-interactions
//
//  Created by Luke on 2024-02-13.
//

import MetalKit
import SwiftUI

struct MetalView {
    
    @State private var renderer: MetalRenderer = MetalRenderer()
    
    @Binding var rotation: Float
    
    private func makeMetalView() -> MTKView {
        let view = MTKView()
        
        view.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        view.device = renderer.device
        view.delegate = renderer
        
        return view
    }
    
    private func updateMetalView() {
        renderer.updateRotation(angle: rotation)
    }
}
#if os(iOS)
extension MetalView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIView {
        makeMetalView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        updateMetalView()
    }
}
#elseif os(macOS)
extension MetalView: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView {
        makeMetalView()
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        updateMetalView()
    }
}
#endif
