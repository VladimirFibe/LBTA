import SwiftUI
import LBTATools
import MapKit

final class RouteStepCell:LBTAListCell<MKRoute.Step> {
    override var item: MKRoute.Step! {
        didSet {
            nameLabel.text = item.instructions
            distanceLabel.text = String(format: "%.0f m", item.distance)
        }
    }
    let nameLabel = UILabel(text: "Name", numberOfLines: 0)
    let distanceLabel = UILabel(text: "200m", textAlignment: .right)
    override func setupViews() {
        hstack(nameLabel, distanceLabel.withWidth(80)).withMargins(.init(top: 8, left: 16, bottom: 8, right: 16))
        addSeparatorView(leadingAnchor: nameLabel.leadingAnchor)
    }
}
final class RoutesController: LBTAListController<RouteStepCell, MKRoute.Step> {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension RoutesController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 60)
    }
}

struct RoutesControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> RoutesController {
        RoutesController()
    }
    
    func updateUIViewController(_ uiViewController: RoutesController, context: Context) {
    }
}

struct RoutesController_Previews: PreviewProvider {
    static var previews: some View {
        RoutesControllerRepresentable()
    }
}
