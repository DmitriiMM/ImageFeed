import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var task: URLSessionTask?
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        print("🟢🔴🟢🔴🟢🔴🟢🔴🟢 fetchPhotosNextPage() if task != nil start")
        if task != nil { return }
        task?.cancel()
        print("🟢🟢🟢🟢🟢 fetchPhotosNextPage.task != nil  ОКОКОКОКОКОК")
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
                    print("🧲🔆♻️🧲🔆♻️🧲🔆♻️ fetchPhotosNextPage.success")
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
                    print("Ⓜ️🆗🈳🎦Ⓜ️🆗🈳🎦 fetchPhotosNextPage.failure")
                    print(error)
                }
            }
        }
        print("🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢 fetchPhotosNextPage.task.resume()")
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "/photos/\(photoId)/like", relativeTo: defaultBaseURL)!)
        let token = OAuth2TokenStorage().token!
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥❤️‍🔥 isLike - \(isLike)")
        if isLike {
            request.httpMethod = "DELETE"
        } else {
            request.httpMethod = "POST"
        }
        
        print("🧲🧲🧲 request.allHTTPHeaderFields - \(request.allHTTPHeaderFields)")
        print("🧲🧲🧲 request.url - \(request.url)")
        print("🧲🧲🧲 request.httpBody - \(request.httpBody)")
        print("🧲🧲🧲 request.httpMethod - \(request.httpMethod)")
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<LikedPhotoResult, Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let photoResult):
                    print("❤️❤️❤️ photoResult - \(photoResult)")
                    
                    let newPhoto = LikedPhoto(likedPhotoResult: photoResult)
                    print("🧡🧡🧡 newPhoto - \(newPhoto)")
//                    newPhoto.likedPhoto.isLiked.toggle()
//                    let encodePhotoResult = try JSONEncoder().encode(newPhoto)
                    
                  
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        var photo = self.photos[index]
                        print("💛💛💛 photo for index \(index) - \(photo)")
                       
//                        let replacingPhoto = Photo(photoResult: encodePhotoResult)
                        photo.isLiked = newPhoto.likedPhoto.isLiked
                        
                        self.photos.remove(at: index)
                        self.photos.insert(photo, at: index)
                        
                        print("💚💚💚 photo.isLiked - \(photo.isLiked)")
                        print("💚💚💚 photos - \(self.photos)")
                        completion(.success(()))
                    }
                case .failure(let error):
                    completion(.failure(error))
                    print("🧨🧨🧨 \(error)")
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
