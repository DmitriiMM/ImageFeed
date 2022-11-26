import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var dateLabelCell: UILabel!
    @IBOutlet var gradientViewCell: UIView!
    @IBOutlet var likeButtonCell: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.gradientViewCell = nil
    }
}
