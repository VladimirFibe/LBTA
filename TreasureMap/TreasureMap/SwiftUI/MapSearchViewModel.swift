import SwiftUI
import MapKit
import Combine

final class MapSearchViewModel: ObservableObject {
    @Published var annotations: [MKPointAnnotation] = []
    @Published var mapItems: [MKMapItem] = []
    @Published var isSearching = false
    @Published var searchQuery = ""
    @Published var selectedItem: MKMapItem?
    @Published var keyboardHeight = 0.0
    
    private var bag = Set<AnyCancellable>()
    
    init() {
        $searchQuery
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink {[weak self] searchTerm in
                guard let self = self else { return }
                self.performLocalSearch(searchTerm)
            }
            .store(in: &bag)
        
        listenForKeyboardNotifications()
    }
    
    fileprivate func listenForKeyboardNotifications() {
        NotificationCenter.default
            .addObserver(forName: UIResponder.keyboardWillShowNotification,
                         object: nil,
                         queue: .main) {[weak self] notification in
                guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                let keyboardFrame = value.cgRectValue
                let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
                withAnimation(.easeOut(duration: 0.25)) {
                    self?.keyboardHeight = keyboardFrame.height - window!.safeAreaInsets.bottom
                }
                print("DEBUG: \(self?.keyboardHeight)")
            }
        NotificationCenter.default
            .addObserver(forName: UIResponder.keyboardWillHideNotification,
                         object: nil,
                         queue: .main) {[weak self] notification in
                withAnimation(.easeOut(duration: 0.25)) {
                    self?.keyboardHeight = 0
                }
                print("DEBUG: \(self?.keyboardHeight)")
            }
    }
    func removeLocations() {
        annotations = []
    }
    
    func performLocalSearch(_ text: String) {
        guard !text.isEmpty else {return}
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        let localSearch = MKLocalSearch(request: request)
        isSearching = true
        localSearch.start { response, error in
            if let error = error {
                self.isSearching = false
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            self.mapItems = response?.mapItems ?? []
            var airports = [MKPointAnnotation]()
            response?.mapItems.forEach({ mapItem in
                let annotation = CustomMapItemAnnotation()
                annotation.mapItem = mapItem
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = "Location: " + (mapItem.name ?? "")
                annotation.subtitle = mapItem.address
                airports.append(annotation)
            })
            self.annotations = airports
            self.isSearching = false
        }
    }
}
