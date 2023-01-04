import UIKit
import LBTATools

class PhotoCell: LBTAListCell<UIImage> {
    override var item: UIImage! {
        didSet {
            imageView.image = item
        }
    }
    let imageView = UIImageView(image: nil, contentMode: .scaleAspectFill)
    override func setupViews() {
        addSubview(imageView)
        imageView.fillSuperview()
    }
}

class PlacePhotosViewController: LBTAListController<PhotoCell, UIImage> {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension PlacePhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 300)
    }
}
