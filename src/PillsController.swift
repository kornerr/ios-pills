import Alamofire
import SwiftyJSON

class PillsController
{
    let API_URL = "https://cloud.fdoctor.ru/test_task/"

    init() { }

    func refresh()
    {
        // TODO: self.items = []
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
        guard
            let url = URL(string: self.API_URL)
        else
        {
            self.LOG("ERROR Request URL was malformed")
            return
        }

        Alamofire.request(url).responseJSON { [weak self] response in
            let result = response.result
            // Success.
            if
                result.isSuccess,
                let value = result.value
            {
                self?.parseJSONItems(JSON(value))
            }
            // Failure.
            else
            {
                self?.LOG("ERROR Could not get pills: '\(String(describing: result.error))'")
            }
        }
    }

    private func parseJSONItems(_ json: JSON)
    {
        let jsonItems = json["pills"]

        var items = [Pill]()
        for jsonItem in jsonItems
        {
            let ji = jsonItem.1
            let item =
                Pill(
                    id: ji["id"].intValue,
                    name: ji["name"].stringValue,
                    imgURLString: ji["img"].stringValue,
                    desc: ji["desription"].stringValue,
                    dose: ji["dose"].stringValue
                )
            items.append(item)
        }

        self.items = items
    }

}
