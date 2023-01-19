import Foundation

class OAuth2Service {
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
                task?.cancel()
                lastCode = code
        let request = makeRequest(code: code)
        
        let session = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard
                    let response = response as? HTTPURLResponse,
                    let data = data,
                    response.statusCode > 200 || response.statusCode <= 300 else { return }
                do {
                    let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(responseBody.accessTocken))
                    self.task = nil
                    if error != nil {
                        self.lastCode = nil
                    }
                } catch {
                    print("\(error.localizedDescription)")
                }
            }
        }
        self.task = session
        session.resume()
    }
    
    private func makeRequest(code: String) -> URLRequest {
        let urlString = "https://unsplash.com/oauth/token"
        guard let url = URL(string: urlString) else { fatalError("Failed to create URL") }
        
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
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else { fatalError("Failed to parse data") }
        request.httpBody = httpBody
        return request
    }
}
