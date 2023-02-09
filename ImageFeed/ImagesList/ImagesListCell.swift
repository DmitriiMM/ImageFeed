import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    let gradientBottomCell = CAGradientLayer()
    var gradientLoading = CAGradientLayer()
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var dateLabelCell: UILabel!
    @IBOutlet var gradientViewCell: UIView!
    @IBOutlet var likeButtonCell: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageCell.kf.cancelDownloadTask()
    }
    
    @IBAction private func didLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        gradientLoading.frame.size = imageCell.frame.size
    }
    
    func setIsLiked(isLike: Bool) {
        switch isLike {
        case true:
            likeButtonCell.imageView?.image = UIImage(named: "Active")
        case false:
            likeButtonCell.imageView?.image = UIImage(named: "NoActive")
        }
    }
}
