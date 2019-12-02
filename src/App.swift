import CoreData
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

        self.setupStore()
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
    private var pillsCache: PillsCache!
    
    private func setupPills()
    {
        self.pillsVC = PillsVC()

        self.pillsController = PillsController()

        // Sync items.
        self.pillsController.itemsChanged.subscribe { [weak self] in
            guard let items = self?.pillsController.items else { return }
            self?.LOG("Pills: '\(items)'")
            self?.pillsVC.items = items
        }

        // Sync images.
        self.pillsController.imagesChanged.subscribe { [weak self] in
            guard let images = self?.pillsController.images else { return }
            self?.pillsVC.images = images
        }

        // Cycle items forward.
        self.pillsVC.cycle.subscribe { [weak self] in
            self?.pillsVC.cycleItems()
        }

        // Request network data.
        self.pillsController.refresh()

        // Setup cache once persistent store is loaded.
        self.storeLoaded.subscribe {
            self.setupPillsCache()
        }
    }

    private func setupPillsCache()
    {
        self.pillsCache = PillsCache(context: self.store.viewContext)

        self.pillsCache.clear()

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let sdate = formatter.string(from: date)

        self.pillsCache.addItem(
            Pill(
                id: 100,
                name: "Abc",
                imgURLString: "http://ya.ru",
                desc: sdate,
                dose: "Dose"
            )
        )
        self.pillsCache.save()
        self.pillsCache.printItems()
    }

    // MARK: - STORE

    var store: NSPersistentContainer!
    let storeLoaded = Reporter()

    private func setupStore()
    {
        self.store = NSPersistentContainer(name: "abcv")
        self.store.loadPersistentStores { (desc, error) in
            if let error = error 
            {
                self.LOG("ERROR Could not load persistent store: '\(error)'")
            }
            else
            {
                self.storeLoaded.report()
            }
        }
    }

}
