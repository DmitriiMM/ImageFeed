import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    var animationLayers = Set<CALayer>()
    let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
    
    var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    private var imagesListServiceObserver: NSObjectProtocol?
    let isoDateFormatter = ISO8601DateFormatter()
    
//    private lazy var inputDateFormatter: DateFormatter = {
//        let inputDateFormatter = DateFormatter()
//        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//
//        return inputDateFormatter
//    }()
//
//    private lazy var outputDateFormatter: DateFormatter = {
//        let outputDateFormatter = DateFormatter()
//        outputDateFormatter.dateFormat = "dd MMMM yyyy"
//        outputDateFormatter.locale = Locale(identifier: "ru_RU")
//
//        return outputDateFormatter
//    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        return dateFormatter
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
        cell.gradientBottomCell.colors = [
            UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0).cgColor,
            UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0.5).cgColor
        ]
        
        cell.gradientBottomCell.locations = [0, 1]
        cell.gradientBottomCell.frame.size = cell.gradientViewCell.frame.size
        cell.gradientViewCell.layer.insertSublayer(cell.gradientBottomCell, at: 0)
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.likeButtonCell.isHidden = true
        cell.dateLabelCell.isHidden = true
        cell.gradientBottomCell.isHidden = true
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
                cell.gradientBottomCell.isHidden = false
                self.animationLayers.removeAll()
            case .failure(let error):
                print(error)
                cell.imageCell.kf.indicatorType = .none
            }
        }
        
        if self.photos[indexPath.row].isLiked {
            cell.likeButtonCell.setImage(UIImage(named: "Active"), for: .normal)
        } else {
            cell.likeButtonCell.setImage(UIImage(named: "NoActive"), for: .normal)
        }
        
        if let date = isoDateFormatter.date(from: photos[indexPath.row].createdAt) {
            cell.dateLabelCell.text = dateFormatter.string(from: date)
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
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success():
                self.photos = self.imagesListService.photos
                cell.setIsLiked(isLike: self.photos[indexPath.row].isLiked)
            case .failure(let error):
                self.showAlert(with: error)
            }
        }
    }
    
    private func showAlert(with error: Error) {
        let alert = UIAlertController(title: "Лайки сломались", message: "Ошибка - \(error)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}




