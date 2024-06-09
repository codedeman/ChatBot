// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct HomeCardView: View {

    @ObservedObject var viewModel = CardViewModel()
    @State private var cardOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    public init() {
        
    }
    public var body: some View {
        VStack {
            ZStack {
                ForEach(viewModel.profiles) { profile in
                    CardView(profile: profile)
                        .offset(
                            x: cardOffset.width,
                            y: cardOffset.height
                        )
                        .rotationEffect(.degrees(cardRotation))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    cardOffset = gesture.translation
                                    cardRotation = Double(gesture.translation.width / 10)
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        if abs(cardOffset.width) > 100 {
                                            if cardOffset.width > 0 {
                                                print("Swipe rigt ")
                                            } else {
                                                print("Swipe left")
                                            }
                                            // Remove the swiped card
                                            viewModel.profiles.removeAll { $0.id == profile.id }
                                        }
                                        // Reset the offset and rotation for the next card
                                        cardOffset = .zero
                                        cardRotation = 0
                                    }
                                }
                        )
                        .animation(.spring(), value: cardOffset)
                }
            }.padding(.bottom, 16)
            Spacer()
        }
    }

}
