import UIKit
import LBTATools
import MapKit
import GooglePlaces

class PlacesViewController: UIViewController {

    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    let client = GMSPlacesClient()
    var currentCustomCallout: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.showsUserLocation = true
        mapView.delegate = self
        
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
                
                let annotation = PlaceAnnotation(place: place)
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

extension PlacesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let placeAnnotation = annotation as? PlaceAnnotation else { return nil }
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
        annotationView.canShowCallout = true
        if let firstType = placeAnnotation.place.types?.first {
            switch firstType {
            case "bar": annotationView.image = #imageLiteral(resourceName: "bar")
            case "restaurant": annotationView.image = #imageLiteral(resourceName: "restaurant")
            case "point_of_interest": annotationView.image = #imageLiteral(resourceName: "restaurant")
            default: annotationView.image = #imageLiteral(resourceName: "default")
            }
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("DEBUG: \(123)")
    
        currentCustomCallout?.removeFromSuperview()
        let customCalloutContainer = UIView(backgroundColor: .white)
        view.addSubview(customCalloutContainer)
        customCalloutContainer.translatesAutoresizingMaskIntoConstraints = false
        let widthAnchor = customCalloutContainer.widthAnchor.constraint(equalToConstant: 100)
        let heightAnchor = customCalloutContainer.heightAnchor.constraint(equalToConstant: 50)
        NSLayoutConstraint.activate([
            widthAnchor,
            heightAnchor,
            customCalloutContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customCalloutContainer.bottomAnchor.constraint(equalTo: view.topAnchor)
        ])
        customCalloutContainer.layer.borderColor = UIColor.darkGray.cgColor
        customCalloutContainer.layer.borderWidth = 2
        customCalloutContainer.setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        customCalloutContainer.layer.cornerRadius = 5
        currentCustomCallout = customCalloutContainer
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .darkGray
        spinner.startAnimating()
        customCalloutContainer.addSubview(spinner)
        spinner.fillSuperview()
        
        guard let placeId = (view.annotation as? PlaceAnnotation)?.place.placeID else { return }
        client.lookUpPhotos(forPlaceID: placeId) {[weak self] metadataList, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            guard let firstPhotoMetadata = metadataList?.results.first else { return }
            self?.client.loadPlacePhoto(firstPhotoMetadata) { uiImage, error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    return
                }
                guard let uiImage = uiImage else { return }
                if uiImage.size.width > uiImage.size.height {
                    let width = 300.0
                    let height = uiImage.size.height * width / uiImage.size.width
                    widthAnchor.constant = width
                    heightAnchor.constant = height
                }
                DispatchQueue.main.async {
                    spinner.stopAnimating()
                    let imageView = UIImageView(image: uiImage, contentMode: .scaleAspectFill)
                    customCalloutContainer.addSubview(imageView)
                    imageView.fillSuperview()
                }
            }
        }
    }
}

class PlaceAnnotation: MKPointAnnotation {
    let place: GMSPlace
    init(place: GMSPlace) {
        self.place = place
    }
}
