import Foundation
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        
        set {
            guard let token = newValue else { return }
            KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
        }
    }
    
    private enum Keys: String {
        case token
    }
    
    func store(token: String) {
        self.token = token
    }
}
