import StrivacitySDK
import SwiftUI

struct ContentView: View {
    @ObservedObject var controller: UIController

    var body: some View {
        ScrollView {
            if controller.isAuthenticated {
                MainView(controller: controller)
            } else {
                LoginView(controller: controller)
            }
        }
        .padding(5)
    }

    init(controller: UIController) {
        self.controller = controller

        controller.checkAuthenticated()
    }
}

struct LoginView: View {
    @ObservedObject var controller: UIController

    var body: some View {
        Button("Login") {
            controller.startFlow(viewController: getViewController())
        }
        Text(controller.errorText ?? "")
    }

    private func getViewController() -> UIViewController {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene!.keyWindow!.rootViewController!
    }
}

struct MainView: View {
    @ObservedObject var controller: UIController

    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Access Token:")
                    Text(controller.accessToken ?? "")
                }
                Divider()
                ForEach(getClaims().keys.map { String(describing: $0) }, id: \.self) { claim in
                    HStack {
                        Text(claim)
                        Spacer()
                        Text(getClaimValue(key: claim))
                    }
                }
                Divider()
                ForEach(getAdditionalParams().keys.map { String(describing: $0) }, id: \.self) { additionalParam in
                    HStack {
                        Text(additionalParam)
                        Spacer()
                        Text(getAdditionalParams()[additionalParam] ?? "")
                    }
                }
                Divider()
                Text(controller.errorText ?? "")
            }
            Spacer()
            VStack(spacing: 10) {
                Button("Get Access Token and additional params") {
                    controller.getAccessToken(additionalParams: ["customKey": "customValue"])
                    controller.getLastAdditionalParams()
                }
                Button("Get claims") {
                    controller.getClaims()
                }
                Button("Logout") {
                    controller.logout(viewController: getViewController())
                }
            }
        }
    }

    private func getClaims() -> [AnyHashable: Any] {
        controller.claims ?? [:]
    }

    private func getClaimValue(key: AnyHashable) -> String {
        String(describing: controller.claims?[key] ?? "")
    }

    private func getAdditionalParams() -> [String: String] {
        controller.additionalParams ?? [:]
    }

    private func getViewController() -> UIViewController {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene!.keyWindow!.rootViewController!
    }
}
