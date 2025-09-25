//
//  APIRequest.swift
//  GeoDBExplorer
//
//  Created by Seda Kirakosyan on 25.09.25.
//

import Foundation

protocol APIRequest {
    associatedtype Response: Decodable
    var path: String { get }
    var query: [URLQueryItem] { get }
    var method: String { get } 
}

extension APIRequest {
    var method: String { "GET" }
}
