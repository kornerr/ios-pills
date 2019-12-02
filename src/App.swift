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
        self.pillsCache = PillsCache(persistentContainer: self.persistentContainer)

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

        // Initial request.
        self.pillsController.refresh()
    }

    // MARK: - TODO CORE DATA

    func applicationWillTerminate(_ application: UIApplication)
    {
        self.saveContext()
    }

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "abcv")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext()
    {
        let context = persistentContainer.viewContext
        if context.hasChanges
        {
            do
            {
                try context.save()
            }
            catch
            {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
