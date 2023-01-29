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
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard self != nil else { return }
                switch result {
                case .success(let photoResult):
                    for photo in photoResult {
                        let onePhoto = Photo(photoResult: photo)
                        ImagesListService.shared.photos.append(onePhoto)
                    }
                    
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": ImagesListService.shared.photos])
                case .failure(let error):
                    print(error)
                }
            }
        }
        task.resume()
    }
    
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
            welcomeDescription = photoResult.welcomeDescription
            thumbImageURL = photoResult.urls.thumbImageURL
            largeImageURL = photoResult.urls.largeImageURL
            isLiked = photoResult.isLiked
        }
    }
}
