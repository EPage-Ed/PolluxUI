//
//  AdvertisingList.swift
//  PolluxUI
//
//  Created by Edward Arenberg on 10/10/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import SwiftUI

struct AdvertisingList: View {
//    @State var showId : Int = 0
    @EnvironmentObject var showData: ShowData
    @ObservedObject var beaconDetector: BeaconDetector
    @State private var showActionSheet = false
    @State private var showList = false

//    init() {
//        beaconDetector = BeaconDetector(show: showData)
//    }

    var body: some View {
        NavigationView {
            List {
                GeometryReader { geometry in
                    HStack {
                        Text(self.showData.showTitle)
                            .font(.largeTitle)
                            //                    .edgesIgnoringSafeArea(.all)
                            //                    .frame(minWidth: 0, maxWidth: .infinity)
                            .padding([.leading,.trailing], 20.0)
                        Spacer()
                        Text(self.showData.showTime.toTime())
                            .font(.system(size: 20))
                            .padding([.trailing], 20.0)
                    }
                    .background(Color.gray)
                    .frame(minWidth: 0, maxWidth: .infinity)
//                    .frame(width: geometry.size.width,
//                        height: nil,
//                        alignment: .leading)
                }
                ForEach(showData.advertisements) { ad in
                    AdvertisementRow(advertisement: ad)
                }
            }
            .navigationBarTitle(
                Text("Gemini")
                
            )
            .navigationBarItems(
                leading:
                Button(action: {
                    self.showList = true
                }) {
                    Image(systemName: "list.bullet")
                }
                .font(.largeTitle)
                .sheet(isPresented: $showList) {
                    HistoryList()
                }
                
                ,
                
                trailing:
                Button(action: {
                    self.showActionSheet = true
                }) {
                    Image(systemName: "gear")
                }
                .font(.largeTitle)
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(
                        title: Text("Age"),
//                        message: Text("Available actions"),
                        buttons: [
                            .cancel { print(self.showActionSheet) },
                            .default(Text("9")) {
                                print("Act 1")
                                self.showData.age = 9
                            },
                            .default(Text("36")) {
                                print("Act 2")
                                self.showData.age = 36
                            },
                            .default(Text("56")) {
                                print("Act 3")
                                self.showData.age = 56
                            }
//                            .destructive(Text("Delete"))
                        ]
                    )
                }
                    
//                .alert(isPresented: $showingAlert) {
//                    Alert(title: Text("Age Range"), primaryButton: <#T##Alert.Button#>, secondaryButton: <#T##Alert.Button#>)
//                    Alert(title: Text("Age Range"), message: Text("Wear sunscreen"), dismissButton: .default(Text("Got it!")))
//            }
            )
        }
//        .onAppear(perform: showData.fetch)
        .onAppear() {
//            beaconDetector = BeaconDetector(show: showData)
        }
    }
    
}

struct AdvertisingList_Previews: PreviewProvider {
    static var previews: some View {
        var ad = Advertisement(key: "x")
        ad.displayTime = 20
        ad.action = "Info"
        ad.linkurl = "http://google.com"
        ad.message = "Get info on the best thing since sliced bread."
        ad.show = "Inception"

        let showData = ShowData()
        showData.advertisements = [ad]
        showData.showTime = Date().timeIntervalSinceReferenceDate
        showData.showTitle = "Inception"

        let list = AdvertisingList(beaconDetector: BeaconDetector()).environmentObject(showData)
        
        return list
    }
}


// import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let request: URLRequest
    
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        uiView.load(request)
    }
}

#if DEBUG
struct PostWebView_Previews : PreviewProvider {
    static var previews: some View {
        WebView(request: URLRequest(url: URL(string: "www.google.com")!))
    }
}
#endif
