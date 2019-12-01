import Foundation

class PillsController
{
    init() { }

    func refresh()
    {
        //self.items = []
        self.loadItems()
    }

    private func LOG(_ message: String)
    {
        NSLog("PillsController \(message)")
    }

    // MARK: - ITEMS

    var items = [Pill]()
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
            Pill(
                id: 1,
                name: "Мезим форте",
                imgURLString: "https://cloud.fdoctor.ru/test_task/static/mezim.jpg",
                desc: "Перед завтраком",
                dose: "По таблетке"
            ),
            Pill(
                id: 2,
                name: "Bioderma",
                imgURLString: "https://cloud.fdoctor.ru/test_task/static/bioderma.jpg",
                desc: "Во время еды",
                dose: "По 3 глотка"
            ),
        ]
    }

}
