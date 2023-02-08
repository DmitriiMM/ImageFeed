import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    var animationLayers = Set<CALayer>()
    let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
    
    var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var inputDateFormatter: DateFormatter = {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return inputDateFormatter
    }()
    
    private lazy var outputDateFormatter: DateFormatter = {
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "dd MMMM yyyy"
        outputDateFormatter.locale = Locale(identifier: "ru_RU")
        
        return outputDateFormatter
    }()
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        imagesListService.fetchPhotosNextPage()
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount == 0 {
            tableView.reloadData()
        } else if oldCount != newCount {
            tableView.performBatchUpdates {
                var indexPaths: [IndexPath] = []
                for i in oldCount..<newCount {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as? SingleImageViewController
            let indexPath = sender as! IndexPath
            viewController?.fullImageUrl = self.photos[indexPath.row].largeImageURL
        } else {
            prepare(for: segue, sender: sender)
        }
    }
    
    private func configBottomGradient(for cell: ImagesListCell) {
        cell.gradientButtomCell.colors = [
            UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0).cgColor,
            UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0.5).cgColor
        ]
        
        cell.gradientButtomCell.locations = [0, 1]
        cell.gradientButtomCell.frame.size = cell.gradientViewCell.frame.size
        cell.gradientViewCell.layer.insertSublayer(cell.gradientButtomCell, at: 0)
    }
    
    private func setIsLiked(isLike: Bool) -> String {
        let imageNameLike = isLike == true ? "NoActive" : "Active"
        return imageNameLike
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.likeButtonCell.isHidden = true
        cell.dateLabelCell.isHidden = true
        cell.gradientButtomCell.isHidden = true
        cell.gradientLoading = addForGradient(on: cell.imageCell)
        
        let imageURL = self.photos[indexPath.row].thumbImageURL
        let url = URL(string: imageURL)
        let placeholder = UIImage(named: "Stub")
        
        cell.imageCell.kf.indicatorType = .activity
        cell.imageCell.kf.setImage(with: url, placeholder: placeholder) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                cell.imageCell.kf.indicatorType = .none
                cell.gradientLoading.removeFromSuperlayer()
                cell.likeButtonCell.isHidden = false
                cell.dateLabelCell.isHidden = false
                cell.gradientButtomCell.isHidden = false
                self.animationLayers.removeAll()
            case .failure(let error):
                print(error)
                cell.imageCell.kf.indicatorType = .none
            }
        }
        
        let like = self.photos[indexPath.row].isLiked
        switch like {
        case true:
            cell.likeButtonCell.setImage(UIImage(named: "Active"), for: .normal)
        case false:
            cell.likeButtonCell.setImage(UIImage(named: "NoActive"), for: .normal)
        }
        
        if let inputDate = inputDateFormatter.date(from: photos[indexPath.row].createdAt) {
            let outputDateString = outputDateFormatter.string(from: inputDate)
            cell.dateLabelCell.text = outputDateString
        }
        
        configBottomGradient(for: cell)
    }
    
    private func addForGradient(on superView: UIImageView) -> CAGradientLayer {
        let gradientForCell = CAGradientLayer()
        
        gradientForCell.frame = CGRect(
            origin:
                CGPoint(x: 0, y: 0),
            size:
                CGSize(
                    width: superView.frame.width,
                    height: superView.frame.height
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
        superView.layer.addSublayer(gradientForCell)
        
        animationLayers.insert(gradientForCell)
        
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientForCell.add(gradientChangeAnimation, forKey: "locationsChange")
        
        return gradientForCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        photos = imagesListService.photos
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in
            switch result {
            case .success():
                let imageNameLike = self.setIsLiked(isLike: photo.isLiked)
                guard let image = UIImage(named: imageNameLike) else { return }
                cell.likeButtonCell.setImage(image, for: .normal)
                UIBlockingProgressHUD.dismiss()
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                break
            }
        }
    }
}
