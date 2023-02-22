import UIKit
import Kingfisher
import WebKit

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func updateAvatar()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    private let profileService = ProfileService.shared
    let tokenStorage = OAuth2TokenStorage()
    private var animationLayers = Set<CALayer>()
    private let gradient = CAGradientLayer()
    private let gradientForNameLabel = CAGradientLayer()
    private let gradientForLinkLabel = CAGradientLayer()
    private let gradientForDescriptionLabel = CAGradientLayer()
    private let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
    
    private lazy var profileImageView: UIImageView = {
        let image = UIImage(systemName: "person.crop.circle.fill")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .gray
        
        //MARK: - Gradient for Image View
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        imageView.layer.addSublayer(gradient)
        
        return imageView
    }()
    
    private lazy var profileNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = UIColor(named: "YP White")
        
        //MARK: - Gradient for NAME Label
        gradientForNameLabel.frame = CGRect(origin: CGPoint(x: 0, y: 10), size: CGSize(width: 300, height: 18))
        gradientForNameLabel.locations = [0, 0.1, 0.3]
        gradientForNameLabel.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientForNameLabel.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForNameLabel.endPoint = CGPoint(x: 1, y: 0.5)
        gradientForNameLabel.cornerRadius = 9
        gradientForNameLabel.masksToBounds = true
        animationLayers.insert(gradientForNameLabel)
        label.layer.insertSublayer(gradientForNameLabel, at: 0)
        
        return label
    }()
    
    private lazy var profileLinkLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP Grey")
        
        //MARK: - Gradient for LINK Label
        gradientForLinkLabel.frame = CGRect(origin: CGPoint(x: 0, y: -1), size: CGSize(width: 150, height: 18))
        gradientForLinkLabel.locations = [0, 0.1, 0.3]
        gradientForLinkLabel.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientForLinkLabel.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForLinkLabel.endPoint = CGPoint(x: 1, y: 0.5)
        gradientForLinkLabel.cornerRadius = 9
        gradientForLinkLabel.masksToBounds = true
        animationLayers.insert(gradientForLinkLabel)
        label.layer.insertSublayer(gradientForLinkLabel, at: 0)
        
        return label
    }()
    
    private lazy var profileDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP White")
        
        //MARK: - Gradient for DESCRIPTION Label
        gradientForDescriptionLabel.frame = CGRect(origin: .zero, size: CGSize(width: 120, height: 18))
        gradientForDescriptionLabel.locations = [0, 0.1, 0.3]
        gradientForDescriptionLabel.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientForDescriptionLabel.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForDescriptionLabel.endPoint = CGPoint(x: 1, y: 0.5)
        gradientForDescriptionLabel.cornerRadius = 9
        gradientForDescriptionLabel.masksToBounds = true
        animationLayers.insert(gradientForDescriptionLabel)
        label.layer.insertSublayer(gradientForDescriptionLabel, at: 0)
        
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let image = UIImage(named: "Exit")
        let button = UIButton.systemButton(
            with: image ?? UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(logOutButtonTapped)
        )
        button.tintColor = UIColor(named: "YP Red")
        button.accessibilityIdentifier = "logoutButton"
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        
        animateGradients()
        addSubViews()
        addConstraints()
        
        presenter?.viewDidLoad()
        
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
    }
    
    func updateAvatar() {
        guard
            let avatarURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: avatarURL)
        else { return }
        
        profileImageView.kf.setImage(with: url, options: [
            .processor(RoundCornerImageProcessor(cornerRadius: 16, backgroundColor: .clear)),
            .cacheSerializer(FormatIndicatedCacheSerializer.png)
        ])
        profileImageView.clipsToBounds = true
        removeGradient()
    }
    
    private func animateGradients() {
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        gradientForNameLabel.add(gradientChangeAnimation, forKey: "locationsChange")
        gradientForLinkLabel.add(gradientChangeAnimation, forKey: "locationsChange")
        gradientForDescriptionLabel.add(gradientChangeAnimation, forKey: "locationsChange")
        
    }
    
    private func addConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        profileLinkLabel.translatesAutoresizingMaskIntoConstraints = false
        profileDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            profileNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            profileNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            
            profileLinkLabel.topAnchor.constraint(equalTo: profileNameLabel.bottomAnchor, constant: 8),
            profileLinkLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            
            profileDescriptionLabel.topAnchor.constraint(equalTo: profileLinkLabel.bottomAnchor, constant: 8),
            profileDescriptionLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private func addSubViews() {
        view.addSubview(profileImageView)
        view.addSubview(profileNameLabel)
        view.addSubview(profileLinkLabel)
        view.addSubview(profileDescriptionLabel)
        view.addSubview(logoutButton)
    }
    
    @objc private func logOutButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let completion: (UIAlertAction) -> Void = { [weak self] _ in

            self?.tokenStorage.token = nil
            self?.clean()
            guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
            window.rootViewController = SplashViewController()
            window.makeKeyAndVisible()
        }
        
        let actionYes = UIAlertAction(title: "Да", style: .cancel, handler: completion)
        let actionNo = UIAlertAction(title: "Нет", style: .default)
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        
        alert.restorationIdentifier = "Пока, пока!"
        actionYes.accessibilityIdentifier = "Yes"
        
        self.present(alert, animated: true)
    }
    
    private func updateProfileDetails(profile: Profile) {
        self.profileNameLabel.text = profile.name
        self.profileLinkLabel.text = profile.loginName
        self.profileDescriptionLabel.text = profile.bio
    }
    
    private func removeGradient() {
        self.animationLayers.removeAll()
        self.gradient.removeFromSuperlayer()
        self.gradientForNameLabel.removeFromSuperlayer()
        self.gradientForLinkLabel.removeFromSuperlayer()
        self.gradientForDescriptionLabel.removeFromSuperlayer()
    }
}

extension ProfileViewController: WebViewViewControllerCleanDelegate {
    func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
