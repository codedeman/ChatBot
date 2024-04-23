//
//  HomeView.swift
//  
//
//  Created by Kevin on 4/18/24.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import Intents
import IntentsUI

struct PDFView: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> PDFKit.PDFView {
        let pdfView = PDFKit.PDFView()
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFKit.PDFView, context: Context) {
        uiView.document = PDFDocument(url: url)
    }

}

public struct HomeView: View{
    @State private var fileURL: URL?
    @State private var documentPickerDelegate: DocumentPickerDelegate?
    @State private var fileContent: String?

    public init() { }
    public var body: some View {
        VStack {
            if let content = fileContent {
                Text(content)
                    .padding()
            } else if let fileURL = fileURL {

                PDFView(url: fileURL)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Button("Open File") {
                    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data])
                    documentPicker.allowsMultipleSelection = false
                    documentPickerDelegate = DocumentPickerDelegate(fileURL: $fileURL)
                    documentPicker.delegate = documentPickerDelegate
                    UIApplication
                        .shared
                        .windows
                        .first?
                        .rootViewController?
                        .present(
                        documentPicker,
                        animated: true,
                        completion: nil
                    )
                }
            }
        }.onAppear(perform: {
            requestSiriAuthorization()
            
        })
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

    func requestSiriAuthorization() {
        INPreferences.requestSiriAuthorization { status in
            switch status {
            case .authorized:
                print("Siri authorization granted")
                // Handle authorization granted
            case .denied:
                print("Siri authorization denied")
                // Handle authorization denied
            case .notDetermined:
                print("Siri authorization not determined")
                // Handle authorization not determined (user hasn't responded yet)
            case .restricted:
                print("Siri authorization restricted")
                // Handle authorization restricted (e.g., parental controls)
            @unknown default:
                print("Unknown authorization status")
                // Handle unknown authorization status
            }
        }
        }

}


class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    @Binding var fileURL: URL?

    init(fileURL: Binding<URL?>) {
        _fileURL = fileURL
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            fileURL = url
        }
    }

}
