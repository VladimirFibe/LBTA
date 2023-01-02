import UIKit
import LBTATools
import MapKit
import SwiftUI

class DirectionsViewController: UIViewController {

    let mapView = MKMapView()
    
    let navBar = UIView(backgroundColor: .blue)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBarUI()
        setupMap()
    }
    
    fileprivate func setupMap() {
        view.addSubview(mapView)
        mapView.anchor(
            top: navBar.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor)
        mapView.delegate = self
        mapView.showsUserLocation = true
        setupRegionForMap()
        setupStartEndDummyAnnotations()
        requestForDirections()
    }
    
    fileprivate func requestForDirections() {
        guard let first = mapView.annotations.first,
        let last = mapView.annotations.last else {return}
        let request = MKDirections.Request()
        
        let startingPlacemark = MKPlacemark(coordinate: first.coordinate)
        request.source = .init(placemark: startingPlacemark)
        
        let endingPlacemark = MKPlacemark(coordinate: last.coordinate)
        request.destination = .init(placemark: endingPlacemark)
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            guard let route = response?.routes.first else { return }
            self.mapView.addOverlay(route.polyline)
            print("DEBUG: Yesss!!!")
        }
    }
    
    fileprivate func setupStartEndDummyAnnotations() {
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = .init(latitude: 37.766610, longitude: -122.427290)
        startAnnotation.title = "Start"
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = .init(latitude: 37.331352, longitude: -122.030331)
        endAnnotation.title = "End"
        mapView.addAnnotation(startAnnotation)
        mapView.addAnnotation(endAnnotation)
        mapView.showAnnotations(self.mapView.annotations, animated: false)
    }
    
    fileprivate func setupNavBarUI() {
        view.addSubview(navBar)
        navBar.anchor(
            top: view.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.topAnchor,
            trailing: view.trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: -50, right: 0)
        )
        navBar.setupShadow(opacity: 0.5, radius: 5)
    }
    
    fileprivate func setupRegionForMap() {
        let coordinateSanFrancisco = CLLocationCoordinate2D(latitude: 37.766610, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinateSanFrancisco, span: span)
        mapView.setRegion(region, animated: true)
    }
}

extension DirectionsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = .red
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
}

struct DirectionsViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DirectionsViewController {
        DirectionsViewController()
    }
    
    func updateUIViewController(_ uiViewController: DirectionsViewController, context: Context) {
    }
}

struct DirectionsViewController_Previews: PreviewProvider {
    static var previews: some View {
        DirectionsViewControllerRepresentable()
            .ignoresSafeArea()
    }
}
