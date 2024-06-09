//
//  ContentView.swift
//  ScanApp
//
//  Created by Kevin on 4/16/24.
//

import SwiftUI
//import Pulse
//import PulseUI
import Message
import Logger
import NetWork
import Logger
import SwiftUI
import Tinder

struct ContentView: View {
    @State private var showConsoleView = false
    @State private var showDestinationView = true

    let mindarg: CGFloat = 100
    let screenWidth = UIScreen.main.bounds.width
    let logger = Logger(label: "🤣")

    var body: some View {
        HomeCardView()
//        MessageCenter(
//            vm: MessageViewModel(
//                messageRepository: DBMessageRepository(
//                    apiClientService: NetWorkLayer(
//                        logger: logger
//                    )
//                )
//            )
//        )
    }
}


#Preview {
    ContentView()
}
