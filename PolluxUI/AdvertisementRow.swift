//
//  AdvertisementRow.swift
//  PolluxUI
//
//  Created by Edward Arenberg on 10/10/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import SwiftUI

struct AdvertisementRow: View {
    @State var advertisement : Advertisement
    @State private var act: Int? = 0
    
    var body: some View {
        
        struct FillStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .frame(minWidth: 44, minHeight: 44)
                    .padding(.horizontal)
                    .font(Font.body.bold())
                    .foregroundColor(configuration.isPressed ? .gray : .white)
                    .background(configuration.isPressed ? Color.accentColor : .green)
                    .cornerRadius(12)
            }
        }

//        return Text("abc")
        let action = advertisement.action
        let hasAction = action != "None"

        return HStack(alignment: .top, spacing: nil) {
            VStack(alignment: .leading) {
                //                .aspectRatio(contentMode: .fit)
                HStack {
                    advertisement.image
                        .resizable()
                        .frame(width: 80.0, height: 80.0)
                    
                    if hasAction {
                        Spacer()
//                        NavigationLink(destination: WebView(request: URLRequest(url: URL(string: advertisement.linkurl)!)), isActive: $act) {
                        VStack(alignment: .trailing, spacing: nil) {
                            Text(advertisement.displayTime.toTime())
                            NavigationLink(destination: WebView(request: URLRequest(url: URL(string: advertisement.linkurl)!)), tag:1, selection: $act) {
                                EmptyView()
                            }
                            Button(action: {
                                self.act = 1
                                print("Button Hit")
                            }, label: {
                                Text(action).font(.system(size: 20))
                            }).onTapGesture {
                                self.act = 1
                                print("Button Hit")
                            }
                                //            .padding(.all)
                                //            .background( ? Color.red : Color.blue)
                                //            .background(Color.green)
                                //            .cornerRadius(16)
                                //            .foregroundColor(.white)
                                //                .font(Font.body.bold())
                                .buttonStyle(FillStyle())
                        }
                            //                }
//                        }
                        //                NavigationLink(destination: WebView(request: URLRequest(url: URL(string: advertisement.linkurl)!))) {
                    }
                }
//                Spacer(minLength: 8.0)
                Text(advertisement.message)
                    .font(.system(size: 20))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }

            
    }
}

struct AdvertisementRow_Previews: PreviewProvider {
    static var previews: some View {
        var ad = Advertisement(key: "x")
        ad.displayTime = 20
        ad.action = "Info"
        ad.linkurl = "http://google.com"
        ad.message = "Get info on the best thing since sliced bread."
        ad.show = "Inception"
        return AdvertisementRow(advertisement: ad)
            .previewLayout(.sizeThatFits)
//            .previewDevice(PreviewDevice(stringLiteral: "iPhoneX"))
//            .previewLayout(.fixed(width: 360, height: 120))
    }
}
