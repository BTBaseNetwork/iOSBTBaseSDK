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
        BTServiceContainer.getBTMemberService()?.purchaseMemberProduct(p: product)
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
        }
        return products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MemberCardCell.reuseId, for: indexPath) as! MemberCardCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: MemberProductCell.reuseId, for: indexPath) as! MemberProductCell
        cell.product = products[indexPath.row]
        return cell
    }
    
    @objc func onMemberProductsUpdated(a _: Notification) {
        products = BTServiceContainer.getBTMemberService()!.products.map { $0 }.sorted(by: { (a, b) -> Bool in
            a.price.doubleValue < b.price.doubleValue
        })
    }
}
