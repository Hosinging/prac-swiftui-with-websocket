//
//  WebsocketWervice.swift
//  prac-swiftui-with-websocket
//
//  Created by Theo on 2022/01/19.
//

import Foundation
import Combine

class WebSocketService : ObservableObject {
    
    private let urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?
    
//    private let baseURL = URL(string: "wss://ws.finnhub.io?token=c7k0g3aad3i9q0uqe1g0")!
    //MARK: 빗썸테스트
    private let baseURL = URL(string: "wss://pubwss.bithumb.com/pub/ws")!
    
    let didChange = PassthroughSubject<Void, Never>()
    @Published var price: String = ""
    
    private var cancellable: AnyCancellable? = nil
    
    var priceResult: String = "" {
        didSet {
            didChange.send()
        }
    }
    
    
    init() {
        cancellable = AnyCancellable($price
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.priceResult, on: self))
        
    }

    func connect() {
        
        stop()
        webSocketTask = urlSession.webSocketTask(with: baseURL)
        webSocketTask?.resume()
        
        sendMessage()
        receiveMessage()
        //sendPing()
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { (error) in
            if let error = error {
                print("Sending PING failed: \(error)")
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 10) { [weak self] in
                self?.sendPing()
            }
        }
    }

    func stop() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func convertJSON() -> Data? {
        let dic = Ticker(symbols: ["BTC_KRW"], tickTypes: ["30M"])
        guard let jsonData = try? JSONEncoder().encode(dic) else {
            return nil
        }
        return jsonData
    }
    
    private func sendMessage()
    {
//        let string = "{\"type\":\"subscribe\",\"symbol\":\"BINANCE:BTCUSDT\"}"
        //MARK: 빗썸용
//        let string = "{\"type\":\"ticker\", \"symbols\": \(["BTC_KRW"]),\"tickTypes\": \(["30M"])}"
        
        
//        let message = URLSessionWebSocketTask.Message.string(string)
        guard let jsonData = convertJSON() else { return }
        let message = URLSessionWebSocketTask.Message.data(jsonData)
        
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive {[weak self] result in
            
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(.string(let str)):
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(APIResponse.self, from: Data(str.utf8))
                    DispatchQueue.main.async{
                        self?.price = "\(result.content?.value)"
                    }
                } catch  {
                    print("error is \(String(describing: error))")
                }
                
                self?.receiveMessage()
                
            default:
                print("default")
            }
        }
    }
    
}
