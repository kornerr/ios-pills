import Anchorage
import FSPagerView
import UIKit

class PillsVC: UIViewController
    ,FSPagerViewDataSource
    ,FSPagerViewDelegate
{

    private var lastView: UIView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setupPagerView()
        self.setupImages()
        /*
        // Selection.
        self.tableView.delegate = self
        
        self.setupAddition()
        */

        // Layout.
        self.lastView = startLastView(forVC: self)
        self.layoutPagerView()
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        self.layoutPagerViewItems()
    }

    private func LOG(_ message: String)
    {
        NSLog("PillsVC \(message)")
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

    // MARK: - PAGER VIEW

    private var pagerView: FSPagerView!

    private func setupPagerView()
    {
        self.pagerView = FSPagerView()
        self.view.addSubview(self.pagerView)

        self.pagerView.dataSource = self
        self.pagerView.transformer = FSPagerViewTransformer(type: .linear)
        self.pagerView.register(
            Cell.self,
            forCellWithReuseIdentifier: self.CELL_ID
        )

        // Refresh on changes.
        self.itemsChanged.subscribe { [weak self] in
            self?.pagerView.reloadData()
        }
    }

    private func layoutPagerView()
    {
        self.pagerView.topAnchor == self.lastView.bottomAnchor + 8
        self.pagerView.leftAnchor == self.view.leftAnchor
        self.pagerView.rightAnchor == self.view.rightAnchor
        self.pagerView.heightAnchor == self.view.heightAnchor / 2
        self.lastView = self.pagerView
    }
    
    private func layoutPagerViewItems()
    {
        let size = self.pagerView.frame.size
        let height = size.height / 1.2
        let width = size.width / 1.7
        self.pagerView.itemSize = CGSize(width: width, height: height)
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int
    {
        return self.items.count
    }

    func pagerView(
        _ pagerView: FSPagerView,
        cellForItemAt index: Int
    ) -> FSPagerViewCell {
        return self.cell(forItemAt: index)
    }

    // MARK: - CELL

    private var dequeued = [CellView : Int]()
    private let CELL_ID = "CELL_ID"
    private typealias CellView = UIImageView
    private typealias Cell = FSPagerViewCellTemplate<CellView>
    
    private func cell(forItemAt index: Int) -> FSPagerViewCell
    {
        let cell =
            self.pagerView.dequeueReusableCell(
                withReuseIdentifier: self.CELL_ID,
                at: index
            )
            as! Cell
        cell.backgroundColor = .white
        cell.itemView.image = self.images[index]
        cell.itemView.contentMode = .scaleAspectFit
        cell.itemView.clipsToBounds = true
        cell.contentView.layer.shadowRadius = 0
        cell.contentView.layer.borderWidth = 0.5
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor
        cell.contentView.layer.cornerRadius = 5
        self.dequeued[cell.itemView] = index
        return cell
    }

    // MARK: - IMAGES

    var images = [Int : UIImage]()
    {
        didSet
        {
            self.imagesChanged.report()
        }
    }
    let imagesChanged = Reporter()

    private func setupImages()
    {
        self.imagesChanged.subscribe { [weak self] in
            self?.applyImages()
        }
    }

    private func applyImages()
    {
        for (itemView, id) in self.dequeued
        {
            if let image = self.images[id]
            {
                itemView.image = image
            }
        }
    }

    /*
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
    */

    // MARK: - ADDITION

    /*
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
    */

}
