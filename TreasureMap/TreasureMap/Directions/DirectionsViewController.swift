import UIKit
import LBTATools
import MapKit
import SwiftUI
import JGProgressHUD

class DirectionsViewController: UIViewController {

    let mapView = MKMapView()
    let navBar = UIView(backgroundColor: .brandBlue)
    
    let startTextField = IndentedTextField(padding: 16, cornerRadius: 5)
    let endTextField = IndentedTextField(padding: 16, cornerRadius: 5)
    
    var startMapItem: MKMapItem?
    var endMapItem: MKMapItem?
    
    var currentlyShowingRoute: MKRoute?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBarUI()
        setupMap()
        setupShowRouteButton()
    }
    
    fileprivate func setupShowRouteButton() {
        let showRouteButton = UIButton(
            title: "Show Route",
            titleColor: .black,
            font: .boldSystemFont(ofSize: 16),
            backgroundColor: .white,
            target: self,
            action: #selector(handleShowRoute))
        
        view.addSubview(showRouteButton)
        
        showRouteButton.anchor(
            top: nil,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: .allSides(12),
            size: .init(width: 0, height: 50))
    }
    
    @objc fileprivate func handleShowRoute() {
        guard let route = currentlyShowingRoute else { return }
        let routesController = RoutesController()
        routesController.items = route.steps.filter{!$0.instructions.isEmpty}
        present(routesController, animated: true)
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
    }
    
    fileprivate func requestForDirections() {
        let request = MKDirections.Request()
        
        request.source = startMapItem
        request.destination = endMapItem
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Routing..."
        hud.show(in: view)
        request.transportType = .any
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            hud.dismiss()
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            guard let route = response?.routes.first else { return }
            self.mapView.addOverlay(route.polyline)
            self.currentlyShowingRoute = route
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
            padding: .init(top: 0, left: 0, bottom: -120, right: 0)
        )
        navBar.setupShadow(opacity: 0.5, radius: 5)
        let containerView = UIView(backgroundColor: .clear)
        navBar.addSubview(containerView)
        containerView.fillSuperviewSafeAreaLayoutGuide()
        var first = true
        [startTextField, endTextField].forEach {
            $0.backgroundColor = .init(white: 1, alpha: 0.3)
            $0.textColor = .white
            $0.attributedPlaceholder = .init(string: first ? "Start" : "End", attributes: [.foregroundColor: UIColor.init(white: 1, alpha: 0.7)])
            first = false
        }
        let startIcon = UIImageView(image: UIImage(named: "start_location_circles"), contentMode: .scaleAspectFit)
        startIcon.constrainWidth(20)
        let endIcon = UIImageView(image: UIImage(named: "annotation_icon")?.withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        endIcon.tintColor = .white
        endIcon.constrainWidth(20)
        containerView.stack(
            containerView.hstack(startIcon, startTextField, spacing: 16),
            containerView.hstack(endIcon, endTextField, spacing: 16),
                            spacing: 16,
                            distribution: .fillEqually)
        .withMargins(.init(top: 0, left: 16, bottom: 12, right: 16))
        startTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeLocation)))
        endTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeLocation)))
        navigationController?.navigationBar.isHidden = true
        endTextField.tag = 1
    }
    
    @objc fileprivate func handleChangeLocation(_ sender: UITapGestureRecognizer) {
        let vc = LocationSearchController()
        vc.selectionHandler = { [weak self] item in
            if sender.view?.tag == 1 {
                self?.endTextField.text = item.name
                self?.endMapItem = item
            } else {
                self?.startTextField.text = item.name
                self?.startMapItem = item
            }
            self?.addAnnotations()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    fileprivate func addAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        [startMapItem, endMapItem].forEach {
            if let item = $0 {
                addAnnotation(item)
            }
        }
        guard startMapItem != nil, endMapItem != nil else { return }
        requestForDirections()
    }
    
    fileprivate func addAnnotation(_ item: MKMapItem) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = item.placemark.coordinate
        annotation.title = item.name
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: false)
    }
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
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
        polylineRenderer.strokeColor = .brandBlue
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
}

struct DirectionsViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UINavigationController(rootViewController: DirectionsViewController())
        
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

struct DirectionsViewController_Previews: PreviewProvider {
    static var previews: some View {
        DirectionsViewControllerRepresentable()
            .ignoresSafeArea()
    }
}
