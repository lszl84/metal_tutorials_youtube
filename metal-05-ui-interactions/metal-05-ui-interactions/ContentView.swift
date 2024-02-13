//
//  ContentView.swift
//  metal-05-ui-interactions
//
//  Created by Luke on 2024-02-13.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                MetalView().aspectRatio(1, contentMode: .fit)
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
