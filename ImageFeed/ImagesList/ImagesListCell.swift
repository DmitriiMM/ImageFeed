import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    let gradientBottomCell = CAGradientLayer()
    var gradientLoading = CAGradientLayer()
    private let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var dateLabelCell: UILabel!
    @IBOutlet var gradientViewCell: UIView!
    @IBOutlet var likeButtonCell: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageCell.kf.cancelDownloadTask()
        gradientLoading.removeFromSuperlayer()
    }
    
    @IBAction private func didLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        gradientLoading.frame.size = imageCell.frame.size
    }
    
    func setIsLiked(isLike: Bool) {
        if isLike {
            likeButtonCell.setImage(UIImage(named: "Active"), for: .normal)
        } else {
            likeButtonCell.setImage(UIImage(named: "NoActive"), for: .normal)
        }
    }
    
    func configLoadingGradient(for imageView: UIImageView) {
        gradientLoading.frame = CGRect(
            origin:
                CGPoint(x: 0, y: 0),
            size:
                CGSize(
                    width: imageView.frame.width,
                    height: imageView.frame.height
                )
        )
        
        gradientLoading.locations = [0, 0.1, 0.3]
        gradientLoading.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        
        gradientLoading.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLoading.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLoading.cornerRadius = 16
        gradientLoading.masksToBounds = true
        imageView.layer.addSublayer(gradientLoading)
        
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientLoading.add(gradientChangeAnimation, forKey: "locationsChange")
    }
}
