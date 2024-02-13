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
    
    private func makeMetalView() -> MTKView {
        let view = MTKView()
        
        view.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        view.device = renderer.device
        view.delegate = renderer
        
        return view
    }
}
#if os(iOS)
extension MetalView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIView {
        makeMetalView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}
#elseif os(macOS)
extension MetalView: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView {
        makeMetalView()
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
}
#endif
