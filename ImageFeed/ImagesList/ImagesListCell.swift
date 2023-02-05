import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    var animationLayers = Set<CALayer>()
    private var imagesListServiceObserver: NSObjectProtocol?
    static let reuseIdentifier = "ImagesListCell"
    let gradientLayer = CAGradientLayer()
    let gradientForCell = CAGradientLayer()
    let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var dateLabelCell: UILabel!
    @IBOutlet var gradientViewCell: UIView!
    @IBOutlet var likeButtonCell: UIButton!
    
    func gradient() {
        //MARK: - Gradient for Cell
        gradientForCell.frame = CGRect(
            origin:
                CGPoint(x: 0, y: 0),
            size:
                CGSize(
                    width: imageCell.frame.width,
                    height: imageCell.frame.height
                )
        )
        gradientForCell.locations = [0, 0.1, 0.3]
        gradientForCell.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientForCell.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForCell.endPoint = CGPoint(x: 1, y: 0.5)
        gradientForCell.cornerRadius = 16
        gradientForCell.masksToBounds = true
        animationLayers.insert(gradientForCell)
        imageCell.layer.insertSublayer(gradientForCell, at: 0)
        
        //MARK: - Animation for Cell gradient
        
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientForCell.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageCell.kf.cancelDownloadTask()
    }
    
    @IBAction private func didLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
