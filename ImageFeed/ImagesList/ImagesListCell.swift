import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    let gradientLayer = CAGradientLayer()
    
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var dateLabelCell: UILabel!
    @IBOutlet var gradientViewCell: UIView!
    @IBOutlet var likeButtonCell: UIButton!
}
