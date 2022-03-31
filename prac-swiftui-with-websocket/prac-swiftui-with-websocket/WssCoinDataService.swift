//
//  ws2.swift
//  prac-swiftui-with-websocket
//
//  Created by Theo on 2022/02/01.
//

import Foundation
import Combine

class WssCoinDataService: ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()
    @Published var price: String = ""
    //
    @Published var allCoins: [RealTimeCoinData] = []
    
    private let urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?
    
    private let baseURL = URL(string: "wss://pubwss.bithumb.com/pub/ws")!
    private var cancellable: AnyCancellable? = nil
    
    var priceResult: String = "" {
        didSet {
            didChange.send()
        }
    }
    
    init() {
        cancellable = AnyCancellable(
            $price
                .debounce(for: 0.5, scheduler: DispatchQueue.main)
                .removeDuplicates()
                .assign(to: \.priceResult, on: self)

            
        )
    }
    
    func connect(symbols: [String], tickTypes: [String]) {
        stop()
        webSocketTask = urlSession.webSocketTask(with: baseURL)
        webSocketTask?.resume()
        sendMessage(symbols: symbols, tickTypes: tickTypes)
        receiveMessage()
    }
    
    func stop() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func convertJSON(symbols: [String], tickTypes: [String]) -> Data? {
        let dic = Ticker(symbols: symbols, tickTypes: tickTypes)
        guard let jsonData = try? JSONEncoder().encode(dic) else { return nil }
        return jsonData
    }
    
    private func sendMessage(symbols: [String], tickTypes: [String]) {
        guard let jsonData = convertJSON(symbols: symbols, tickTypes: tickTypes) else { return }
        let message = URLSessionWebSocketTask.Message.data(jsonData)
        
        webSocketTask?.send(message, completionHandler: { error in
            if let error = error {
                print("\(error)때문에 Websocket이 메시지를 보낼 수 없습니다.")
            }
        })
    }
    
    private func receiveMessage() {
        webSocketTask?.receive(completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                print("메시지 수신 오류: \(error) ")
            case .success(.string(let message)):
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: Data(message.utf8))
                    var openPriceValue = 0
                    var changePriceValue = 0
                    if let openPriceString = result.content?.openPrice, let openPrice = Int(openPriceString),
                       let changePriceString = result.content?.chgAmt, let changePrice = Int(changePriceString) {
                        openPriceValue = openPrice
                        changePriceValue = changePrice
                    }
                    DispatchQueue.main.async {
                        self?.price = "\(openPriceValue + changePriceValue)"
                    }
                } catch {
                    print("디코딩 중 \(String(describing: error))에러 발생")
                }
                self?.receiveMessage()
                
           @unknown
            default:
                print("default")
            }
        })
    }
    
}

