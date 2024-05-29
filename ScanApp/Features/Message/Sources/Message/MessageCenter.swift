//
//  SwiftUIView.swift
//  
//
//  Created by Kevin on 4/16/24.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import Logger
import NetWork
import CoreUI

public struct MessageCenter: View {
    @ObservedObject var vm: MessageViewModel
    @State private var fileURL: URL?
    @State private var documentPickerDelegate: DocumentPickerDelegate?
    @State private var fileContent: String?
    @State private var extractedText: String? // Add this state variable to hold the extracted text
    @State private var showRqView: Bool = false
    @FocusState var isTextFieldFocused: Bool
    @State private var selectedDate: Date? = Date() // Initializing with the current date

    public init(vm: MessageViewModel) {
        self.vm = vm
    }

    public var body: some View {
        NavigationView {
            chatListView
                .navigationBarItems(
                    trailing: NavigationLink(destination: CalendarView(selectedDate: $selectedDate)) {
                        Image(systemName: "ellipsis")
                    }
                )
        }
    }

    var chatListView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.messages) { message in
                            MessageRowView(message: message) { message in
                                Task { @MainActor in
                                    await vm.retry(message: message)
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                }
                Divider()
                bottomView(image: "profile", proxy: proxy)
                Spacer()
            }
            .onChange(of: vm.messages.last?.responseText) { _ in  scrollToBottom(proxy: proxy)
            }
        }
    }

    func bottomView(
        image: String,
        proxy: ScrollViewProxy
    ) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if image.hasPrefix("http"), let url = URL(string: image) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .frame(width: 30, height: 30)
                } placeholder: {
                    ProgressView()
                }

            } else {
                Image(image)
                    .resizable()
                    .frame(
                        width: 30,
                        height: 30
                    )
            }

            TextField("Send message", text: $vm.inputMessage, axis: .vertical)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)
                .disabled(vm.isInteracting)

            if vm.isInteracting {
                Button {
                    vm.cancelStream()
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 30))
                        .symbolRenderingMode(.multicolor)
                        .foregroundColor(.red)
                }

            } else {
                Button {
                    Task { @MainActor in
                        isTextFieldFocused = false
                        scrollToBottom(proxy: proxy)
                        await vm.sendTapped()
                    }
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .rotationEffect(.degrees(45))
                        .font(.system(size: 30))
                }

                .disabled(vm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = vm.messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }

    func extractText(from pdfURL: URL) -> String? {
        guard let pdfDocument = PDFDocument(url: pdfURL) else {
            print("Failed to create PDF document")
            return nil
        }

        var text = ""
        for i in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: i) else { continue }
            guard let pageContent = page.string else { continue }
            text.append(pageContent)
        }

        return text
    }

    private func extractTextIfNeeded(from pdfURL: URL?) {
        guard let pdfURL = pdfURL else { return }
        DispatchQueue.global().async {
            if let text = extractText(from: pdfURL) {
                DispatchQueue.main.async {
                    extractedText = text // Update the state with the extracted text
                    vm.inputMessage = "Can you help me review and give me feeedback for this resume & rewrite a new resume for me\(String(describing: extractedText))"
                    print("text ===>", extractedText ?? "")
                }
            }
        }
    }

}


//struct MessageCenter_Previews: PreviewProvider {
//    static let logger = Logger(label: "")
//
//    static var previews: some View {
//        MessageCenter(
//            vm: MessageViewModel(
//                messageRepository: DBMessageRepository(
//                    apiClientService: NetWorkLayer(
//                        logger: logger
//                    ), responseHandler: {
//
//                        
//                    }
//                )
//            )
//        )
//    }
//}

 




