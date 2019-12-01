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

        self.setupAppliances()
        let nc = UINavigationController(rootViewController: self.appliancesVC)
        self.window?.rootViewController = nc

        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()

        return true
    }

    private func LOG(_ message: String)
    {
        NSLog("App \(message)")
    }

    // MARK: - APPLIANCES

    private var applianceVC: ApplianceVC!
    private var applianceNC: UINavigationController!

    private var appliancesVC: AppliancesVC!
    private var appliancesController: AppliancesController!
    
    private func setupAppliances()
    {
        self.appliancesVC = AppliancesVC()
        self.appliancesVC.title =
            NSLocalizedString("Appliances.Title", comment: "")

        self.applianceVC = ApplianceVC()
        self.applianceNC =
            UINavigationController(rootViewController: self.applianceVC)

        self.appliancesController = AppliancesController()
        self.appliancesController.itemsChanged.subscribe { [weak self] in
            guard let items = self?.appliancesController.items else { return }
            self?.LOG("Appliances: '\(items)'")
            self?.appliancesVC.items = items
        }

        // Add item.
        self.appliancesVC.addItem.subscribe { [weak self] in
            guard let this = self else { return }
            this.applianceVC.title =
                NSLocalizedString("Appliance.Add.Title", comment: "")
            this.applianceVC.type = .kettle
            this.applianceVC.state = false

            this.appliancesVC.present(
                this.applianceNC,
                animated: true,
                completion: nil
            )
        }

        // Edit item.
        self.appliancesVC.selectedItemIdChanged.subscribe { [weak self] in
            guard
                let this = self,
                let id = this.appliancesVC.selectedItemId
            else
            {
                return
            }

            let item = this.appliancesController.items[id]
            this.applianceVC.title =
                NSLocalizedString("Appliance.Edit.Title", comment: "")
            this.applianceVC.type = item.type
            this.applianceVC.state = item.state

            this.appliancesVC.present(
                this.applianceNC,
                animated: true,
                completion: nil
            )
        }

        // Cancel item modifications.
        self.applianceVC.cancel.subscribe { [weak self] in
            self?.applianceVC.dismiss(animated: true, completion: nil)
        }

        // Apply item modifications.
        self.applianceVC.apply.subscribe { [weak self] in

            // TODO Save changes
            self?.applianceVC.dismiss(animated: true, completion: nil)
        }

        // Load the first time.
        self.appliancesController.refresh()
    }

}
