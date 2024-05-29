//
//  MessageRowView.swift
//  ScanApp
//
//  Created by Kevin on 4/16/24.
//

import SwiftUI
import CoreUI 
import Markdown

struct MessageRowView: View {
    let message: MessageRow
    let retryCallback: (MessageRow) -> Void
    @Environment(\.colorScheme) private var colorScheme

    var imageSize: CGSize {
        CGSize(width: 25, height: 25)
    }

    var body: some View {
        VStack(spacing: 0) {
            messageRow(
                rowType: message.send,
                image: message.sendImage,
                bgColor: colorScheme == .light ? .white : Color(red: 52/255, green: 53/255, blue: 65/255, opacity: 0.5)
            )

            if let response = message.response {
                Divider()
                messageRow(
                    rowType: response,
                    image: message.responseImage,
                    bgColor: colorScheme == .light ? .gray.opacity(0.1) : Color(red: 52/255, green: 53/255, blue: 65/255, opacity: 1), responseError: message.responseError, showDotLoading: message.isInteracting
                )
                Divider()
            }
        }
    }

    func messageRow(
        rowType: MessageRowType,
        image: String,
        bgColor: Color,
        responseError: String? = nil,
        showDotLoading: Bool = false
    ) -> some View {

        HStack(alignment: .top, spacing: 24) {
            messageRowContent(
                rowType: rowType,
                image: image,
                responseError: responseError,
                showDotLoading: showDotLoading
            )
        }.padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(bgColor)
    }

    @ViewBuilder
    func messageRowContent(
        rowType: MessageRowType,
                           image: String,
                           responseError: String? = nil,
                           showDotLoading: Bool = false
    ) -> some View {
        if image.hasPrefix("http"), let url = URL(string: image) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .frame(
                        width: imageSize.width,
                           height: imageSize.height
                    )
            } placeholder: {
                ProgressView()
            }

        } else {
            Image(.init(name: image, bundle: Bundle.module))
                .resizable()
                .frame(width: imageSize.width, height: imageSize.height)
        }

        VStack(alignment: .leading) {
            switch rowType {
            case .attributed(let attributedOutput):
                attributedView(results: attributedOutput.results)

            case .rawText(let text):
                if !text.isEmpty {
                    Text(text)
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)
                }
            }

            if let error = responseError {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)

                Button("Regenerate response") {
                    retryCallback(message)
                }
                .foregroundColor(.accentColor)
                .padding(.top)
            }

            if showDotLoading {
                DotLoadingView()
                    .frame(width: 60, height: 30)

            }
        }
    }

    func attributedView(results: [ParserResult]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(results) { parsed in
                    Text(parsed.attributedString)
                        .textSelection(.enabled)
            }
        }
    }
}

//MARK: Preview
struct MessageRowView_Previews: PreviewProvider {

    static let message = MessageRow(
            isInteracting: true, sendImage: "profile",
            send: .rawText("What is SwiftUI?"),
            responseImage: "openai",
            response: nil)
    
    static let message2 = MessageRow(
         isInteracting: false, sendImage: "profile",
         send: .rawText("What is SwiftUI?"),
         responseImage: "openai",
         response: .rawText(""),
         responseError: "ChatGPT is currently not available")
    static var previews: some View {
        NavigationStack {
            ScrollView {
                MessageRowView(message: message, retryCallback: { messageRow in

                })

                MessageRowView(message: message2, retryCallback: { messageRow in

                })

            }
            .previewLayout(.sizeThatFits)
        }
    }
}


public protocol NameableAsset: RawRepresentable where RawValue == String {
    var namespace: String? { get }
}

// NOTE: by default, there is no namespacing
public extension NameableAsset where RawValue == String {
    var namespace: String? { nil }
}


