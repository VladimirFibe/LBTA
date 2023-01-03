import SwiftUI
import LBTATools
import MapKit

final class RouterHeader: UICollectionReusableView {
    let nameLabel = UILabel(text: "Route:", font: .boldSystemFont(ofSize: 16))
    let distanceLabel = UILabel(text: "Distance:", font: .boldSystemFont(ofSize: 16))
    let estimatedTimeLabel = UILabel(text: "Estimated Time:", font: .boldSystemFont(ofSize: 16))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stack(nameLabel, distanceLabel, estimatedTimeLabel, distribution: .fillEqually).withMargins(.allSides(16))
    }
    
    private func generateAttributedString(title: String, description: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: title + ": ", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
        attributedString.append(.init(string: description, attributes: [.font: UIFont.systemFont(ofSize: 16)]))
        return attributedString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabels(name: String, distance: Double, time: Double) {
        nameLabel.attributedText = generateAttributedString(title: "Route", description: name)
        distanceLabel.attributedText = generateAttributedString(title: "Distance", description: String(format: "%.0f m", distance))
        estimatedTimeLabel.attributedText = generateAttributedString(title: "Estimated Time", description: String(format: "%.0f h", time / 360))
    }
}

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

final class RoutesController: LBTAListHeaderController<RouteStepCell, MKRoute.Step, RouterHeader> {
    var route: MKRoute!
    
    override func setupHeader(_ header: RouterHeader) {
        header.setupLabels(name: route.name, distance: route.distance, time: route.expectedTravelTime)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        .init(width: 0, height: 100)
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
//        RoutesControllerRepresentable()
        Text("Hi")
    }
}
