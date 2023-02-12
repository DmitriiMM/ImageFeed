import Foundation

final class ProfileService {
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private(set) var profile: Profile?
    static let shared = ProfileService()
    
    private init(task: URLSessionTask? = nil, lastCode: String? = nil, profile: Profile? = nil) {
        self.task = task
        self.lastCode = lastCode
        self.profile = profile
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == token { return }
                task?.cancel()
                lastCode = token
        let requestUrlString = defaultBaseURL!.absoluteString + "/me"
        guard let requestUrl = URL(string: requestUrlString) else { return }
        var request = URLRequest(url: requestUrl)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResponseBody, Error>) in
            DispatchQueue.main.async {
                guard self != nil else { return }
                switch result {
                case .success(let profileResult):
                    self?.profile = Profile(profileResult: profileResult)
                    guard let profile = self?.profile else { return }
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.task = task
    }
}
