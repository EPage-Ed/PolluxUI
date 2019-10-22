//
//  ShowData.swift
//  PolluxUI
//
//  Created by Edward Arenberg on 10/11/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import SwiftUI
import Combine
import Parse

final class ShowData: ObservableObject {
    var id = UUID()
    var showId = ""
    var key = ""
    private var isSubscribed = false
//    @Published var advertisements = advertisementData
    var allAdvertisements = [Advertisement]()
    @Published var advertisements = [Advertisement]()
    @Published var age = 0
    @Published var showTitle = ""
    @Published var showTime : TimeInterval = 0
    
    func newTime(time:Int, from:Int) -> Int {
        print("Check for ads from \(from) to \(time)")
        let newAds = allAdvertisements.filter() {
            $0.displayTime <= time && $0.displayTime >= from
                && $0.minAge <= self.age && $0.maxAge >= self.age
        }
        advertisements.insert(contentsOf: newAds, at: 0)
//        advertisements.append(contentsOf: newAds)
        return newAds.count
    }

    func fetch(showId:String) {
        self.showId = showId
        self.showTitle = ""
        
        AdvertisementStore.shared.fetch(showKey:showId) { ads in
            self.allAdvertisements = ads
            self.subscribe()
            
            for ad in ads {
                print("\(ad.displayTime) : \(ad.message)")
            }
        }
            
        
        /*
        persons = [
            .init(id: .init(), name: "Majid", age: 27),
            .init(id: .init(), name: "John", age: 31),
            .init(id: .init(), name: "Fred", age: 25)
        ]
         */
    }
    
    func subscribe() {
        if isSubscribed { return }
        AdvertisementStore.shared.subscribe(showId: self.showId) { event, ad in
            DispatchQueue.main.async {
                switch event {
                case .entered (let obj),
                     .created (let obj):
                    self.allAdvertisements.append(ad)
                    //                        self.advertisements.append(ad)
                    break
                case .updated (let obj):
                    if let idx = self.allAdvertisements.firstIndex(where: { $0.key == obj.objectId }) {
                        self.allAdvertisements[idx] = ad
                    }
                    if let idx = self.advertisements.firstIndex(where: { $0.key == obj.objectId }) {
                        self.advertisements[idx] = ad
                    }
                    
                    break
                case .left (let obj),
                     .deleted (let obj):
                    self.allAdvertisements.removeAll(where: { $0.key == obj.objectId! } )
                    self.advertisements.removeAll(where: { $0.key == obj.objectId! } )
                    break
                }
            }
        }
    }

}

/*
class AdFetcher: ObservableObject {
    private static let apiUrlString = "https://gist.githubusercontent.com/schmidyy/02fdec9b9e05a71312a550fc50f948e6/raw/7fc2facbbf9c3aa526f35a32d0c7fe74a4fc29a1/products.json"
    
    init() {
        guard let apiUrl = URL(string: AdFetcher.apiUrlString) else {
//            state = .fetched(.failure(.error("Malformed API URL.")))
            return
        }
        
        URLSession.shared.dataTask(with: apiUrl) { [weak self] (data, _, error) in
            if let error = error {
//                self?.state = .fetched(.failure(.error(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
//                self?.state = .fetched(.failure(.error("Malformed response data")))
                return
            }
            let root = try! JSONDecoder().decode(Root.self, from: data)
            
            DispatchQueue.main.async { [weak self] in
                self?.state = .fetched(.success(root))
            }
        }.resume()
    }
}
*/
