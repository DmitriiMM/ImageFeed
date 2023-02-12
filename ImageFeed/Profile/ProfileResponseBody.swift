import Foundation

struct ProfileResponseBody: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        username = try? container.decode(String.self, forKey: .username)
        firstName = try? container.decode(String.self, forKey: .firstName)
        lastName = try? container.decode(String.self, forKey: .lastName)
        bio = try? container.decode(String.self, forKey: .bio)
    }
    
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
}

private enum CodingKeys: String, CodingKey {
    case username = "username"
    case firstName = "first_name"
    case lastName = "last_name"
    case bio = "bio"
}
