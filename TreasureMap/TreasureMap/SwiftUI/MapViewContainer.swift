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
    var annotations: [MKPointAnnotation]?
    func makeUIView(context: Context) -> MKMapView {
        setupRegionForMap()
        return mapView
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        guard let annotations = annotations else { return }
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
        uiView.showAnnotations(uiView.annotations, animated: false)
    }
    fileprivate func setupRegionForMap() {
        let coordinateSanFrancisco = CLLocationCoordinate2D(latitude: 37.766610, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinateSanFrancisco, span: span)
        mapView.setRegion(region, animated: true)
    }
}
