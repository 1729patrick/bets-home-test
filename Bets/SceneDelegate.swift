import UIKit
import BetsCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let rootViewController = composeRootViewController()
        let navigationController = composeNavigationController(with: rootViewController)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func composeRootViewController() -> UIViewController  {
        let repository = ServiceBetRepository(service: RemoteBetService.instance)
        let sortingStrategy = SellInOddsSortingStrategy()

        let viewModel = OddsRepositoryViewModel(
            repository: repository,
            sortingStrategy: sortingStrategy
        )

        return OddsViewController(viewModel: viewModel)
    }

    func composeNavigationController(with rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = true

        return navigationController
    }
}

