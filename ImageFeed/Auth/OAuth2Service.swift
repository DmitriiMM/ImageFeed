import Foundation

final class OAuth2Service {
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        let request = makeRequest(code: code)
        
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard self != nil else { return }
                switch result {
                case .success(let responseBody):
                    let authToken = responseBody.accessToken
                    completion(.success(authToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.task = task
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
