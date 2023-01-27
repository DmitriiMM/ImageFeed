import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        imagesListViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Images", comment: ""),
            image: UIImage(systemName: "rectangle.stack.fill"),
            selectedImage: nil
        )
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Profile", comment: ""),
            image: UIImage(systemName: "person.crop.circle.fill"),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}

