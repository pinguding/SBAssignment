//
//  NetworkClientInterface.swift
//
//
//  Created by 박종우 on 9/16/24.
//

import Foundation

final class SBNetworkClientInterface: SBNetworkClient {
    
    /// Sendbird User Manager SDK 에서 서버호출을 공통적으로 담당할 URLSession
    static private let session: URLSession = URLSession(configuration: .default)
    
    /// Request Timeout 시간
    private let defaultTimeoutInterval: TimeInterval = 30
   
    /// 1초에 요청할 수 있는 Request 의 제한 수
    private let requestsPerSecondLimit: Int = 1
    
    /// Request 제한을 위해 만든 OperationQueue
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
            
            /// Request Limit 을 위해 바로 dataTask 를 resume() 하지 않고 OperationQueue에 넣어 OperationQueue에서 관리할 수 있도록 만든다.
            /// SBDataTaskOperation은 Request 제한 사항을 위해 만들어진 Custom Operation
            /// - Parameters:
            ///    - requestsPerSecondLimit : 1초당 생성할 수 있는 request limit 숫자
            ///    - dataTask : Custom operation 에서 처리할 URLSessionDataTask
            let taskOperation = SBDataTaskOperation(requestsPerSecondLimit: requestsPerSecondLimit, dataTask: dataTask)
            operationQueue.addOperation(taskOperation)
            
        } catch let error {
            completionHandler(.failure(error))
        }
    }
    
    ///Request Abstract을 URLRequest 형태로 변경해주는 함수
    ///- Parameters:
    /// - request: Request protocol 을 만족하는 객체
    /// - cachePolicy: URLRequest 의 CachePolicy를 지정할 수 있다. Default value 는 .useProtocolCachePolicy
    /// - timeoutInterval: URLRequest 의 Timeout 을 지정한다.
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
    
    ///Operation 종료에 Delay를 걸어주기 위해 Custom으로 정의
    override var isFinished: Bool {
        isDelayed && super.isFinished
    }
    
    init(requestsPerSecondLimit: Int, dataTask: URLSessionDataTask) {
        self.requestsPerSecondLimit = requestsPerSecondLimit
        self.dataTask = dataTask
    }
    
    ///Operation이 Cancel 될때 URLSessionDataTask 도 같이 Cancel 해준다.
    override func cancel() {
        dataTask.cancel()
    }

    override func main() {
        if isCancelled { return }
        dataTask.resume()
        
        ///Request Limit per second 조건을 만족시키기 위해 asyncAfter 를 이용한 딜레이 로직
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + (1.0 / Double(requestsPerSecondLimit))) { [weak self] in
            self?.willChangeValue(for: \.isFinished)
            self?.isDelayed = true
            self?.didChangeValue(for: \.isFinished)
        }
    }
}
