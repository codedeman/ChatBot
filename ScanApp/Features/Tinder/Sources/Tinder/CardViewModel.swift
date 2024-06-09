import SwiftUI
import Combine

final class CardViewModel: ObservableObject {
    @Published var profiles: [UserProfile] = []
    private var cancellable: AnyCancellable?

    init() {
        fetchProfiles()
    }

    func fetchProfiles() {
        guard let url = URL(string: "https://codedeman.github.io/ssd_api/tinder.json") else {
            print("Invalid URL")
            return
        }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [UserProfile].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching profiles: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] profiles in
                self?.profiles = profiles
            })
    }
}
