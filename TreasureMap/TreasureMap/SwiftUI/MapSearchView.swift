import SwiftUI
import MapKit

struct MapSearchView: View {
    @State private var annotations = [MKPointAnnotation]()
    var body: some View {
        ZStack(alignment: .top) {
            MapViewContainer(annotations: annotations)
                .ignoresSafeArea()
            HStack {
                Button(action: {
                    performLocalSearch("sushi")
                }) {
                    Text("Search for Airports")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                }
                Button(action: {
                    annotations = []
                }) {
                    Text("Search for Airports")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                }
            }
            .shadow(radius: 3)
            .padding()
        }
    }
    
    fileprivate func performLocalSearch(_ text: String) {
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
            annotations = airports
        }
    }
}

struct MapSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchView()
    }
}
