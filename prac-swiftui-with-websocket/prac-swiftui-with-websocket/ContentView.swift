//
//  ContentView.swift
//  prac-swiftui-with-websocket
//
//  Created by Theo on 2022/01/19.
//

import SwiftUI
import Combine
import Foundation

struct ContentView: View {
    @ObservedObject var service = WssCoinDataService()
    
    var body: some View {
//        VStack {
//            Image(systemName: "bitcoinsign.circle.fill")
//                .font(.system(size: 150))
//                .foregroundColor(Color.orange)
//                .padding()
//
//            Text("USD")
//                .font(.largeTitle)
//                .padding()
//
//            Text(service.priceResult)
//
////            Image(systemName: "circle.fill")
////                .font(.system(size: 150))
////                .foregroundColor(Color.blue)
////                .padding()
////
////            Text("USD")
////                .font(.largeTitle)
////                .padding()
////
////            Text(service.priceResult)
//        }.onAppear {
//            self.service.connect()
//        }
        ZStack {
            VStack {
                Text(service.priceResult)
                Spacer(minLength: 0)
            }
            .onAppear {
                service.connect(symbols: ["BTC_KRW"], tickTypes: ["30M"])
            }
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
