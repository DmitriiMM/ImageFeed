import Foundation

class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            userDefaults.string(forKey: Keys.token.rawValue)
        }
        
        set {
            guard let data = newValue else {
                print("🥎🥎🥎Невозможно сохранить результат")
                return
            }
            print("🥎🥎🥎New setting value is \(String(describing: newValue))")
            userDefaults.set(data, forKey: Keys.token.rawValue)
        }
    }
    
    private enum Keys: String {
        case token
    }
    
    func store(token: String) {
        self.token = token
    }
}
