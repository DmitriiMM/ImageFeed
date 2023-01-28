import Foundation

final class ImagesListService {
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        let request = makeRequest(path: "/photos", httpMethod: "GET", baseURL: defaultBaseURL!)
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in
            DispatchQueue.main.async {
                guard self != nil else { return }
                switch result {
                case .success(let photoResult):
                    let photo = Photo(photoResult: photoResult)
                    self?.photos.append(photo)
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": self?.photos])
                case .failure(_):
                    break
                }
            }
        }
        if self.task == nil {
            task.resume()
        }
    }
    
    private func makeRequest(path: String, httpMethod: String, baseURL: URL = defaultBaseURL!) -> URLRequest {
        let nextPage = lastLoadedPage == nil
        ? 1
        : lastLoadedPage! + 1
        
        let parameters = [
            "page": nextPage,
            "per_page": 10
        ]
        
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else { fatalError("Failed to parse data") }
        request.httpBody = httpBody
        return request
    }
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
        welcomeDescription = photoResult.description
        thumbImageURL = photoResult.urls.thumbImageURL
        largeImageURL = photoResult.urls.largeImageURL
        isLiked = photoResult.isLiked
    }
}
