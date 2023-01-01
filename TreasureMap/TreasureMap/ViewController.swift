import UIKit
import MapKit
import LBTATools
import SwiftUI

class ViewController: UIViewController {

    let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }

    func setupMap() {
        view.addSubview(mapView)
        mapView.mapType = .standard
        mapView.delegate = self
        mapView.fillSuperview()
        setupRegionForMap()
        performLocalSearch()
        
    }
    
    fileprivate func performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Apple"
        request.region = mapView.region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { response, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            response?.mapItems.forEach({ mapItem in
                
                let placemark = mapItem.placemark
                var address = ""
                if let subThoroughfare = placemark.subThoroughfare {
                    address += subThoroughfare + " "
                }
                if let thoroughfare = placemark.thoroughfare {
                    address += thoroughfare + ", "
                }
                if let postalCode = placemark.postalCode {
                    address += postalCode + ", "
                }
                if let locality = placemark.locality {
                    address += locality + ", "
                }
                if let administrativeArea = placemark.administrativeArea {
                    address += administrativeArea + ", "
                }
                if let country = placemark.country {
                    address += country
                }
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                annotation.subtitle = address
                self.mapView.addAnnotation(annotation)
            })
            print(self.mapView.annotations.count)
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    fileprivate func setupRegionForMap() {
        let coordinateNewYork = CLLocationCoordinate2D(latitude: 40.783466, longitude: -73.971266)
        let coordinateSanFrancisco = CLLocationCoordinate2D(latitude: 37.766610, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinateSanFrancisco, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func setupAnnotationsForMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.766610, longitude: -122.427290)
        annotation.title = "Сан-Франциско"
        annotation.subtitle = "Калифорния"
        mapView.addAnnotation(annotation)
        
        let appleCampusAnnotation = MKPointAnnotation()
        appleCampusAnnotation.coordinate = CLLocationCoordinate2D(latitude: 37.3326, longitude: -122.030024)
        appleCampusAnnotation.title = "Apple Campus"
        appleCampusAnnotation.subtitle = "Купертино"
        mapView.addAnnotation(appleCampusAnnotation)
        
        mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
}

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerRepresentable()
            .ignoresSafeArea()
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
        annotationView.canShowCallout = true
//        annotationView.image = #imageLiteral(resourceName: "tourist")
        return annotationView
    }
}
