import Foundation
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
            } else {
                KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
    
    private enum Keys: String {
        case token
    }
    
    func store(token: String) {
        self.token = token
    }
}
