//
//  MemberViewController.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import MBProgressHUD
import StoreKit
import UIKit

class MemberCardCell: UITableViewCell {
    static let reuseId = "MemberCardCell"
    
    @IBOutlet var memberTypeLabel: UILabel!
    
    @IBOutlet var expiredOnDateLabel: UILabel!
    
    func refresh() {
        let service = BTServiceContainer.getBTMemberService()!
        if let member = service.localProfile.preferredMember {
            switch member.memberType {
            case BTMember.MEMBER_TYPE_PREMIUM: memberTypeLabel.text = "BTLocMemberTypePremium".localizedBTBaseString
            case BTMember.MEMBER_TYPE_ADVANCED: memberTypeLabel.text = "BTLocMemberTypeAdvance".localizedBTBaseString
            default: break
            }
            if member.expiredDateTs > Date().timeIntervalSince1970 {
                let formatter = DateFormatter()
                formatter.dateFormat = "BTLocMemberExpiredDateFormat".localizedBTBaseString
                formatter.locale = Locale.current
                expiredOnDateLabel.text = formatter.string(from: Date(timeIntervalSince1970: member.expiredDateTs))
            } else {
                expiredOnDateLabel.text = "BTLocMemberOutOfDate".localizedBTBaseString
            }
        } else {
            memberTypeLabel.text = "BTLocMemberTypeNoSubscription".localizedBTBaseString
            expiredOnDateLabel.text = "BTLocMemberTypeNoSubscription".localizedBTBaseString
        }
    }
}

class MemberProductCell: UITableViewCell {
    static let reuseId = "MemberProductCell"
    var purchaseButtonObserve: Any?
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var purchaseButton: UIButton! {
        didSet {
            purchaseButton.SetupBTBaseUI()
        }
    }
    
    var product: BTMemberService.MemberProduct! {
        didSet {
            if product == nil {
                purchaseButton.isEnabled = false
            } else {
                titleLabel?.text = product.product.localizedTitle
                descLabel?.text = product.product.localizedDescription
                purchaseButton.setTitle(product.product.localizedPrice, for: .normal)
                purchaseButton.isEnabled = product.enabled
            }
        }
    }
    
    weak var rootController: UIViewController!
    
    @IBAction func onClickPurchase(_: Any) {
        let hud = rootController.showActivityHud()
        BTServiceContainer.getBTMemberService()?.purchaseMemberProduct(p: product.product) { _ in
            hud.hide(animated: true)
        }
    }
    
    deinit {
        debugLog("Deinited:\(self.description)")
    }
}

class MemberViewController: UIViewController {
    static let noMemberProductCellReuseId = "NoMemberProductCell"
    @IBOutlet var signInButton: UIButton! {
        didSet {
            signInButton.SetupBTBaseUI()
        }
    }
    
    @IBOutlet var tableView: UITableView!
    var products: [BTMemberService.MemberProduct]! {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        reloadProducts()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = view.backgroundColor
    }
    
    override func viewWillAppear(_: Bool) {
        tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(onMemberProfileUpdated(a:)), name: BTMemberService.onLocalMemberProfileUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onMemberProductsUpdated(a:)), name: BTMemberService.onMemberProductsUpdated, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onClickTabbarItem(a:)), name: BTBaseHomeController.DidSelectViewController, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onMemberProfileUpdated(a _: Notification) {
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    @objc private func onClickTabbarItem(a: Notification) {
        if let vc = a.userInfo?[kDidSelectViewController] as? UIViewController, vc == self.navigationController {
            BTServiceContainer.getBTMemberService()?.fetchIAPList()
        }
    }
    
    @IBAction func onClickSignIn(_: Any) {
        BTBaseHomeEntry.getEntryViewController().performSegue(withIdentifier: "SignIn", sender: nil)
    }
    
    deinit {
        debugLog("Deinited:\(self.description)")
    }
}

extension MemberViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        if BTServiceContainer.getBTSessionService()!.isSessionLogined {
            signInButton.isHidden = true
            return 3
        }
        signInButton.isHidden = false
        return 0
    }
    
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return products?.count ?? 0
        } else {
            return (products?.count ?? 0) > 0 ? 0 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MemberCardCell.reuseId, for: indexPath) as! MemberCardCell
            cell.refresh()
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MemberProductCell.reuseId, for: indexPath) as! MemberProductCell
            cell.product = products[indexPath.row]
            cell.rootController = self
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: MemberViewController.noMemberProductCellReuseId, for: indexPath)
        }
    }
    
    @objc func onMemberProductsUpdated(a _: Notification) {
        reloadProducts()
    }
    
    func reloadProducts() {
        if let pdset = BTServiceContainer.getBTMemberService()?.products {
            products = pdset.map { $0 }.sorted(by: { (a, b) -> Bool in
                a.product.price.doubleValue < b.product.price.doubleValue
            })
        } else {
            products = []
        }
    }
    
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else if indexPath.section == 1 {
            return 86
        } else {
            return 64
        }
    }
}
