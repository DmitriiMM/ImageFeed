import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(profileResult: ProfileResponseBody) {
        username = profileResult.username ?? "User name"
        name = (profileResult.firstName ?? "Profile owner First name") + " " + (profileResult.lastName ?? "Profile owner Last name")
        loginName = "@" + (profileResult.username ?? "Link")
        bio = profileResult.bio ?? "Profile's description"
    }
}
