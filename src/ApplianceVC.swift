import Anchorage
import UIKit

class ApplianceVC: UIViewController
{

    private var lastView: UIView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        self.setupCancellation()
        self.setupApplication()

        self.setupType()
        self.setupState()

        // Layout.
        self.lastView = startLastView(forVC: self)
        self.layoutType()
        self.layoutState()
        //finishLastView(self.lastView, forVC: self)
    }

    private func LOG(_ message: String)
    {
        NSLog("ApplianceVC \(message)")
    }

    // MARK: - CANCELLATION

    let cancel = Reporter()
    private var cancelButton: UIBarButtonItem!

    private func setupCancellation()
    {
        self.cancelButton =
            UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(requestCancellation)
            )
        var items: [UIBarButtonItem] = self.navigationItem.leftBarButtonItems ?? []
        items.append(self.cancelButton)
        self.navigationItem.leftBarButtonItems = items
    }

    @objc func requestCancellation(_ sender: Any)
    {
        self.cancel.report()
    }

    // MARK: - APPLICATION

    let apply = Reporter()
    private var applyButton: UIBarButtonItem!

    private func setupApplication()
    {
        self.applyButton =
            UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(requestApplication)
            )
        var items: [UIBarButtonItem] = self.navigationItem.rightBarButtonItems ?? []
        items.append(self.applyButton)
        self.navigationItem.rightBarButtonItems = items
    }

    @objc func requestApplication(_ sender: Any)
    {
        self.apply.report()
    }

    // MARK: - TYPE

    private var _type: ApplianceType?
    var type: ApplianceType?
    {
        get
        {
            return self._type
        }
        set
        {
            self._type = newValue
            self.typeChanged.report()
        }
    }
    let typeChanged = Reporter()

    private var typeLabel: UILabel!
    private var typeSC: UISegmentedControl!

    private func setupType()
    {
        self.typeLabel = UILabel()
        self.typeLabel.text = NSLocalizedString("Type.Title", comment: "")
        self.view.addSubview(self.typeLabel)

        let items = ApplianceType.allCases.map { NSLocalizedString($0.rawValue, comment: "") }
        self.typeSC = UISegmentedControl(items: items)
        self.view.addSubview(self.typeSC)
        
        // Display initial selection.
        self.updateType()
        // Keep selection in sync.
        self.typeChanged.subscribe { [weak self] in
            self?.updateType()
        }

        // Track user selection.
        self.typeSC.addTarget(
            self,
            action: #selector(trackType),
            for: .valueChanged
        )
    }

    private func updateType()
    {
        guard
            let type = self.type,
            let id = applianceTypeToId(type)
        else
        {
            return
        }

        self.typeSC.selectedSegmentIndex = id
    }

    @objc private func trackType()
    {
        self._type = idToApplianceType(self.typeSC.selectedSegmentIndex)
    }

    private func layoutType()
    {
        self.typeLabel.topAnchor == self.lastView.bottomAnchor + 16
        self.typeLabel.leftAnchor == self.view.leftAnchor + 8
        self.typeLabel.rightAnchor == self.view.rightAnchor - 8
        self.lastView = self.typeLabel
        
        self.typeSC.topAnchor == self.lastView.bottomAnchor + 8
        self.typeSC.leftAnchor == self.view.leftAnchor + 8
        self.typeSC.rightAnchor == self.view.rightAnchor - 8
        self.lastView = self.typeSC
    }

    // MARK: - STATE

    var state: Bool?
    {
        didSet
        {
            self.stateChanged.report()
        }
    }
    let stateChanged = Reporter()

    private var stateLabel: UILabel!
    private var stateSC: UISegmentedControl!

    private func setupState()
    {
        self.stateLabel = UILabel()
        self.stateLabel.text = NSLocalizedString("State.Title", comment: "")
        self.view.addSubview(self.stateLabel)

        let items = [
            NSLocalizedString("State.Off", comment: ""),
            NSLocalizedString("State.On", comment: ""),
        ]
        self.stateSC = UISegmentedControl(items: items)
        self.view.addSubview(self.stateSC)

        // Display initial state.
        self.updateState()
        // Keep state in sync.
        self.stateChanged.subscribe { [weak self] in
            self?.updateState()
        }
    }

    private func updateState()
    {
        guard let state = self.state else { return }
        self.stateSC.selectedSegmentIndex = state ? 1 : 0
    }

    private func layoutState()
    {
        self.stateLabel.topAnchor == self.lastView.bottomAnchor + 16
        self.stateLabel.leftAnchor == self.view.leftAnchor + 8
        self.stateLabel.rightAnchor == self.view.rightAnchor - 8
        self.lastView = self.stateLabel
        
        self.stateSC.topAnchor == self.lastView.bottomAnchor + 8
        self.stateSC.leftAnchor == self.view.leftAnchor + 8
        self.stateSC.rightAnchor == self.view.rightAnchor - 8
        self.lastView = self.stateSC
    }

}
