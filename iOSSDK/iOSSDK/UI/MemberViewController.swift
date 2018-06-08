//
//  MemberViewController.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import StoreKit
import UIKit

class MemberCardCell: UITableViewCell {
    static let reuseId = "MemberCardCell"
    
    @IBOutlet var memberTypeLabel: UILabel!
    
    @IBOutlet var expiredOnDateLabel: UILabel!
    
    @IBOutlet var unloginView: UIVisualEffectView!
    
    @IBAction func onClickSignIn(_: Any) {
        BTBaseHomeEntry.getEntryViewController().performSegue(withIdentifier: "SignIn", sender: nil)
    }
    
    func refresh() {
        if !BTServiceContainer.getBTSessionService()!.isSessionLogined {
            unloginView.isHidden = false
            memberTypeLabel.text = "BTLocMemberTypeNotLogin".localizedBTBaseString
            expiredOnDateLabel.text = "BTLocMemberTypeNotLogin".localizedBTBaseString
        } else {
            unloginView.isHidden = true
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
}

class MemberProductCell: UITableViewCell {
    static let reuseId = "MemberProductCell"
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var purchaseButton: UIButton!
    
    var product: SKProduct! {
        didSet {
            if product == nil {
                purchaseButton.isEnabled = false
            } else {
                titleLabel?.text = product.localizedTitle
                priceLabel?.text = product.localizedPrice
                descLabel?.text = product.localizedDescription
                purchaseButton.isEnabled = true
            }
        }
    }
    
    @IBAction func onClickPurchase(_: Any) {
        BTServiceContainer.getBTMemberService()?.purchaseMemberProduct(p: product){ suc in
            
        }
    }
}

class MemberViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var products: [SKProduct]! {
        didSet {
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_: Bool) {
        tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(onMemberProfileUpdated(a:)), name: BTMemberService.onLocalMemberProfileUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onMemberProductsUpdated(a:)), name: BTMemberService.onMemberProductsUpdated, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onMemberProfileUpdated(a _: Notification) {
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

extension MemberViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 2
    }
    
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return products?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MemberCardCell.reuseId, for: indexPath) as! MemberCardCell
            cell.refresh()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MemberProductCell.reuseId, for: indexPath) as! MemberProductCell
            cell.product = products[indexPath.row]
            return cell
        }
    }
    
    @objc func onMemberProductsUpdated(a _: Notification) {
        products = BTServiceContainer.getBTMemberService()!.products.map { $0 }.sorted(by: { (a, b) -> Bool in
            a.price.doubleValue < b.price.doubleValue
        })
    }
    
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        }
        return 64
    }
}
