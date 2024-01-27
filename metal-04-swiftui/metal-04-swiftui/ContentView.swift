//
//  ContentView.swift
//  metal-04-swiftui
//
//  Created by Luke on 2024-01-26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            MetalView().aspectRatio(1, contentMode: .fit)
        }
    }
}

#Preview {
    ContentView()
}
