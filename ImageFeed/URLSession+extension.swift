import Foundation



extension URLSession {
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let fulfillCompletionOnMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200 ..< 300 ~= statusCode {
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(T.self, from: data)
                            
                            fulfillCompletionOnMainThread(.success(result))
                        } catch {
                            fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
                        }
                    } else {
                        fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
                } else if let error = error {
                    fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
                } else {
                    fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
                }
            }
        })
        task.resume()
        return task
    }
}

private enum NetworkError: Error {
    case urlRequestError(Error)
    case urlSessionError
    case httpStatusCode (Int)
}

