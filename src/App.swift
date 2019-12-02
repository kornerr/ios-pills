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

        self.setupPills()
        self.setupStore()
        // Setup cache once persistent store is loaded.
        self.storeLoaded.subscribe {
            self.setupPillsCache()
        }

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

        // Sync items.
        self.pillsController.itemsChanged.subscribe {
            self.pillsVC.items = self.pillsController.items
            self.LOG("Pills: '\(self.pillsController.items)'")
        }

        // Sync images.
        self.pillsController.imagesChanged.subscribe {
            self.pillsVC.images = self.pillsController.images
        }

        // Cycle items forward.
        self.pillsVC.cycle.subscribe {
            self.pillsVC.cycleItems()
        }

        // Refresh data when requested.
        self.pillsVC.refresh.subscribe {
            self.pillsController.refresh()
        }

        // Request network data.
        self.pillsController.refresh()
    }

    // MARK: - CACHE

    var store: NSPersistentContainer!
    let storeLoaded = Reporter()
    private var pillsCache: PillsCache!

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

    private func setupPillsCache()
    {
        self.pillsCache = PillsCache(context: self.store.viewContext)
        // Use cached items only if there are no loaded ones.
        let items = self.pillsCache.items
        if self.pillsController.items.isEmpty
        {
            self.pillsController.items = items
        }

        // Cache new items.
        self.pillsController.itemsChanged.subscribe {
            self.pillsCache.items = self.pillsController.items
        }
    }

}
