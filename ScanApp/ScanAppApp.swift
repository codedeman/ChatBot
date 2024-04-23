//
//  ScanAppApp.swift
//  ScanApp
//
//  Created by Kevin on 4/16/24.
//

import SwiftUI
import Message
import Logger
import NetWork
import DashBoard
@main
struct ScanAppApp: App {
    var body: some Scene {
        WindowGroup {
//            HomeView()
            let logger = Logger(label: "")
            MessageCenter(
                vm: MessageViewModel(
                    messageRepository: DBMessageRepository(
                        apiClientService: NetWorkLayer(
                            logger: logger
                        )
                    )
                )
            )
        }
    }
}
