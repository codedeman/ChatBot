// The MIT License (MIT)
//
// Copyright (c) 2020-2024 Alexander Grebenyuk (github.com/kean).

#if os(iOS) || os(visionOS)

import SwiftUI
import CoreData
import Pulse
import Combine
import WatchConnectivity

public struct SideMenu: View {
    let width: CGFloat
    let isOpen: Bool
    let menuClose: () -> Void

    public init(
        width: CGFloat,
        isOpen: Bool,
        menuClose: @escaping () -> Void
    ) {
        self.width = width
        self.isOpen = isOpen
        self.menuClose = menuClose
    }


    public var body: some View {
        ZStack {
            GeometryReader { _ in
                ConsoleView(environment: .init(store: .demo, mode: .all))
            }
            .background(Color.gray.opacity(0.3))
            .opacity(self.isOpen ? 1.0 : 0.0)
            .animation(Animation.easeIn.delay(0.25))
            .onTapGesture {
                self.menuClose()
            }
        }
    }
}

public struct ConsoleView: View {
    @StateObject private var environment: ConsoleEnvironment // Never reloads
    @Environment(\.presentationMode) private var presentationMode
    private var isCloseButtonHidden = false

     init(environment: ConsoleEnvironment) {
        _environment = StateObject(wrappedValue: environment)
    }

    public var body: some View {
        if #available(iOS 15, *) {
            contents
        } else {
            PlaceholderView(
                imageName: "xmark.octagon",
                title: "Unsupported",
                subtitle: "Pulse requires iOS 15 or later"
            ).padding()
        }
    }
    @available(iOS 15, visionOS 1.0, *)
    private var contents: some View {
        ConsoleListView()
            .navigationTitle(environment.title)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if !isCloseButtonHidden && presentationMode.wrappedValue.isPresented {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    trailingNavigationBarItems
                }
            }.frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .leading
            )
            .background(Color.white)
            .injecting(environment)
    }

    /// Changes the default close button visibility.
    public func closeButtonHidden(_ isHidden: Bool = true) -> ConsoleView {
        var copy = self
        copy.isCloseButtonHidden = isHidden
        return copy
    }

    @available(iOS 15, visionOS 1.0, *)
    @ViewBuilder private var trailingNavigationBarItems: some View {
        Button(action: { environment.router.isShowingShareStore = true }) {
            Image(systemName: "square.and.arrow.up")
        }
        Button(action: { environment.router.isShowingFilters = true }) {
            Image(systemName: "line.horizontal.3.decrease.circle")
        }
        ConsoleContextMenu()
    }
}

#if DEBUG
struct ConsoleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ConsoleView(environment: .init(store: .mock))
            }.previewDisplayName("Console")
            NavigationView {
                ConsoleView(store: .mock, mode: .network)
            }.previewDisplayName("Network")
        }
    }
}
#endif

#endif
