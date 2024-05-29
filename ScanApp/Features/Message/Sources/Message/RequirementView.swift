//
//  RequirementView.swift
//  
//
//  Created by Kevin on 4/27/24.
//

import SwiftUI
import CAtomic
import PDFKit
import UniformTypeIdentifiers
import CoreUI

public struct RequirementView: View {
    @State private var documentPickerDelegate: DocumentPickerDelegate?
    @State private var resumURL: URL?
    @State private var requiermentURL: URL?
    @State private var selectedDate: Date? = Date() // Initializing with the current date

    public init () { }
    public var body: some View {
        CalendarView(selectedDate: $selectedDate)
                  .edgesIgnoringSafeArea(.all) // Makes the CalendarView occupy the full screen
                  .navigationBarTitle("", displayMode: .inline) // Optional: Removes the default navigation bar title space
                  .navigationBarHidden(true) // Op

    }
//    public var body: some View {
//        VStack(alignment: .leading, spacing: 16){
//            Text ("your requirement ")
//                .font(.callout)
//            Button  {
//                openFile(fileURLBinding: $requiermentURL)
//            } label: {
//                HStack {
//                    if let fileURL = requiermentURL?.lastPathComponent {
//                        Text(fileURL)
//                    } else {
//                        Spacer()
//                        Image(systemName: "square.and.arrow.up.circle")
//                        Spacer()
//                    }
//                }.frame(height: 50)
//                    .frame(maxWidth: .infinity)
//                .background(Color.white)
//                .clipShape(
//                    RoundedRectangle(cornerRadius: 10)
//                )
//                .shadow(
//                    color: Color.black.opacity(0.3),
//                    radius: 5, x: 0, y: 5
//                )
//            }
//            Text ("your resume ")
//                .font(.callout)
//
//            Button {
//                openFile(fileURLBinding: $resumURL)
//            } label: {
//
//                HStack {
//                    if let fileURL = resumURL?.lastPathComponent {
//                        Spacer()
//                        Text(fileURL)
//                        Spacer()
//                    } else {
//                        Spacer()
//                        Image(systemName: "square.and.arrow.up.circle")
//                        Spacer()
//                    }
//
//                }.frame(height: 50)
//                .frame(maxWidth: .infinity)
//                .background(Color.white)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .shadow(
//                    color: Color.black.opacity(0.3),
//                    radius: 5, x: 0, y: 5
//                )
//
//            }
//
//            HStack {
//                Button {
//
//                } label: {
//                    Text("Review Process")
//                        .tint(Color.white)
//                }.background(Color.red)
//                    .frame(height: 400)
//
//            }.frame(
//                maxWidth: .infinity
//            )
//            .frame(height: 100)
//            .background(Color.blue)
//
//
//        }.padding(.horizontal, 16)
//    }

    private func openFile(fileURLBinding: Binding<URL?>) {

        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data])
        documentPicker.allowsMultipleSelection = false
        documentPickerDelegate = DocumentPickerDelegate(fileURL: fileURLBinding)
        documentPicker.delegate = documentPickerDelegate

        // Present the document picker
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }

}

struct RequirementView_Previews: PreviewProvider {
    static var previews: some View {
        RequirementView()
    }
}


