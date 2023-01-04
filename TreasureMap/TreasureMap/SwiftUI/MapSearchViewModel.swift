import SwiftUI
import MapKit
import Combine

final class MapSearchViewModel: ObservableObject {
    @Published var annotations: [MKPointAnnotation] = []
    @Published var isSearching = false
    @Published var searchQuery = ""
    
    private var bag = Set<AnyCancellable>()
    
    init() {
        $searchQuery
//            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink {[weak self] searchTerm in
                guard let self = self else { return }
                self.performLocalSearch(searchTerm)
            }
            .store(in: &bag)
    }
    func removeLocations() {
        annotations = []
    }
    
    func performLocalSearch(_ text: String) {
        guard !text.isEmpty else {return}
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        let localSearch = MKLocalSearch(request: request)
        isSearching = true
        localSearch.start { response, error in
            if let error = error {
                self.isSearching = false
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            var airports = [MKPointAnnotation]()
            response?.mapItems.forEach({ mapItem in
                let annotation = CustomMapItemAnnotation()
                annotation.mapItem = mapItem
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = "Location: " + (mapItem.name ?? "")
                annotation.subtitle = mapItem.address
                airports.append(annotation)
            })
            self.annotations = airports
            self.isSearching = false
        }
    }
}
