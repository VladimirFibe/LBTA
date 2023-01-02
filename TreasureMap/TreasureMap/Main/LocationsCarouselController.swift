import UIKit
import LBTATools
import MapKit

class LocationCell: LBTAListCell<MKMapItem> {
    override var item: MKMapItem! {
        didSet {
            label.text = item.name
            address.text = item.address
            coordinate.text = "\(item.placemark.coordinate.latitude), \(item.placemark.coordinate.longitude)"
        }
    }
    let label = UILabel(text: "Location", font: .boldSystemFont(ofSize: 16))
    let address = UILabel(text: "Address", numberOfLines: 0)
    let coordinate = UILabel(text: "coordinate")
    override func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 10
        setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .black)
        stack(label, address, coordinate)
            .withMargins(.allSides(16))
    }
}

class LocationsCarouselController: LBTAListController<LocationCell, MKMapItem> {
    
    weak var mainController: MainController?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemMap = items[indexPath.item]
        
        if let annotations = mainController?.mapView.annotations {
            annotations.forEach { annotation in
                guard let customAnnotation = annotation as? CustomMapItemAnnotation else { return }
                if customAnnotation.mapItem?.name == itemMap.name {
                    mainController?.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
        if var region = mainController?.mapView.region {
            region.center = itemMap.placemark.coordinate
            self.mainController?.mapView.setRegion(region, animated: true)
        }
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
    }
}

extension LocationsCarouselController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width - 64, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        12
    }
}
