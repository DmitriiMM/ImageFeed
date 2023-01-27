import Foundation

struct OAuthTokenResponseBody: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        accessTocken = try container.decode(String.self, forKey: .accessTocken)
        tockenType = try container.decode(String.self, forKey: .tockenType)
        scope = try container.decode(String.self, forKey: .scope)
        createdAt = try container.decode(Int.self, forKey: .createdAt)
    }
    
    let accessTocken: String
    let tockenType: String
    let scope: String
    let createdAt: Int
    
}

private enum CodingKeys: String, CodingKey {
    case accessTocken = "access_token"
    case tockenType = "token_type"
    case scope = "scope"
    case createdAt = "created_at"
}
