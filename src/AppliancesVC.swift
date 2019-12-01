import UIKit

class AppliancesVC: UIViewController
    ,UITableViewDataSource
    ,UITableViewDelegate
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setupTableView()
        self.tableView.register(Cell.self, forCellReuseIdentifier: self.CELL_ID)

        // Selection.
        self.tableView.delegate = self
        
        self.setupAddition()
    }

    private func LOG(_ message: String)
    {
        NSLog("AppliancesVC \(message)")
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

    // MARK: - TABLE VIEW

    private var tableView: UITableView!

    private func setupTableView()
    {
        self.tableView = UITableView(frame: .zero, style: .plain)
        self.view.embeddedView = self.tableView
        self.tableView.backgroundColor = .clear
        self.tableView.dataSource = self
    
        // Refresh on changes.
        self.itemsChanged.subscribe { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return self.items.count
    }
    
    func tableView(
       _ tableView: UITableView,
       cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        return self.cell(forItemAt: indexPath)
    }

    // MARK: - TODO ?

    // private var dequeued = [CellView : Int]()

    // MARK: - CELL

    private let CELL_ID = "CELL_ID"
    private typealias Cell = UITableViewCell
    //private typealias CellView = UIImageView
    //private typealias Cell = UICollectionViewCellTemplate<CellView>
    
    private func cell(forItemAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell =
            self.tableView.dequeueReusableCell(
                withIdentifier: self.CELL_ID,
                for: indexPath
            )
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator

        let index = indexPath.row
        let item = self.items[index]
        let textId = item.type.rawValue
        cell.textLabel?.text = NSLocalizedString(textId, comment: "")
        //self.dequeued[cell.view] = index
        
        return cell
    }

    // MARK: - SELECTION

    var selectedItemId: Int?
    {
        didSet
        {
            self.selectedItemIdChanged.report()
        }
    }
    let selectedItemIdChanged = Reporter()

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        self.selectedItemId = indexPath.row
    }

    // MARK: - ADDITION

    let addItem = Reporter()
    private var addButton: UIBarButtonItem!

    private func setupAddition()
    {
        self.addButton =
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(requestAddition)
            )
        var items: [UIBarButtonItem] = self.navigationItem.rightBarButtonItems ?? []
        items.append(self.addButton)
        self.navigationItem.rightBarButtonItems = items
    }

    @objc func requestAddition(_ sender: Any)
    {
        self.addItem.report()
    }

}
