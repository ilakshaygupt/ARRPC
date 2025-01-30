import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let viewController = ARViewController()
        window.rootViewController = viewController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene, willBeRemoved: Bool) {
        // Called when the scene is being removed from an active state.
        // This may occur when the scene is being closed or when the scene is being removed from the background to the background.
        // The scene may re-connect later, as it is not being discarded or re-created when the scene is being re-connected.
        // The scene-specific state information will not be saved when the scene is being re-connected.
        // This method may be called when the scene is being created.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene is being presented to the user.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene is being removed from an active state to an inactive state.
        // This may occur when the scene is being closed, or when the scene is being re-connected.
        // This method may be called when the scene is being created.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called when the scene is being re-connected to an active state.
        // This may occur when the scene is being re-connected to an active state.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called when the scene is being re-connected to an active state.
        // This may occur when the scene is being re-connected to an active state.
    }
} 