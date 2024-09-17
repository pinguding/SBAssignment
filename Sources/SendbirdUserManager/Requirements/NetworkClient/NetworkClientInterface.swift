//
//  NetworkClientInterface.swift
//
//
//  Created by 박종우 on 9/16/24.
//

import Foundation

final class SBNetworkClientInterface: SBNetworkClient {
    
    static private let session: URLSession = URLSession(configuration: .default)
    
    private let applicationId: String
    
    private let apiToken: String
    
    private let defaultTimeoutInterval: TimeInterval = 30
    
    private var sessionTaskStroage: [UUID: URLSessionDataTask] = [:]
    
    init(applicationId: String, apiToken: String) {
        self.applicationId = applicationId
        self.apiToken = apiToken
    }
    
    deinit {
        sessionTaskStroage.values.forEach { dataTask in
            dataTask.cancel()
        }
        sessionTaskStroage.removeAll()
    }
    
    func request<R>(request: R, completionHandler: @escaping (Result<R.Response, any Error>) -> Void) where R : Request {
        let taskId: UUID = .init()
        
        do {
            let urlRequest = try urlRequest(createdFrom: request, timeoutInterval: defaultTimeoutInterval)
            
            let dataTask = SBNetworkClientInterface.session.dataTask(with: urlRequest) { [weak self] data, response, error in
                if let error = error {
                    self?.sessionTaskStroage[taskId] = nil
                    completionHandler(.failure(error))
                    return
                }
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let data = data, let response = response as? HTTPURLResponse {
                    if (200...299) ~= response.statusCode {
                        do {
                            let dto = try decoder.decode(R.Response.self, from: data)
                            completionHandler(.success(dto))
                        } catch {
                            completionHandler(.failure(RequestError.responseDecodingFailure))
                        }
                    } else {
                        do {
                            let errorDto = try decoder.decode(SBResponseErrorData.self, from: data)
                            completionHandler(.failure(RequestError.responseError(data: errorDto)))
                        } catch {
                            completionHandler(.failure(RequestError.responseDecodingFailure))
                        }
                    }
                } else {
                    completionHandler(.failure(URLError(.badServerResponse)))
                }
                self?.sessionTaskStroage[taskId] = nil
            }
            
            sessionTaskStroage[taskId] = dataTask
            sessionTaskStroage[taskId]?.resume()
            
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    
    private func urlRequest<R: Request>(createdFrom request: R, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval) throws -> URLRequest {
        guard let url = URL(string: request.baseURL + request.path) else {
            throw RequestError.badURL
        }
        
        var urlReqeust = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval)
        
        urlReqeust.allHTTPHeaderFields = request.headerFields
        
        urlReqeust.httpMethod = request.method.rawValue
        
        switch request.method {
        case .GET, .DELETE:
            if let queryItems = request.queryItems {
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                let urlQueryItems = queryItems
                urlComponents?.queryItems = urlQueryItems
                
                if let queryAppenedURL = urlComponents?.url {
                    urlReqeust.url = queryAppenedURL
                } else {
                    throw RequestError.queryItemAppendingFailure
                }
            }
            
        case .POST, .PUT:
            if let body = request.body {
                urlReqeust.httpBody = body
            }
        }
        
        return urlReqeust
    }
}
