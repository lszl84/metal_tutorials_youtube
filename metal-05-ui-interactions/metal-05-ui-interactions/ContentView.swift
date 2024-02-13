//
//  ContentView.swift
//  metal-05-ui-interactions
//
//  Created by Luke on 2024-02-13.
//

import SwiftUI

struct ContentView: View {
    @State private var rotation: Float = 0.0
    
    var body: some View {
            VStack {
                Spacer()
                MetalView().aspectRatio(1, contentMode: .fit)
                Spacer()
            }
    }
}

#Preview {
    ContentView()
}
