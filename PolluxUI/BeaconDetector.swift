//
//  BeaconDetector.swift
//  PolluxUI
//
//  Created by Edward Arenberg on 10/18/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import Foundation
import Combine
import CoreLocation
import AVFoundation

//let advertisementData: [Advertisement] = [
//    Advertisement(id: "e"),Advertisement(id: "f"),Advertisement(id: "g")
//]

class BeaconDetector : NSObject, ObservableObject, CLLocationManagerDelegate {
//    var didChange = PassthroughSubject<Void, Never>()
    var showData: ShowData!
    let objectWillChange = ObservableObjectPublisher()
    var locationManager: CLLocationManager?
    var major : Int = 0
    var minor : Int = 0
    var lastMajor : Int = -1
    var lastMinor : Int = -1
//    @Published var newBeacon = false
    private var timer : Timer?
    private var seconds = 0
    
    private var audioPlayer : AVAudioPlayer!
    
    static var shared = BeaconDetector()
    
    func setData(data:ShowData) -> BeaconDetector {
        self.showData = data
        
        if timer == nil {
            timer = Timer(timeInterval: 1.0, repeats: true) { timer in
                self.seconds += 1
                if self.seconds % 15 == 0 {
                    if self.showData.newTime(time: self.seconds, from: self.seconds - 15) > 0 {
                        self.audioPlayer.play()
                    }
                }
            }
//            RunLoop.main.add(timer!, forMode: .common)
        }
        
        return self
    }
        
    override init() {
        super.init()

        do {
            let sound = Bundle.main.url(forResource: "bloop", withExtension: "wav")!
            audioPlayer = try AVAudioPlayer(contentsOf: sound)
            audioPlayer.prepareToPlay()
        }
        catch (let e) {
            print(e)
        }
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                startMonitoring(major: nil,minor: nil)
            }
        }
    }
    
    func startMonitoring(major:Int? = nil, minor:Int? = nil) {
        stopMonitoring()
        
        print("Monitor \(major) , \(minor)")
        
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        var constraint : CLBeaconIdentityConstraint
        if let major = major, let minor = minor {
            constraint = CLBeaconIdentityConstraint(uuid: uuid, major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor))
        } else if let major = major {
            constraint = CLBeaconIdentityConstraint(uuid: uuid, major: CLBeaconMajorValue(major))
        } else {
            constraint = CLBeaconIdentityConstraint(uuid: uuid)
        }
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "ShowBeacon")
        
        locationManager?.startMonitoring(for: beaconRegion)
    }
    
    func stopMonitoring() {
        if let reg = locationManager?.monitoredRegions.first {
            print("Stop monitoring \(reg.identifier)")
            locationManager?.stopMonitoring(for: reg)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Start monitoring \(region.identifier)")
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit region \(region.identifier)")
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("\(region.identifier) : \(state.rawValue)") // unknown, inside, outside
        if let beacon = region as? CLBeaconRegion, state == .inside {
            manager.startRangingBeacons(satisfying: beacon.beaconIdentityConstraint)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        print("No beacons in range")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beacon = region as? CLBeaconRegion {
            print("Entered region \(region.identifier)")
//            manager.startRangingBeacons(satisfying: beacon.beaconIdentityConstraint)
            
            /*
            self.objectWillChange.send()
            lastMajor = major
            lastMinor = minor
            major = beacon.major?.intValue ?? 0
            minor = beacon.minor?.intValue ?? 0
            
            print("Did Enter \(major) , \(minor)")
            
            showData.newTime(time: minor, from: lastMinor)
            
            minor += 15
            startMonitoring(major: major, minor: minor)
            */
//            didChange.send(())
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
//            manager.stopRangingBeacons(satisfying: beaconConstraint)
            
            if beacon.major.intValue == major && beacon.minor.intValue == minor { return }

            self.objectWillChange.send()

            lastMajor = major
            lastMinor = minor
            major = beacon.major.intValue
            minor = beacon.minor.intValue

            print("Did Range \(major) , \(minor)")
            
            showData.showTitle = "Inception"
            showData.showTime = Date().timeIntervalSinceReferenceDate
            
//            minor += 15
            if showData.newTime(time: minor, from: lastMinor) > 0 {
                self.audioPlayer.play()
            }
            
//            startMonitoring()
//            startMonitoring(major: major, minor: minor)

        }
    }
}
