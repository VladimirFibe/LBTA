import SwiftUI
import MapKit

final class MapSearchViewModel: ObservableObject {
    @Published var annotations: [MKPointAnnotation] = []
    
    func removeLocations() {
        annotations = []
    }
    
    func performLocalSearch(_ text: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { response, error in
            if let error = error {
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
        }
    }
}
