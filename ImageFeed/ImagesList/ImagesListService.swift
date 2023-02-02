import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if task != nil { return }
        task?.cancel()
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        var request = URLRequest(url: URL(string: "/photos?page=\(nextPage)&&per_page=10", relativeTo: defaultBaseURL)!)
        request.httpMethod = "GET"
        
        let token = OAuth2TokenStorage().token!
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("🚜🚜🚜 \(String(describing: request.allHTTPHeaderFields))")
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async { [weak self] in
                print("🚛🚛🚛srart write task")
                guard let self else { return }
                print("🚗🚗🚗self == nil")
                switch result {
                case .success(let photoResult):
                    print("🥐🥐🥐\(photoResult)")
                    var photoss: [Photo] = []
                    print("🥐🥐🥐\(photoss)")
                    for photo in photoResult {
                        let onePhoto = Photo(photoResult: photo)
                        photoss.append(onePhoto)
                    }
                    self.photos = photoss
                    print("🫒🫒🫒array ImagesListService.shared.photos finished \(ImagesListService.shared.photos)")
                    
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": self.photos])
                    print("🧀🧀🧀\(NotificationCenter.default)")
                case .failure(let error):
                    print(error)
                }
            }
        }
        task.resume()
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        createdAt = photoResult.createdAt
        welcomeDescription = photoResult.welcomeDescription
        thumbImageURL = photoResult.urls.thumbImageURL
        largeImageURL = photoResult.urls.largeImageURL
        isLiked = photoResult.isLiked
    }
}
