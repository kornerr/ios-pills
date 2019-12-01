import Anchorage
import CHIPageControl
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
        self.setupSelection()
        self.setupDots()
        self.setupName()
        self.setupDescription()
        //self.setupRefresh()

        // Layout.
        self.lastView = startLastView(forVC: self)
        self.layoutPagerView()
        self.layoutDots()
        self.layoutName()
        self.layoutDescription()
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
        let height = size.height / 1.1
        let width = size.width / 1.6
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

    // MARK: - SELECTION

    var selectedItemId = 0
    {
        didSet
        {
            self.selectedItemIdChanged.report()
        }
    }
    let selectedItemIdChanged = Reporter()

    private func setupSelection()
    {
        self.pagerView.delegate = self
    }

    func pagerView(
       _ pagerView: FSPagerView,
       shouldSelectItemAt index: Int
    ) -> Bool {
        self.pagerView.scrollToItem(at: index, animated: true)
        return true
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView)
    {
        // Skip setting the same value.
        if self.selectedItemId == self.pagerView.currentIndex
        {
            return
        }

        self.selectedItemId = self.pagerView.currentIndex
    }

    // MARK: - DOTS

    private var pageControl: CHIPageControlJalapeno!
    
    private func setupDots()
    {
        self.pageControl = CHIPageControlJalapeno()
        self.view.addSubview(self.pageControl)
        self.pageControl.radius = 2
        self.pageControl.tintColor = UIColor.lightGray
        self.pageControl.currentPageTintColor = self.view.tintColor
    
        self.itemsChanged.subscribe { [weak self] in
            guard let count = self?.items.count else { return }
            self?.pageControl.numberOfPages = count
        }
        self.selectedItemIdChanged.subscribe { [weak self] in
            guard let id = self?.selectedItemId else { return }
            self?.pageControl.progress = Double(id)
        }
    }
    
    private func layoutDots()
    {
        self.pageControl.topAnchor == self.lastView.bottomAnchor
        self.pageControl.centerXAnchor == self.view.centerXAnchor
        self.lastView = self.pageControl
    }

    // MARK: - NAME

    private var nameLabel: UILabel!
    
    private func setupName()
    {
        self.nameLabel = UILabel()
        self.view.addSubview(self.nameLabel)
        self.nameLabel.textAlignment = .center
        self.nameLabel.lineBreakMode = .byWordWrapping
        self.nameLabel.numberOfLines = 0
        self.nameLabel.font = UIFont.preferredFont(forTextStyle: .title1)
    
        self.itemsChanged.subscribe { [weak self] in
            self?.updateName()
        }
        self.selectedItemIdChanged.subscribe { [weak self] in
            self?.updateName()
        }
    }
    
    private func layoutName()
    {
        self.nameLabel.topAnchor == self.lastView.bottomAnchor + 16
        self.nameLabel.leftAnchor == self.view.leftAnchor + 16
        self.nameLabel.rightAnchor == self.view.rightAnchor - 16
        self.lastView = self.nameLabel
    }
    
    private func updateName()
    {
        let name = self.items[self.selectedItemId].name
        self.nameLabel?.text = name
    }

    // MARK: - DESCRIPTION

    private var descLabel: UILabel!
    
    private func setupDescription()
    {
        self.descLabel = UILabel()
        self.view.addSubview(self.descLabel)
        self.descLabel.textAlignment = .center
        self.descLabel.lineBreakMode = .byWordWrapping
        self.descLabel.numberOfLines = 0
        self.descLabel.textColor = .lightGray
    
        self.itemsChanged.subscribe { [weak self] in
            self?.updateDescription()
        }
        self.selectedItemIdChanged.subscribe { [weak self] in
            self?.updateDescription()
        }
    }
    
    private func layoutDescription()
    {
        self.descLabel.topAnchor == self.lastView.bottomAnchor + 16
        self.descLabel.leftAnchor == self.view.leftAnchor + 16
        self.descLabel.rightAnchor == self.view.rightAnchor - 16
        self.lastView = self.descLabel
    }
    
    private func updateDescription()
    {
        let desc = self.items[self.selectedItemId].desc
        self.descLabel?.text = desc
    }

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
