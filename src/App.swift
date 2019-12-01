import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)

        self.setupPills()
        let nc = UINavigationController(rootViewController: self.pillsVC)
        nc.setNavigationBarHidden(true, animated: false)
        self.window?.rootViewController = nc

        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()

        return true
    }

    private func LOG(_ message: String)
    {
        NSLog("App \(message)")
    }

    // MARK: - PILLS

    private var pillsVC: PillsVC!
    private var pillsController: PillsController!
    
    private func setupPills()
    {
        self.pillsVC = PillsVC()

        self.pillsController = PillsController()
        self.pillsController.itemsChanged.subscribe { [weak self] in
            guard let items = self?.pillsController.items else { return }
            self?.LOG("Pills: '\(items)'")
            self?.pillsVC.items = items
        }

        self.pillsController.refresh()
    }

}
