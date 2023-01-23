import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == username { return }
                task?.cancel()
                lastCode = username
        let requestUrlString = defaultBaseURL!.absoluteString + "/users/\(username)"
        guard let requestUrl = URL(string: requestUrlString) else { return }
        var request = URLRequest(url: requestUrl)
        request.setValue("Bearer \(String(describing: OAuth2TokenStorage().token))", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard self != nil else { return }
                switch result {
                case .success(let user):
                    self?.avatarURL = user.profileImage.smallProfileImageUrlString
                    guard let avatarURL = self?.avatarURL else { return }
                    completion(.success(avatarURL))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
        
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: self,
            userInfo: ["URL": avatarURL as Any])
    }
}
