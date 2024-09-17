//
//  File.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/17/24.
//

import Foundation

public enum RequestError: LocalizedError {
    case badURL
    case httpBodyEncodingFailure
    case queryItemAppendingFailure
    case responseDecodingFailure
    case responseError(data: SBResponseErrorData)
    
    public var errorDescription: String? {
        switch self {
        case .badURL:
            return "Cannot create URL object. Please check again the baseURL and paths."
        case .httpBodyEncodingFailure:
            return "Fail to encoding httpBody parameters. Please check again request configuration."
        case .queryItemAppendingFailure:
            return "Fail to append query items at url. Please check again request configuration"
        case .responseDecodingFailure:
            return "Fail to decode server response. Please check response object to match with server response."
        case let .responseError(data):
            return data.message
        }
    }
}
