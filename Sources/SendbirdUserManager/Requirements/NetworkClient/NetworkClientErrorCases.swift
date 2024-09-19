//
//  File.swift
//  SendbirdUserManager
//
//  Created by 박종우 on 9/17/24.
//

import Foundation

public enum RequestError: LocalizedError {
    /// URL 생성 실패
    case badURL
    /// HTTP Body Encoding 실패
    case httpBodyEncodingFailure
    /// URL Query 추가 실패
    case queryItemAppendingFailure
    /// Request response Decoding 실패
    case responseDecodingFailure
    /// 서버로부터 에러 발생, 상세 내용은 data parameter 참고
    /// - Parameters:
    ///    - data: SBResponseErrorData. Server error response 가 담긴 객체이며 code, 와 message 를 통해 에러에 대한 정보를 확인할 수 있다.
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
