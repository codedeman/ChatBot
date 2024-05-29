//
//  ResponseParsingTask.swift
//  
//
//  Created by Kevin on 4/23/24.
//

import Foundation
import CoreUI
import Markdown

actor ResponseParsingTask {
    func parse(text: String) async -> AttributedOutput {
        let document = Document(parsing: text)
        var markdownParser = MarkdownAttributedStringParser()
        let results = markdownParser.parserResults(from: document)
        return AttributedOutput(string: text, results: results)
    }
}
