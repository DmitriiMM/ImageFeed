import UIKit
import Kingfisher

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    
    private var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    let imagesListService = ImagesListService.shared
    
    private let isoDateFormatter = ISO8601DateFormatter()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        return dateFormatter
    }()
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        imagesListService.fetchPhotosNextPage()
    }
    
    func updateTableViewAnimated() {
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
        cell.configLoadingGradient(for: cell.imageCell)
        cell.contentView.bringSubviewToFront(cell.imageCell)
        
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
                cell.contentView.sendSubviewToBack(cell.imageCell)
                cell.gradientLoading.removeFromSuperlayer()
            case .failure(let error):
                print(error)
                cell.imageCell.kf.indicatorType = .none
            }
        }
        
        cell.setIsLiked(isLike: self.photos[indexPath.row].isLiked)
        
        if let date = isoDateFormatter.date(from: photos[indexPath.row].createdAt) {
            cell.dateLabelCell.text = dateFormatter.string(from: date)
        }
        
        configBottomGradient(for: cell)
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
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
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




