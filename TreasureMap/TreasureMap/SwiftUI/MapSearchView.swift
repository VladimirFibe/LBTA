import SwiftUI
import MapKit

struct MapViewContainer: UIViewRepresentable {
    let mapView = MKMapView()
    func makeUIView(context: Context) -> MKMapView {
        setupRegionForMap()
        return mapView
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    fileprivate func setupRegionForMap() {
        let coordinateSanFrancisco = CLLocationCoordinate2D(latitude: 37.766610, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinateSanFrancisco, span: span)
        mapView.setRegion(region, animated: true)
    }
}
struct MapSearchView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    var body: some View {
        ZStack(alignment: .top) {
            MapViewContainer()
                .ignoresSafeArea()
            HStack {
                Button(action: {}) {
                    Text("Search for Airports")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                }
                Button(action: {}) {
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
}

struct MapSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchView()
    }
}
