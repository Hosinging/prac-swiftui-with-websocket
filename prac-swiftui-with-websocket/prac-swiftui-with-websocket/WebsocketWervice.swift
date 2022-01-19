//
//  WebsocketWervice.swift
//  prac-swiftui-with-websocket
//
//  Created by Theo on 2022/01/19.
//

import Foundation
import Combine

class WebSocketService: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let baseURL = URL(string: "wss/ws.finnhub.io?token=XYZ")!
    
    let didChange = PassthroughSubject<Void, Never>()
    @Published var price: String = ""
    
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
    
    func connect() {
        stop()
        webSocketTask = URLSession.shared.webSocketTask(with: baseURL)
        webSocketTask?.resume()
        
    }
    
    func stop() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    func sendMessage() {
        let string = "{\"type\":\"subscribe\",\"symbol\":\"BINANCE:BTCUSDT\"}"
        
        let message = URLSessionWebSocketTask.Message.string(string)
        webSocketTask?.send(message, completionHandler: { error in
            if let error = error {
                print("Websocket couldn't send message because: \(error.localizedDescription)")
            }
        })
    }
    
    private func receiveMessage() {
        webSocketTask?.receive(completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(.string(let str)):
                
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: Data(str.utf8))
                    DispatchQueue.main.async {
                        self?.price = "\(result.data[0].p)"
                    }
                } catch {
                    print("error is \(error.localizedDescription)")
                }
                self?.receiveMessage()
                
            default:
                print("default")
            }
        
        })
    }
}
