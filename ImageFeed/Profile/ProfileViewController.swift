import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    private lazy var profileImageView: UIImageView = {
        let image = UIImage(systemName: "person.crop.circle.fill")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .gray
        return imageView
    }()
    
    private lazy var profileNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = UIColor(named: "YP White")
        return label
    }()
    
    private lazy var profileLinkLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP Grey")
        return label
    }()
    
    private lazy var profileDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP White")
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
        return button
    }()
    
    private var profileImageServiceObserver: NSObjectProtocol?
       
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        
        addSubViews()
        addConstraints()
        
        guard let profile = profileService.profile else { return }
        updateProfileDetails(profile: profile)
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let avatarURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: avatarURL)
        else { return }
        profileImageView.kf.setImage(with: url, options: [
            .processor(RoundCornerImageProcessor(cornerRadius: 16, backgroundColor: .clear)),
            .cacheSerializer(FormatIndicatedCacheSerializer.png)
        ])
        profileImageView.clipsToBounds = true
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
    
    @objc private func logOutButtonTapped(_ sender: Any) { }
    
    func updateProfileDetails(profile: Profile) {
        self.profileNameLabel.text = profile.name
        self.profileLinkLabel.text = profile.loginName
        self.profileDescriptionLabel.text = profile.bio
    }
}
