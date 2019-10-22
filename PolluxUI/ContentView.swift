//
//  ContentView.swift
//  PolluxUI
//
//  Created by Edward Arenberg on 10/10/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var showData: ShowData

    var body: some View {
        AdvertisingList(beaconDetector: BeaconDetector.shared.setData(data: showData))
//        .environmentObject(showData)
        

//        Text("Hello World")
//            .font(.title)
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
