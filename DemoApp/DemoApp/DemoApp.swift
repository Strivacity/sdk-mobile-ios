import StrivacitySDK
import SwiftUI

@main
struct DemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(controller: UIController(appDelegate: appDelegate))
        }
    }
}
