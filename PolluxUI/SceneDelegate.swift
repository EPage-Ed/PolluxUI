//
//  SceneDelegate.swift
//  PolluxUI
//
//  Created by Edward Arenberg on 10/10/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import UIKit
import SwiftUI
import Parse

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var showData = ShowData()

    func configureParse() {
        AdClass.registerSubclass()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        let configuration = ParseClientConfiguration {
          $0.applicationId = "iqeEuY9TcyeZQxefpSimZVfZ6E0GEp9e5cxlDY85"
          $0.clientKey = "ls1OCbhmFq6jfqoexXEzZXecd6bVlh3Ay3uaKSpz"
          $0.server = "https://parseapi.back4app.com"
        }
        Parse.initialize(with: configuration)
        
        configureParse()

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {

            UITableView.appearance().allowsSelection = false
            UITableViewCell.appearance().selectionStyle = .none

            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView.environmentObject(showData))
            self.window = window
            window.makeKeyAndVisible()
            
            showData.fetch(showId: "Test")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

