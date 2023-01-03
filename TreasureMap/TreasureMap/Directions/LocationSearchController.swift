import SwiftUI
import LBTATools
import MapKit
import Combine

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
    private var bag = Set<AnyCancellable>()
    var selectionHandler: ((MKMapItem) -> ())?
    let searchTextField = IndentedTextField(placeholder: "Endter search term", padding: 12)
    lazy var backIcon = UIButton(image: UIImage(named: "back_arrow")!, tintColor: .black, target: self, action: #selector(handleBack)).withWidth(32)
    let navBarHeight = 66.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.becomeFirstResponder()
        performLoacalSearch()
        setupSearchBar()
    }
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupSearchBar() {
        let navBar = UIView(backgroundColor: .white)
        view.addSubview(navBar)
        navBar.anchor(
            top: view.topAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.topAnchor,
            trailing: view.trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: -navBarHeight, right: 0))
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        let container = UIView(backgroundColor: .clear)
        navBar.addSubview(container)
        container.fillSuperviewSafeAreaLayoutGuide()
        container.hstack(backIcon, searchTextField, spacing: 12).withMargins(.init(top: 0, left: 16, bottom: 16, right: 16))
        searchTextField.layer.borderWidth = 2
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
        searchTextField.layer.cornerRadius = 5
        setupSearchListener()
    }
    
    fileprivate func setupSearchListener() {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification,
            object: searchTextField)
            .debounce(for: .milliseconds(500),
                      scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.performLoacalSearch()}
            .store(in: &bag)
    }
    
    fileprivate func performLoacalSearch() {
        print("DEBUG: \(#function)")
        guard let text = searchTextField.text, !text.isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        
        let search = MKLocalSearch.init(request: request)
        search.start { response, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            if let items = response?.mapItems {
                self.items = items
            } else {
                self.items = []
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        selectionHandler?(items[indexPath.item])
    }
}

extension LocationSearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: navBarHeight, left: 0, bottom: 0, right: 0)
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
