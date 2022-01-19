//
//  APIResponse.swift
//  prac-swiftui-with-websocket
//
//  Created by Theo on 2022/01/19.
//

import Foundation

struct APIResponse: Codable {
    var data: [PriceData]
    var type : String
    
    private enum CodingKeys: String, CodingKey {
        case data, type
    }
}

struct PriceData : Codable{
    
    public var p: Float
    
    private enum CodingKeys: String, CodingKey {
        case p
    }
}
