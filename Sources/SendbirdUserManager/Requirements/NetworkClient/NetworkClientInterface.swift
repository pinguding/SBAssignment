//
//  NetworkClientInterface.swift
//
//
//  Created by 박종우 on 9/16/24.
//

import Foundation

final class SBNetworkClientInterface: SBNetworkClient {
    
    static private let session: URLSession = URLSession(configuration: .default)
    
    private let defaultTimeoutInterval: TimeInterval = 30
   
    private let requestsPerSecondLimit: Int = 1
    
    private let operationQueue: OperationQueue
        
    init() {
        operationQueue = .init()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
    }
    
    deinit {
        operationQueue.cancelAllOperations()
    }
    
    func request<R>(request: R, completionHandler: @escaping (Result<R.Response, any Error>) -> Void) where R : Request {
        do {
            let urlRequest = try urlRequest(createdFrom: request, timeoutInterval: defaultTimeoutInterval)
            
            let dataTask = SBNetworkClientInterface.session.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
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
            }
            
            let taskOperation = SBDataTaskOperation(requestsPerSecondLimit: requestsPerSecondLimit, dataTask: dataTask)
            operationQueue.addOperation(taskOperation)
            
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

private class SBDataTaskOperation: Operation, @unchecked Sendable {
    
    private let dataTask: URLSessionDataTask
    
    private let requestsPerSecondLimit: Int
    
    private var isDelayed: Bool = false
    
    override var isFinished: Bool {
        isDelayed && super.isFinished
    }
    
    init(requestsPerSecondLimit: Int, dataTask: URLSessionDataTask) {
        self.requestsPerSecondLimit = requestsPerSecondLimit
        self.dataTask = dataTask
    }
    
    override func cancel() {
        dataTask.cancel()
    }

    override func main() {
        if isCancelled { return }
        dataTask.resume()
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + (1.0 / Double(requestsPerSecondLimit))) { [weak self] in
            self?.willChangeValue(for: \.isFinished)
            self?.isDelayed = true
            self?.didChangeValue(for: \.isFinished)
        }
    }
}
