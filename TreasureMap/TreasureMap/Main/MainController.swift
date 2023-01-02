import UIKit
import MapKit
import LBTATools
import SwiftUI
import Combine

class MainController: UIViewController {
    private var bag = Set<AnyCancellable>()
    let mapView = MKMapView()
    
    let searchTextField = UITextField(placeholder: "Search query")
    
    let locationsController = LocationsCarouselController(scrollDirection: .horizontal)
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestUserLocation()
        setupMap()
    }
    
    fileprivate func requestUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    func setupMap() {
        view.addSubview(mapView)
        mapView.mapType = .standard
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.fillSuperview()
        setupRegionForMap()
        setupSearchUI()
        setupLocationsCarousel()
    }
    
    fileprivate func setupLocationsCarousel() {
        locationsController.mainController = self
        let locationView = locationsController.view!
        view.addSubview(locationView)
        locationView.anchor(
            top: nil,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            size: .init(width: 0, height: 150))
    }
    
    fileprivate func setupSearchUI() {
        
        let whiteContainer = UIView(backgroundColor: .white)
        view.addSubview(whiteContainer)
        whiteContainer.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: nil,
            trailing: view.trailingAnchor,
            padding: .init(top: 0, left: 16, bottom: 0, right: 16))
        whiteContainer.stack(searchTextField)
            .withMargins(.allSides(16))
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification,
            object: searchTextField)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { result in
                self.performLocalSearch()
            }
            .store(in: &bag)
    }
    
    @objc fileprivate func handleSearchChanges() {
        print(#function)
        performLocalSearch()
    }
    
    fileprivate func performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        request.region = mapView.region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { response, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.locationsController.items.removeAll()
            response?.mapItems.forEach({ mapItem in
                let annotation = CustomMapItemAnnotation()
                annotation.mapItem = mapItem
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = "Location: " + (mapItem.name ?? "")
                annotation.subtitle = mapItem.address
                self.mapView.addAnnotation(annotation)
                self.locationsController.items.append(mapItem)
            })
//            if !self.locationsController.items.isEmpty {
//                self.locationsController.collectionView.scrollToItem(at: [0, 0], at: .centeredHorizontally, animated: true)
//            }
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    fileprivate func setupRegionForMap() {
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

extension MainController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? CustomMapItemAnnotation else { return }
        guard let name = annotation.mapItem?.name else { return }
        guard let index = self.locationsController.items.firstIndex(where: { $0.name == name }) else { return }
        self.locationsController.collectionView.scrollToItem(at: [0, index], at: .centeredHorizontally, animated: true)
                
    }
}

extension MainController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            print("Failed to authorize")
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        mapView.setRegion(.init(center: location.coordinate,
                                span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)),
                          animated: false)
        locationManager.stopUpdatingLocation()
    }
}

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MainController {
        MainController()
    }
    
    func updateUIViewController(_ uiViewController: MainController, context: Context) {
    }
}

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        ViewControllerRepresentable()
            .ignoresSafeArea()
    }
}
