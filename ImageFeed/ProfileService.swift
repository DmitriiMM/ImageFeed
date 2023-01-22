import Foundation

struct ProfileResult: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        username = try container.decode(String.self, forKey: .username)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        bio = try container.decode(String.self, forKey: .bio)
    }
    
    let username: String
    let firstName: String
    let lastName: String
    let bio: String
    
    private enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(profileResult: ProfileResult) {
        username = profileResult.username
        name = profileResult.firstName + " " + profileResult.lastName 
        loginName = "@" + profileResult.username
        bio = profileResult.bio
    }
}

final class ProfileService {
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private(set) var profile: Profile?
    static let shared = ProfileService()
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == token { return }
                task?.cancel()
                lastCode = token
        let requestUrlString = defaultBaseURL!.absoluteString + "/me"
        guard let requestUrl = URL(string: requestUrlString) else { return }
        var request = URLRequest(url: requestUrl)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode)
                else { return }
                do {
                    let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                    self.profile = Profile(profileResult: profileResult)
                    print("🍔\(self.profile)")
                    guard let profile = self.profile else { return }
                    completion(.success(profile))
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        self.task = task
        task.resume()
    }
}
