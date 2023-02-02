import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.setLocalizedDateFormatFromTemplate("MMMMd")
        
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
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
                guard let self = self else { return }
                print("⏰⏰⏰  imagesListServiceObserver ON")
                self.updateTableViewAnimated()
            }
        
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        print("🥩1🥩1🥩\(oldCount) ==== \(newCount)")
        
        photos = imagesListService.photos
        print("🥩2🥩2🥩\(oldCount) ==== \(newCount)")
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
//            let viewController = segue.destination as? SingleImageViewController
//            let indexPath = sender as! IndexPath
//            let image = UIImage(named: photosNames[indexPath.row])
//            viewController?.image = image
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
    
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        print("☎️ configCell() for cell \(indexPath.description)")
       
            let imageURL = self.photos[indexPath.row].thumbImageURL
            let url = URL(string: imageURL)
            let placeholder = UIImage(named: "stub")
            
            cell.imageCell.kf.indicatorType = .activity
            cell.imageCell.kf.setImage(with: url, placeholder: placeholder) { result in
                switch result {
                case .success(let value):
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    cell.imageCell.kf.indicatorType = .none
                    print(value.image)
                    
                    // From where the image was retrieved:
                    // - .none - Just downloaded.
                    // - .memory - Got from memory cache.
                    // - .disk - Got from disk cache.
                    print("💿💿💿 cacheType \(value.cacheType)")
                    
                    // The source object which contains information like `url`.
                    print("💿💿💿 source \(value.source)")
                    
                case .failure(let error):
                    print(error) // The error happens
                    cell.imageCell.kf.indicatorType = .none
                }
            }
        
        cell.dateLabelCell.text = photos[indexPath.row].createdAt
        
        
        if photos[indexPath.row].isLiked {
            cell.likeButtonCell.imageView?.image = UIImage(named: "Active")
        } else {
            cell.likeButtonCell.imageView?.image = UIImage(named: "NoActive")
        }
        
        configGradient(for: cell)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("🥗🥗🥗🥗проверка   if 🥗\(indexPath.row + 1)🥗 == 🥗\(photos.count)🥗 ")
        if indexPath.row + 1 == photos.count {
            print("🥗🥗🥗проверка   if indexPath.row == photos.count УСПЕХ")
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
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
    
   
}
