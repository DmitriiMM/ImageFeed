import Foundation

struct UserResult: Decodable {
    let profileImage: Size
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct Size: Decodable {
    let smallProfileImageUrlString: String
    
    enum CodingKeys: String, CodingKey {
        case smallProfileImageUrlString = "small"
    }
}
