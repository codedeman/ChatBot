//
//  UploadFileView.swift
//  
//
//  Created by Kevin on 4/25/24.
//

import SwiftUI

public struct UploadFileView: View {
    @ObservedObject var vm: MessageViewModel
    var responseText: (String) -> Void
    @Environment(\.dismiss) var dismiss

    public init(
        vm: MessageViewModel,
        responseText: @escaping (String) -> Void = {_ in }
    ) {
        self.vm = vm
        self.responseText = responseText
    }

    public var body: some View {
        ScrollView {
            ForEach(vm.messagesHelps) { message in
                VStack {
                    Button(action: {
                        responseText(message.responseText ?? "")
                        vm.isShowingTips = false
                        dismiss()
                    }, label: {
                        Text(message.responseText ?? "").tint(Color.white)
                    })
                }
            }
        }.onDisappear(perform: {
            vm.isShowingTips = false
        }).ignoresSafeArea()

    }
}
