import Foundation

struct PhotoResult: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        description = try container.decode(String.self, forKey: .description)
        urls = try container.decode(Urls.self, forKey: .urls)
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
    }
    
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let description: String
    let urls: Urls
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case width = "width"
        case height = "height"
        case createdAt = "created_at"
        case description = "description"
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
