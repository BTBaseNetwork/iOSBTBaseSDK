//
//  OrderListViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/11.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit
class OrderListCell: UITableViewCell {
    static let reuseId = "OrderListCell"
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var verifyButton: UIButton!
    
    weak var rootController: OrderListViewController?
    
    var order: BTIAPOrder! {
        didSet {
            if order == nil {
                return
            }
            titleLabel.text = order?.locTitle
            dateLabel.text = order?.date?.toLocalDateTimeSimpleString()
            priceLabel.text = order?.locPrice
            var locState = "BTLocOrderStateUnknow"
            verifyButton.isHidden = true
            switch order.state {
            case BTIAPOrder.STATE_PAY_SUC: locState = "BTLocOrderStatePaid"
            case BTIAPOrder.STATE_VERIFY_FAILED: locState = "BTLocOrderStateVerifyFailed"
            case BTIAPOrder.STATE_VERIFY_SUC: locState = "BTLocOrderStateCompleted"
            case BTIAPOrder.STATE_VERIFY_SERVER_NETWORK_ERROR:
                locState = "BTLocOrderStateVerifyNetworkError"
                verifyButton.isHidden = false
            default: break
            }
            statusLabel.text = locState.localizedBTBaseString
        }
    }
    
    var observer: NSObjectProtocol!
    @IBAction func onClickVerify(_ sender: Any) {
        if let o = order {
            verifyButton.isEnabled = false
            let hud = rootController?.showActivityHud()
            observer = NotificationCenter.default.addObserver(forName: BTMemberService.onPurchaseEvent, object: nil, queue: .main) { a in
                if let event = a.userInfo?[kBTMemberPurchaseEvent] as? Int {
                    if event == BTMemberPurchaseEventValidateFailed || event == BTMemberPurchaseEventValidateSuccess {
                        hud?.hide(animated: true)
                        if let ob = self.observer {
                            NotificationCenter.default.removeObserver(ob)
                            self.observer = nil
                            self.verifyButton?.isEnabled = true
                            self.rootController?.loadOrders()
                        }
                    }
                }
            }
            BTServiceContainer.getBTMemberService()?.verifyTransactionAndRechargeMember(order: o)
        }
    }
    
    deinit {
        if let ob = self.observer {
            NotificationCenter.default.removeObserver(ob)
        }
        debugLog("Deinited:\(self.description)")
    }
}

class OrderListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    var orders = [BTIAPOrder]() {
        didSet {
            tableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadOrders()
    }
    
    func loadOrders() {
        orders = BTIAPOrderManager.instance.getAllOrders().sorted(by: { (a, b) -> Bool in
            a.date!.timeIntervalSince1970 > b.date!.timeIntervalSince1970
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderListCell.reuseId, for: indexPath) as! OrderListCell
        cell.order = orders[indexPath.row]
        cell.rootController = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
