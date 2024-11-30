//
//  SceneDelegate.swift
//  HappyPatient
//
//  Created by Assel Artykbay on 28.11.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Check if the user is logged in
        if isUserLoggedIn() {
            // User is logged in, show MainViewController
            let mainViewController = ViewController()
            let navigationController = UINavigationController(rootViewController: mainViewController)
            window?.rootViewController = navigationController
        } else {
            // User is not logged in, show AuthViewController
            let authViewController = LoginViewController()
            window?.rootViewController = authViewController
        }
        
        window?.makeKeyAndVisible()
    }

    private func isUserLoggedIn() -> Bool {
        if let token = UserDefaults.standard.string(forKey: "userToken"), !token.isEmpty {
            return true
        }
        return false
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
