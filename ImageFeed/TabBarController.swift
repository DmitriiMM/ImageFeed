import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        imagesListViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "FolderNoActive"),
            selectedImage: UIImage(named: "FolderActive")
        )
        
        imagesListViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: -15, bottom: -15, right: -15)
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "PersonNoActive"),
            selectedImage: UIImage(named: "PersonActive")
        )
        
        profileViewController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: -15, bottom: -15, right: -15)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}

