import UIKit
import LBTATools
import MapKit
import GooglePlaces

class PlacesViewController: UIViewController {

    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    let client = GMSPlacesClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.showsUserLocation = true
        locationManager.delegate = self
            requestForLocationAuthorization()
    }
    
    fileprivate func findNearbyPlaces() {
        client.currentPlace {[weak self] likelihoodList, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            likelihoodList?.likelihoods.forEach({ likelihood in
                print("DEBUG: \(likelihood.place.name ?? "")")
                let place = likelihood.place
                let annotation = MKPointAnnotation()
                annotation.title = place.name
                annotation.coordinate = place.coordinate
                self?.mapView.addAnnotation(annotation)
            })
            self?.mapView.showAnnotations(self?.mapView.annotations ?? [], animated: true)
        }
    }
    fileprivate func requestForLocationAuthorization() {
        DispatchQueue.global().async {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension PlacesViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let first = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: first.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        findNearbyPlaces()
        locationManager.stopUpdatingLocation()
    }
}
