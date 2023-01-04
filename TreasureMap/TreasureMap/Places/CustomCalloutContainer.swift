import UIKit

class CustomCalloutContainer: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupViews() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 2
        setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        layer.cornerRadius = 5
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .darkGray
        spinner.startAnimating()
        addSubview(spinner)
        spinner.fillSuperview()
    }
}
