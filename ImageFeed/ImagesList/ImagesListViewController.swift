import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
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
        imagesListService.fetchPhotosNextPage()
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
//                guard let self = self else { return }
                
                ImagesListCell().gradientForCell.removeFromSuperlayer()
                ImagesListCell().animationLayers.removeAll()
                self?.updateTableViewAnimated()
            }
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
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
//            let tappedCell = tableView.cellForRow(at: indexPath) as! ImagesListCell
//            let image = tappedCell.imageCell.image
//            viewController?.image = image
            viewController?.fullImageUrl = self.photos[indexPath.row].largeImageURL
            
        } else {
            prepare(for: segue, sender: sender)
        }
    }
    
    func configGradient(for cell: ImagesListCell) {
        cell.gradientLayer.colors = [
            UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0).cgColor,
            UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0.5).cgColor
        ]
        
        cell.gradientLayer.locations = [0, 1]
        cell.gradientLayer.frame = cell.gradientViewCell.bounds
        cell.gradientViewCell.layer.insertSublayer(cell.gradientLayer, at: 0)
    }
    
    func  setIsLiked(isLike: Bool) -> String {
        let imageNameLike = isLike == true ? "NoActive" : "Active"
        return imageNameLike
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageURL = self.photos[indexPath.row].thumbImageURL
        let url = URL(string: imageURL)
        let placeholder = UIImage(named: "stub")
        
        cell.imageCell.kf.indicatorType = .activity
        cell.imageCell.kf.setImage(with: url, placeholder: placeholder) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                cell.gradient()
                cell.imageCell.kf.indicatorType = .none
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
        
        
        guard let inputDate = inputDateFormatter.date(from: photos[indexPath.row].createdAt) else { return }
        let outputDateString = outputDateFormatter.string(from: inputDate)
        cell.dateLabelCell.text = outputDateString
        
        configGradient(for: cell)
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
        print("🤍🤍🤍 photo for index \(indexPath) - \(photo)")
        print("🤎🤎🤎 photo for index \(indexPath.row) - \(photo)")
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { result in
            print("❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥 photo - \(photo)")
            switch result {
            case .success():
                let imageNameLike = self.setIsLiked(isLike: photo.isLiked)
                print("💙💙💙 imageNameLike - \(imageNameLike)")
                guard let image = UIImage(named: imageNameLike) else { return }
                print("💜💜💜 \(image) is OK")
                cell.likeButtonCell.setImage(image, for: .normal)
                print("🖤🖤🖤 cell.likeButtonCell.imageView?.image = image")
                UIBlockingProgressHUD.dismiss()
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                print("🖤🖤🖤error🖤🖤🖤")
                break
            }
        }
    }
}
