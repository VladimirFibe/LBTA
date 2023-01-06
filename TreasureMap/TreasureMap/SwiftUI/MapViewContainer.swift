//
//  MapViewContainer.swift
//  TreasureMap
//
//  Created by Vladimir Fibe on 1/4/23.
//

import SwiftUI
import MapKit

struct MapViewContainer: UIViewRepresentable {
    let mapView = MKMapView()
    var selectedItem: MKMapItem?
    var annotations: [MKPointAnnotation]?
    var currentLocation = CLLocationCoordinate2D(latitude: 37.766610, longitude: -122.427290)
    func makeUIView(context: Context) -> MKMapView {
        setupRegionForMap()
        return mapView
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        guard let annotations = annotations else { return }
        #warning("Проверять чтоб дважды не перерисовывал анотации")
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
        uiView.showsUserLocation = true
        uiView.showAnnotations(uiView.annotations, animated: false)
    }
    fileprivate func setupRegionForMap() {
        let coordinateSanFrancisco = CLLocationCoordinate2D(latitude: 37.766610, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinateSanFrancisco, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        init(mapView: MKMapView) {
            super.init()
            mapView.delegate = self
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is MKPointAnnotation else { return nil }
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            pinAnnotationView.canShowCallout = true
            return pinAnnotationView
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(mapView: mapView)
    }
}
