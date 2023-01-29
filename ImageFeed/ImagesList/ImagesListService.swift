import Foundation

final class ImagesListService {
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage(_ completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil { return }
        print("🥎   🥎   🥎\(String(describing: task))")
        task?.cancel()
        
        var request = URLRequest(url: URL(string: "/photos?page=1&&per_page=10", relativeTo: defaultBaseURL)!)
        request.httpMethod = "GET"
//        request.setValue("Bearer \(String(describing: OAuth2TokenStorage().token))", forHTTPHeaderField: "Authorization")
                let nextPage = lastLoadedPage == nil
                ? 1
                : lastLoadedPage! + 1
//                let parameters = [
//                    "page": nextPage,
//                    "per_page": 1
//                ]
//        var urlComponents = URLComponents()
//        urlComponents.scheme = "https"
//        urlComponents.host = "api.unsplash.com"
//        urlComponents.path = "/photos"
//        urlComponents.queryItems = [
//            URLQueryItem(name: "page", value: String(nextPage)),
//           URLQueryItem(name: "per_page", value: "10")
//        ]
//        print(urlComponents.url?.absoluteString)
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResult):
                    print("🥎\(photoResult)")
                    for photo in photoResult {
                       let photoOne = Photo(photoResult: photo)
                        self?.photos.append(photoOne)
                    }
                   
                    completion(.success(self!.photos))
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": self?.photos])
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
//        func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
//            assert(Thread.isMainThread)
//            if lastCode == username { return }
//                    task?.cancel()
//                    lastCode = username
//            let request = makeRequest(path: "/users/\(username)", httpMethod: "GET", baseURL: defaultBaseURL!)
//
//            let session = URLSession.shared
//            let task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
//                DispatchQueue.main.async {
//                    guard self != nil else { return }
//                    switch result {
//                    case .success(let user):
//                        self?.avatarURL = user.profileImage.smallProfileImageUrlString
//                        guard let avatarURL = self?.avatarURL else { return }
//                        completion(.success(avatarURL))
//                        NotificationCenter.default
//                            .post(
//                                name: ProfileImageService.didChangeNotification,
//                                object: self,
//                                userInfo: ["URL": avatarURL])
//                    case .failure(let error):
//                        completion(.failure(error))
//                    }
//                }
//            }
//            self.task = task
//            task.resume()
//        }
    
    
    
    
    
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: Date?
        let welcomeDescription: String?
        let thumbImageURL: String
        let largeImageURL: String
        let isLiked: Bool
        
        init(photoResult: PhotoResult) {
            id = photoResult.id
            size = CGSize(width: photoResult.width, height: photoResult.height)
            createdAt = DateFormatter().date(from: photoResult.createdAt)
            welcomeDescription = photoResult.description
            thumbImageURL = photoResult.urls.thumbImageURL
            largeImageURL = photoResult.urls.largeImageURL
            isLiked = photoResult.isLiked
        }
    }
}
