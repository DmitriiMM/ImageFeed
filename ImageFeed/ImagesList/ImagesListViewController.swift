import UIKit

class ImagesListViewController: UIViewController {
    private var photosNames = [String]()
    
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        photosNames = Array(0..<20).map{ "\($0)" }
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
        guard let image = UIImage(named: photosNames[indexPath.row]) else { return }
        cell.imageCell.image = image
        cell.dateLabelCell.text = dateFormatter.string(from: Date())
        
        if indexPath.row % 2 != 0 {
            cell.likeButtonCell.imageView?.image = UIImage(named: "Active")
        } else {
            cell.likeButtonCell.imageView?.image = UIImage(named: "NoActive")
        }
        
        configGradient(for: cell)
    }
}

extension ImagesListViewController: UITableViewDelegate {}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosNames.count
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
