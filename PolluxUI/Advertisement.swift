//
//  Advertisement.swift
//  PolluxUI
//
//  Created by Edward Arenberg on 10/10/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import SwiftUI
import CoreLocation
import Parse
import ParseLiveQuery

typealias UINetworkModel = Decodable & Identifiable


struct Advertisement : Hashable, Codable, Identifiable {
    var id = UUID()
    var key : String
    var message = "This is much longer text that should wrap. Let's see how it gets layed out."
    var gender = "Either"
    var minAge = 0
    var maxAge = 99
    var action = "None"
    var show = ""
    var linkurl = ""
    var displayTime = 0
    var imageData = Data() // UIImage(named:"gemini")!.jpegData(compressionQuality: 0.9)! // Data() // Image("gemini")
}
extension Advertisement {
//    var image : Image {
//        Image("gemini")
////        ImageStore.shared.image(name:"gemini")
//    }
    var image : Image {
        imageData.toImage()
    }
    mutating func setImage(data:Data) {
        print("Set Data")
        self.imageData = data
    }
}


final class AdvertisementStore: ObservableObject {
//    @Published var advertisements: [Advertisement] = []
//    @EnvironmentObject var showData: ShowData

    static let shared = AdvertisementStore()
    

    var subscription: Subscription<AdClass>?
    let liveQueryClient = ParseLiveQuery.Client(server: "wss://pollux.back4app.io", applicationId: "iqeEuY9TcyeZQxefpSimZVfZ6E0GEp9e5cxlDY85", clientKey: "ls1OCbhmFq6jfqoexXEzZXecd6bVlh3Ay3uaKSpz")
    
    var subCallback : ((Event<AdClass>,Advertisement) -> ())?

    func fetch(showKey:String, callback: @escaping ([Advertisement])->()) {
        /*
        let advertisements : [Advertisement] = [
            .init(id: "a", name: "One"),
            .init(id: "b", name: "Two"),
            .init(id: "c", name: "Three")
        ]
        callback(advertisements)
         */
        
        fetchAds(showId: showKey) { ads in
//            self.showData.advertisements = ads
            callback(ads)
        }
        
        /*
        persons = [
            .init(id: .init(), name: "Majid", age: 27),
            .init(id: .init(), name: "John", age: 31),
            .init(id: .init(), name: "Fred", age: 25)
        ]
         */
    }

    func insertImage(adc:AdClass,file:PFFile,callback:@escaping ()->()) {
        file.getDataInBackground() { data,error in
            if let data = data {
                print("Got data")
                adc.imageData = data
            }
            callback()
        }
    }
    
    func fetchAds(showId:String, completion: @escaping (_ ads:[Advertisement])->()) {
        let query = AdClass.query()!
        query.whereKey("showId", equalTo: showId)
        query.findObjectsInBackground() { objects, error in
            guard error == nil else { completion([]); return }
            if let objs = objects as? [AdClass] {
                let dg = DispatchGroup()
                objs.forEach { adv in
                    if let f = adv.image {
                        print("Enter")
                        dg.enter()
                        self.insertImage(adc: adv, file: f) {
                            print("Leave")
                            dg.leave()
                        }
                    }
                }
                
                
// Advertisement(key: $0.objectId!, message: $0.message ?? "Unknown")

                dg.notify(queue: .main) {
                    print("Complete")
                    let ads = objs.map { $0.toAdvertisement() }

                    completion(ads)
                }
                
//                completion(ads)
            } else {
                completion([])
            }
        }
        /*
         query.getFirstObjectInBackground {(object, error) in
         if let error = error {
         completion([])
         } else if let object = object as? AdClass {
         
         //                image.getDataInBackgroundWithBlock {(data, error) in
         //                    if let error = error { completion?(error: error, image: nil) }
         //                    else if let data = data, image = UIImage(data: data) { completion?(error: nil, image: image) }
         //                }
         }
         }
         */
    }
    
