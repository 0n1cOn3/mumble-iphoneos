import UIKit

@objc(MUApplicationDelegate)
class MUApplicationDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.backgroundColor = .black
        window?.makeKeyAndVisible()
        return true
    }

    func reloadPreferences() {
        // TODO: bridge to Objective-C implementation
    }
}
