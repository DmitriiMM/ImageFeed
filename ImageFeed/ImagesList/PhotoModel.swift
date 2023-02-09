import Foundation

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