    func subscribe(showId:String, callback: @escaping (Event<AdClass>,Advertisement)->()) {
        
        subCallback = callback
        
        let query : PFQuery<AdClass> = AdClass.query()! as! PFQuery<AdClass>
        query.whereKey("showId", equalTo: showId)
//        let subscription: Subscription<AdClass> = Client.shared.subscribe(query)
        subscription = liveQueryClient.subscribe(query)
        
        subscription?.handleSubscribe { query in
            print("Subscribed")
        }
        
        subscription?.handleError { query, error in
            print(error)
        }
        
        subscription?.handleEvent { query, event in
            switch event {
                /// The object has been updated, and is now included in the query
            /// The object has been created, and is a part of the query
            case .entered (let obj),
                 .created (let obj):
                callback(event,obj.toAdvertisement())
//                self.showData.advertisements.append(obj.toAdvertisement())
//                break
            /// The object has been updated, and is still a part of the query
            case .updated (let obj):
                callback(event,obj.toAdvertisement())
//                let ad = obj.toAdvertisement()
//                break
                /// The object has been updated, and is no longer included in the query
            /// The object has been deleted, and is no longer included in the query
            case .left (let obj),
                 .deleted (let obj):
                callback(event,obj.toAdvertisement())
//                break
                
            }
            
        }
    }

}

extension String {
    func toSeconds() -> Int {
        var sec = 0
        let comps = self.components(separatedBy: ":")
        if comps.count < 3 { return 0 }
        sec += (Int(comps[0]) ?? 0) * 3600
        sec += (Int(comps[1]) ?? 0) * 60
        sec += Int(comps[2]) ?? 0
        
        return sec
    }
}

extension Int {
    func toTime() -> String {
        let hrs = self / 3600
        let min = (self - hrs * 3600) / 60
        let sec = (self - hrs * 3600 - min * 60)
        
        return String(format:"%02d:%02d:%02d",hrs,min,sec)
    }
}

extension TimeInterval {
    func toTime() -> String {
        if self == 0 { return "" }
        let df = DateFormatter()
        df.dateFormat = "MM/dd h:mm a"
//        df.timeStyle = .short
        return df.string(from: Date(timeIntervalSinceReferenceDate: self))
    }
}

extension Data {
    func toImage() -> Image {
        if let img = UIImage(data: self) {
            return Image(uiImage: img)
        }
        return Image("gemini")
    }
}

class AdClass: PFObject {
    @NSManaged var showId: String?
    @NSManaged var message: String?
    @NSManaged var gender : String?
    @NSManaged var minAge : String?
    @NSManaged var maxAge : String?
    @NSManaged var action : String?
    @NSManaged var show : String?
    @NSManaged var linkurl : String?
    @NSManaged var displayTime : String?
    @NSManaged var image : PFFile?
    
    var imageData : Data?

    /*
    func time2Seconds(time:String) -> Int {
        var sec = 0
        let comps = time.components(separatedBy: ":")
        sec += (Int(comps[0]) ?? 0) * 3600
        sec += (Int(comps[1]) ?? 0) * 60
        sec += Int(comps[2]) ?? 0
        
        return sec
    }
     */

    func toAdvertisement() -> Advertisement {
        var ad = Advertisement(key: objectId!, message: message ?? "Unknown")
        ad.gender = (gender ?? "either").capitalized
        ad.action = (action ?? "none").capitalized
        ad.linkurl = linkurl ?? ""
        ad.minAge = Int(minAge ?? "0") ?? 0
        ad.maxAge = Int(maxAge ?? "99") ?? 99
        ad.message = message ?? ""
        ad.displayTime = (displayTime ?? "0:00:00").toSeconds()
        ad.imageData = imageData ?? Data()

        return ad
    }
}

extension AdClass: PFSubclassing {
    static func parseClassName() -> String {
        return "Advertisement"
    }
}

/*
final class ImageStore {
    typealias _ImageDictionary = [String: CGImage]
    fileprivate var images: _ImageDictionary = [:]

    fileprivate static var scale = 2
    
    static var shared = ImageStore()
    
    func image(name: String) -> Image {
        let index = _guaranteeImage(name: name)
        
        return Image(images.values[index], scale: CGFloat(ImageStore.scale), label: Text(verbatim: name))
    }

    static func loadImage(name: String) -> CGImage {
        guard
            let url = Bundle.main.url(forResource: name, withExtension: "png"),
            let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            fatalError("Couldn't load image \(name).jpg from main bundle.")
        }
        return image
    }
    
    fileprivate func _guaranteeImage(name: String) -> _ImageDictionary.Index {
        if let index = images.index(forKey: name) { return index }
        
        images[name] = ImageStore.loadImage(name: name)
        return images.index(forKey: name)!
    }
}
*/
