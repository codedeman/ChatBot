//
//  ButtonView.swift
//  
//
//  Created by Kevin on 5/3/24.
//

import SwiftUI

public struct ButtonView: View {

    let label: String
    let icon: String
    let action: () -> Void

    public init(
        label: String,
        icon: String? = nil,
        action: @escaping () -> Void

    ) {
        self.label = label
        self.icon = icon ?? ""
        self.action = action

    }

    public var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
            Text(label)
        }
    }

}
