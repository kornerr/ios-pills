import Foundation

class AppliancesController
{
    init() { }

    func refresh()
    {
        self.items = []
        self.loadItems()
    }

    private func LOG(_ message: String)
    {
        NSLog("AppliancesController \(message)")
    }

    // MARK: - ITEMS

    var items = [Appliance]()
    {
        didSet
        {
            self.itemsChanged.report()
        }
    }
    let itemsChanged = Reporter()

    func loadItems()
    {
        self.items = [
            Appliance(type: .kettle, state: true),
            Appliance(type: .coffeeMachine, state: false),
            Appliance(type: .multicooker, state: false),
        ]
    }

}
