import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    var animationLayers = Set<CALayer>()
    let gradientForCell = CAGradientLayer()
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
        print("🖤❤️🖤❤️🖤 start viewDidLoad")
        tableView.delegate = self
        tableView.dataSource = self
       
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
//
//                ImagesListCell().gradientForCell.removeFromSuperlayer()
//                ImagesListCell().animationLayers.removeAll()
                print("💚💜💚💜💚 end NotificationCenter.default.addObserver in viewDidLoad")
                self.updateTableViewAnimated()
            }
        imagesListService.fetchPhotosNextPage()
        print("🖤❤️🖤❤️🖤🖤❤️🖤❤️🖤🖤❤️🖤❤️🖤 fetchPhotosNextPage from viewDidLoad")
        print("💛🤎💛🤎💛 end viewDidLoad")
    }
    
    func updateTableViewAnimated() {
        print("🖤🖤🖤 updateTableViewAnimated")
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            print(" 🔳🔳🔳 oldCount \(oldCount) != newCount \(newCount) ")
            tableView.performBatchUpdates {
                var indexPaths: [IndexPath] = []
                for i in oldCount..<newCount {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
//                self.animationLayers.removeAll()
//                gradientForCell.removeFromSuperlayer()
//                gradient(with: indexPaths)
                tableView.insertRows(at: indexPaths, with: .automatic)
//                gradient(with: indexPaths)
                print("🖤🖤🖤🖤🖤 AFTER tableView.insertRows(at: indexPaths, with: .automatic)")
            } completion: { _ in
//                gradient(with: indexPaths)
            }
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
    
    func configGradient(for cell: ImagesListCell) {
        cell.gradientLayer.colors = [
            UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0).cgColor,
            UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0.5).cgColor
        ]
        
        cell.gradientLayer.locations = [0, 1]
        cell.gradientLayer.frame = cell.gradientViewCell.bounds
        cell.gradientViewCell.layer.insertSublayer(cell.gradientLayer, at: 0)
    }
    
    func setIsLiked(isLike: Bool) -> String {
        let imageNameLike = isLike == true ? "NoActive" : "Active"
        return imageNameLike
    }
    
    func configSizeOfCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageSize = self.photos[indexPath.row].size
        print("🪜🪜🪜 imageSize  \(imageSize)")
        
        cell.contentView.frame.size = imageSize
        cell.imageCell.frame.size = imageSize
        
        gradientt(for: cell.imageCell, with: imageSize)
        cell.imageCell.layer.insertSublayer(gradientForCell, at: 0)
        
        
    
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        print("💜💜💜 configCell(for cell")
//        gradient(for: cell, with: indexPath)
        let imageURL = self.photos[indexPath.row].thumbImageURL
        let imageSize = self.photos[indexPath.row].size
        let url = URL(string: imageURL)
        let placeholder = UIImage(named: "stub")
        
//        gradient(for: cell, with: indexPath)
        cell.imageCell.kf.indicatorType = .activity
//        gradient(for: cell, with: indexPath)
//        gradientt(for: cell.imageCell, with: imageSize)
        cell.imageCell.kf.setImage(with: url, placeholder: placeholder) { [weak self] result in
            
            guard let self else { return }
//            self.gradient(for: cell, with: indexPath)
            switch result {
            case .success(_):
                print("🧡🧡🧡 success in kf.setImage")
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
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
    
    func gradient(for cell: ImagesListCell, with indexPath: IndexPath) {
        //MARK: - Gradient for Cell
        gradientForCell.frame = CGRect(
            origin:
                CGPoint(x: 0, y: 0),
            size:
                CGSize(
                    width: cell.imageCell.frame.width,
                    height: cell.imageCell.frame.height
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
        gradientForCell.cornerRadius = cell.layer.cornerRadius
        gradientForCell.masksToBounds = true
        animationLayers.insert(gradientForCell)
        cell.imageCell.layer.insertSublayer(gradientForCell, at: 0)
        
        //MARK: - Animation for Cell gradient
        
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientForCell.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    func gradient(with indexPaths: [IndexPath]) {
        //MARK: - Gradient for Cell
        let cell = ImagesListCell()
        gradientForCell.frame = CGRect(
            origin:
                CGPoint(x: 0, y: 0),
            size:
                CGSize(
                    width: cell.imageCell.frame.width,
                    height: cell.imageCell.frame.height
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
        gradientForCell.cornerRadius = cell.layer.cornerRadius
        gradientForCell.masksToBounds = true
        animationLayers.insert(gradientForCell)
        cell.imageCell.layer.insertSublayer(gradientForCell, at: 0)
        
        //MARK: - Animation for Cell gradient
        
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientForCell.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    func gradientt(for imageView: UIImageView, with size: CGSize) {
        //MARK: - Gradient for Cell
//        let cell = ImagesListCell()
        gradientForCell.frame = CGRect(
            origin:
                CGPoint(x: 0, y: 0),
            size:
                size
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
        imageView.layer.insertSublayer(gradientForCell, at: 0)
        
        //MARK: - Animation for Cell gradient
        
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientForCell.add(gradientChangeAnimation, forKey: "locationsChange")
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("💙💙💙 didSelectRowAt")
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("❤️‍🔥❤️‍🔥❤️‍🔥 willDisplay")
        if indexPath.row + 1 == photos.count {
//            gradient(for: cell as! ImagesListCell, with: indexPath)
            print("❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥 \(indexPath.row + 1) \(photos.count)fetchPhotosNextPage")
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("🤍🤍🤍 numberOfRowsInSection")
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        print("🤎🤎🤎 cellForRowAt start")
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
//        configCell(for: imageListCell, with: indexPath)
        configSizeOfCell(for: imageListCell, with: indexPath)
        print("🤎🤎🤎 cellForRowAt finish ")
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
