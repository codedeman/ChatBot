//
//  PDFView.swift
//  
//
//  Created by Kevin on 4/24/24.
//

import PDFKit
import UniformTypeIdentifiers
import SwiftUI

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

