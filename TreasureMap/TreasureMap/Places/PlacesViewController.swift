/*
import UIKit
import LBTATools
import MapKit
import GooglePlaces
import JGProgressHUD

class PlacesViewController: UIViewController {

    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    let client = GMSPlacesClient()
    var currentCustomCallout: UIView?
    
    let hudNameLabel = UILabel(text: "Name", font: .boldSystemFont(ofSize: 16))
    let hudAddressLabel = UILabel(text: "Address", font: .systemFont(ofSize: 16))
    let hudTypesLabel = UILabel(text: "Types", textColor: .gray)
    lazy var infoButton = UIButton(type: .infoLight)
    let hudContainer = UIView(backgroundColor: .white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        locationManager.delegate = self
        requestForLocationAuthorization()
        setupSelectedAnnotationHUD()
    }
    
    fileprivate func setupSelectedAnnotationHUD() {
        infoButton.addTarget(self, action: #selector(handleInformation), for: .primaryActionTriggered)
        view.addSubview(hudContainer)
        hudContainer.layer.cornerRadius = 5
        hudContainer.setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        hudContainer.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .allSides(16), size: .init(width: 0, height: 125))
        
        let topRow = UIView()
        topRow.hstack(hudNameLabel, infoButton.withWidth(44))
        hudContainer.stack(topRow, hudAddressLabel, hudTypesLabel, spacing: 8).withMargins(.allSides(16))
    }
    
    @objc private func handleInformation() {
        guard let placeAnnotation = mapView.selectedAnnotations.first as? PlaceAnnotation else { return }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading photos..."
        hud.show(in: view)
        
        guard let placeId = placeAnnotation.place.placeID else { return }
        client.lookUpPhotos(forPlaceID: placeId) {[weak self] list, error in
            guard let self = self else { return }
            if let error = error {
                hud.dismiss()
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            let dispatchGroup = DispatchGroup()
            var images: [UIImage] = []
            list?.results.forEach {
                dispatchGroup.enter()
                self.client.loadPlacePhoto($0) { image, error in
                    dispatchGroup.leave()
                    if let error = error {
                        hud.dismiss()
                        print("DEBUG: \(error.localizedDescription)")
                        return
                    }
                    guard let image = image else { return }
                    images.append(image)
                }
            }
            dispatchGroup.notify(queue: .main) {
                hud.dismiss()
                let controller = PlacePhotosViewController()
                controller.items = images
                controller.title = placeAnnotation.title
                print("DEBUG: \(controller.items.count)")
                self.present(UINavigationController(rootViewController: controller), animated: true)
            }
        }
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
    
    fileprivate func bestSize(for uiImage: UIImage) -> CGSize {
        if uiImage.size.width > uiImage.size.height {
            let width = 300.0
            let height = uiImage.size.height * width / uiImage.size.width
            return .init(width: width, height: height)
        } else {
            let height = 300.0
            let width = uiImage.size.width * height / uiImage.size.height
            return .init(width: width, height: height)
        }
    }
}

extension PlacesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let placeAnnotation = annotation as? PlaceAnnotation else { return nil }
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
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
    
    fileprivate func setupHUD(with view: MKAnnotationView) {
        guard let annotation = view.annotation as? PlaceAnnotation else { return }
        let place = annotation.place
        hudNameLabel.text = place.name
        hudAddressLabel.text = place.formattedAddress
        hudTypesLabel.text = place.types?.joined(separator: ", ")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        setupHUD(with: view)
        currentCustomCallout?.removeFromSuperview()
        let customCalloutContainer = CustomCalloutContainer()
        view.addSubview(customCalloutContainer)
        let widthAnchor = customCalloutContainer.widthAnchor.constraint(equalToConstant: 100)
        let heightAnchor = customCalloutContainer.heightAnchor.constraint(equalToConstant: 50)
        NSLayoutConstraint.activate([
            widthAnchor,
            heightAnchor,
            customCalloutContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customCalloutContainer.bottomAnchor.constraint(equalTo: view.topAnchor)
        ])
        currentCustomCallout = customCalloutContainer
        
        guard let firstPhotoMetadata = (view.annotation as? PlaceAnnotation)?.place.photos?.first else { return }
        self.client.loadPlacePhoto(firstPhotoMetadata) {[weak self] uiImage, error in
            guard let self = self else { return }
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            guard let uiImage = uiImage else { return }
            let size = self.bestSize(for: uiImage)
            widthAnchor.constant = size.width
            heightAnchor.constant = size.height
            
            let imageView = UIImageView(image: uiImage, contentMode: .scaleAspectFill)
            customCalloutContainer.addSubview(imageView)
            imageView.layer.cornerRadius = 5
            imageView.fillSuperview()
            
            let labelContainer = UIView(backgroundColor: .white)
            let nameLabel = UILabel(text: (view.annotation as? PlaceAnnotation)?.place.name, textAlignment: .center)
            labelContainer.stack(nameLabel)
            customCalloutContainer.stack(UIView(), labelContainer.withHeight(30))
        }
    }
}

class PlaceAnnotation: MKPointAnnotation {
    let place: GMSPlace
    init(place: GMSPlace) {
        self.place = place
    }
}
*/
