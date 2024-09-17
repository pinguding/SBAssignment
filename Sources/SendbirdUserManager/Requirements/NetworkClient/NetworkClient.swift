//
//  NetworkClient.swift
//  
//
//  Created by Sendbird
//

import Foundation

public enum SBHTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public protocol Request {
    associatedtype Response: Decodable
    
    var applicationId: String { get }
    
    var method: SBHTTPMethod { get }
    
    var baseURL: String { get }
    
    var path: String { get }
    
    var headerFields: [String: String] { get }
    
    var body: Data? { get }
    
    var queryItems: [URLQueryItem]? { get }
}

internal extension Request {
    
    var baseURL: String {
        "https://api-\(applicationId).sendbird.com/v3"
    }
}

public protocol SBNetworkClient {
    /// 리퀘스트를 요청하고 리퀘스트에 대한 응답을 받아서 전달합니다
    func request<R: Request>(
        request: R,
        completionHandler: @escaping (Result<R.Response, Error>) -> Void
    )
}
