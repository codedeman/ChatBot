//
//  ContentView.swift
//  ScanApp
//
//  Created by Kevin on 4/16/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        chatView
//        VStack {
//
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
    }

    var chatView: some View {
        ScrollViewReader(content: { proxy in
            Text("Hello Mother fucker ")
        })
    }
}

#Preview {
    ContentView()
}
