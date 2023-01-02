import SwiftUI
import LBTATools
import MapKit

class LocationSearchCell: LBTAListCell<MKMapItem> {
    override var item: MKMapItem! {
        didSet {
            titleLabel.text = item.name
            subTitleLabel.text = item.address
        }
    }
    let titleLabel = UILabel(text: "Title", font: .boldSystemFont(ofSize: 16))
    let subTitleLabel = UILabel(text: "Subtitle", font: .systemFont(ofSize: 14))
    override func setupViews() {
        stack(titleLabel, subTitleLabel).withMargins(.allSides(16))
        addSeparatorView(leftPadding: 16)
    }
}
final class LocationSearchController: LBTAListController<LocationSearchCell, MKMapItem> {
    override func viewDidLoad() {
        super.viewDidLoad()
        performLoacalSearch()
    }
    
    fileprivate func performLoacalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Sushi"
        
        let search = MKLocalSearch.init(request: request)
        search.start { response, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            if let items = response?.mapItems {
                self.items = items
            }
        }
    }
}

extension LocationSearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 70)
    }
}

struct LocationSearchControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LocationSearchController {
        LocationSearchController()
    }
    
    func updateUIViewController(_ uiViewController: LocationSearchController, context: Context) {}
}

struct LocationSearchController_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchControllerRepresentable()
            .ignoresSafeArea()
    }
}
