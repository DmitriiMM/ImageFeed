import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    let gradientLayer = CAGradientLayer()
   weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var dateLabelCell: UILabel!
    @IBOutlet var gradientViewCell: UIView!
    @IBOutlet var likeButtonCell: UIButton!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("❤️❤️❤️ prepareForReuse")
        imageCell.kf.cancelDownloadTask()
    }
    
    @IBAction private func didLikeButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
