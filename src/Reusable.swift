import Anchorage
import UIKit

// MARK: - UIView.embeddedView

public extension UIView
{
    var embeddedView : UIView?
    {
        get
        {
            // Only work for single or no subview.
            if (self.subviews.count > 1)
            {
                return nil
            }
            return self.subviews.first
        }
        set
        {
            // Only work for single or no subview.
            if (self.subviews.count > 1)
            {
                return
            }
            // Remove old subview.
            if let subview = self.subviews.first
            {
                if (newValue == subview)
                {
                    return
                }
                subview.removeFromSuperview()
            }
            if let view = newValue
            {
                self.embedView(view)
            }
        }
    }

    func embedView(_ other: UIView)
    {
        self.addSubview(other)
        other.translatesAutoresizingMaskIntoConstraints = false
        other.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        other.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        other.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        other.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
}

// MARK: - Reporter

/*
This file is part of Reporter:
  https://github.com/kornerr/Reporter

Copyright (C) 2018 Michael Kapelko <kornerr@gmail.com>

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
*/

import Foundation

/**
An object that controls subscription lifetime:
when the object is deallocated, all subscriptions get deallocated, too.
*/
public class ReporterBag
{
    
    /**
    Create ReporterBag instance.
    */
    public init() { }

    deinit
    {
        for subscription in self.subscriptions
        {
            subscription.reporter?.removeSubscription(id: subscription.id)
        }
    }

    private var subscriptions = [ReporterSubscription]()

    func addSubscription(_ subscription: ReporterSubscription)
    {
        self.subscriptions.append(subscription)
    }

}

/**
Simple no-argument closure
*/
public typealias ReporterCallback = () -> Void

/**
Internal structure to manage subscriptions.
*/
public struct ReporterSubscription
{

    let id: String
    let callback: ReporterCallback
    weak var reporter: Reporter?

    init(
        _ id: String,
        _ callback: @escaping ReporterCallback,
        _ reporter: Reporter?
    ) {
        self.id = id
        self.callback = callback
        self.reporter = reporter
    }

    public func disposed(by bag: ReporterBag)
    {
        bag.addSubscription(self)
    }

}

/**
An object that reports (broadcasts) to any number of subscribers.
You can think of Reporter as multidelegate pattern implementation.
*/
public class Reporter
{

    /**
    Name might be helpful in telling different instances apart
    */
    public var name: String

    /**
    Create Reporter instance.

     - parameter name: might be helpful in telling different instances apart
    */
    public init(name: String = "")
    {
        self.name = name
    }

    private var subscriptions = [ReporterSubscription]()
    private var oneTimeSubscriptions = [ReporterSubscription]()

    /**
    Report (broadcast) a change to all subscribers on the main queue
    */
    public func report()
    {
        DispatchQueue.main.async {
            for subscription in self.subscriptions
            {
                subscription.callback()
            }

            // Call one-time subscribers.
            for subscription in self.oneTimeSubscriptions
            {
                subscription.callback()
            }
            // Clear.
            self.oneTimeSubscriptions = []
        }
    }

    /**
    Subscribe a callback to be executed each time this instances reports (broadcasts).

    You may want to append `.disposed(by:)` to control this subscription's lifetime.
    See ReporterBag for details.

    - parameter callback: Simple no-argument closure to execute
    */
    @discardableResult
    public func subscribe(
        _ callback: @escaping ReporterCallback
    ) -> ReporterSubscription {
        let id = UUID().uuidString
        self.subscriptions.append(ReporterSubscription(id, callback, self))
        return self.subscriptions.last!
    }

    /**
    Subscribe a callback to be executed only once.

    You may want to append `.disposed(by:)` to control this subscription's lifetime.
    See ReporterBag for details.

    - parameter callback: Simple no-argument closure to execute
    */
    @discardableResult
    public func subscribeOnce(
        _ callback: @escaping ReporterCallback
    ) -> ReporterSubscription {
        let id = UUID().uuidString
        self.oneTimeSubscriptions.append(ReporterSubscription(id, callback, self))
        return self.oneTimeSubscriptions.last!
    }

    func removeSubscription(id: String)
    {
        var index = 0
        for subscription in self.subscriptions
        {
            if subscription.id == id
            {
                self.subscriptions.remove(at: index)
                return
            }
            index = index + 1
        }
    }

}

// MARK: - Use any UIView inside a table view cell.

class UITableViewCellTemplate<ItemView: UIView>: UITableViewCell
{
    var itemView: ItemView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Create and embed item view.
        self.itemView = ItemView()
        self.contentView.embeddedView = self.itemView
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("UITableViewCellTemplate. ERROR: init(coder:) not implemented")
    }
}

// MARK: - Flexible stacking of views

func startLastView(forVC vc: UIViewController) -> UIView
{
    // Create zero height view just to serve as the first `lastView`.
    let view = UIView()
    vc.view.addSubview(view)
    view.heightAnchor == 0

    // Attach it to the safe area's top.
    if #available(iOS 11.0, *)
    {
        view.topAnchor == vc.view.safeAreaLayoutGuide.topAnchor
        view.leftAnchor == vc.view.safeAreaLayoutGuide.leftAnchor
        view.rightAnchor == vc.view.safeAreaLayoutGuide.rightAnchor
    }
    else
    {
        view.topAnchor == vc.topLayoutGuide.bottomAnchor
        view.leftAnchor == vc.view.leftAnchor
        view.rightAnchor == vc.view.rightAnchor
    }

    return view
}

func finishLastView(_ view: UIView, forVC vc: UIViewController)
{
    if #available(iOS 11.0, *)
    {
        view.bottomAnchor == vc.view.safeAreaLayoutGuide.bottomAnchor
    }
    else
    {
        view.bottomAnchor == vc.bottomLayoutGuide.topAnchor
    }
}

