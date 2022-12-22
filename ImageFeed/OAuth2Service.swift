import Foundation

class OAuth2Service {
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://unsplash.com/oauth/token"
        guard let url = URL(string: urlString) else { return }
        
        let parameters = [
            "client_id": accessKey,
            "client_secret": secretKey,
            "redirect_uri": redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else { return }
        request.httpBody = httpBody
        
        DispatchQueue.main.async {
            let session = URLSession.shared.dataTask(with: request) { data, response, error in
                guard
                    let response = response as? HTTPURLResponse,
                    let data = data,
                    response.statusCode > 200 || response.statusCode <= 300 else { return }
                do {
                    let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(responseBody.accessTocken))
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
            session.resume()
        }
    }
}
