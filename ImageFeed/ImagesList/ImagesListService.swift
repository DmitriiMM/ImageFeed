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
        lastLoadedPage = lastLoadedPage == nil ? 1 : nextPage
        
        var request = URLRequest(url: URL(string: "/photos?page=\(nextPage)&&per_page=10", relativeTo: defaultBaseURL)!)
        request.httpMethod = "GET"
        
        let token = OAuth2TokenStorage().token!
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let photoResult):
                    var photosArray: [Photo] = []
                    for photo in photoResult {
                        let onePhoto = Photo(photoResult: photo)
                        photosArray.append(onePhoto)
                    }
                    self.photos.append(contentsOf: photosArray)
                    
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": self.photos])
                case .failure(let error):
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "/photos/\(photoId)/like", relativeTo: defaultBaseURL)!)
        let token = OAuth2TokenStorage().token!
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        if isLike {
            request.httpMethod = "DELETE"
        } else {
            request.httpMethod = "POST"
        }
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<LikedPhotoResult, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let photoResult):
                    
                    let newPhoto = LikedPhoto(likedPhotoResult: photoResult)
                    
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        var photo = self.photos[index]
                        photo.isLiked = newPhoto.likedPhoto.isLiked
                        self.photos.remove(at: index)
                        self.photos.insert(photo, at: index)
                        
                        completion(.success(()))
                    }
                case .failure(let error):
                    completion(.failure(error))
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
    var isLiked: Bool
    
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

struct LikedPhoto {
    var likedPhoto: PhotoResult
    init(likedPhotoResult: LikedPhotoResult) {
        likedPhoto = likedPhotoResult.likedPhoto
    }
}
