import Foundation

struct LikedPhotoResult: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        likedPhoto = try container.decode(PhotoResult.self, forKey: .likedPhoto)
    }
    
    let likedPhoto: PhotoResult
    
    enum CodingKeys: String, CodingKey {
        case likedPhoto = "photo"
    }
}
struct PhotoResult: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        welcomeDescription = try container.decode(String?.self, forKey: .welcomeDescription)
        urls = try container.decode(Urls.self, forKey: .urls)
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
    }
    
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let welcomeDescription: String?
    let urls: Urls
    var isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case urls = "urls"
        case isLiked = "liked_by_user"
    }
}

struct Urls: Decodable {
    let thumbImageURL: String
    let largeImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case thumbImageURL = "thumb"
        case largeImageURL = "full"
    }
}
