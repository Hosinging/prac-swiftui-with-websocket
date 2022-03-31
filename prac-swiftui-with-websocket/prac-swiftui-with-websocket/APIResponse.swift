//
//  APIResponse.swift
//  prac-swiftui-with-websocket
//
//  Created by Theo on 2022/01/19.
//

import Foundation
//MARK: 원래 예제 모델
//
//struct APIResponse: Codable {
//    var data: [PriceData]
//    var type : String
//
//    private enum CodingKeys: String, CodingKey {
//        case data, type
//    }
//}
//
//struct PriceData : Codable{
//
//    public var p: Float
//
//    private enum CodingKeys: String, CodingKey {
//        case p
//    }
//}

//MARK: 빗썸테스트
struct APIResponse: Codable {
    var type : String?
    var content: RealTimeCoinData?
}

struct RealTimeCoinData : Codable { 
    var value: String
    var openPrice: String
    var chgAmt: String

//    private enum CodingKeys: String, CodingKey {
//        case p
//    }
}

struct Ticker: Codable {
    var type: String
    var symbols: [String]
    var tickTypes: [String]
    
    init(type: String = String(describing: Self.self).lowercased(), symbols: [String], tickTypes: [String]) {
        self.type = type
        self.symbols = symbols
        self.tickTypes = tickTypes
    }
}
