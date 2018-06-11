//
//  AccountViewController.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit

class AccountDisplayItemCell: UITableViewCell {
    static let reuseId = "AccountDisplayItemCell"
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
}

class AccountEditableItemCell: UITableViewCell {
    static let reuseId = "AccountEditableItemCell"
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var editableTagImage: UIImageView! {
        didSet {
            editableTagImage.tintColor = UIColor.lightGray
        }
    }
}

class AccountViewController: UIViewController {
    static let logoutGameCellReuseId = "LogoutGameCell"
    static let logoutDeviceCellReuseId = "LogoutDeviceCell"

    @IBOutlet var tableView: UITableView!
    var accountService: BTAccountService!
    var sessionService: BTSessionService!

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        accountService = BTServiceContainer.getBTAccountService()
        sessionService = BTServiceContainer.getBTSessionService()
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(onAccoutProfileUpdated(a:)), name: BTAccountService.onLocalAccountUpdated, object: nil)
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func onAccoutProfileUpdated(a _: Notification) {
        tableView.reloadData()
    }

    deinit {
        debugLog("Deinited:\(self.description)")
    }
}

extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return (sessionService?.isSessionLogined ?? false) ? 3 : 0
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section > 0 {
            return 1
        } else {
            return 5
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section > 0 {
            if indexPath.section == 1 {
                return tableView.dequeueReusableCell(withIdentifier: AccountViewController.logoutGameCellReuseId, for: indexPath)
            } else if indexPath.section == 2 {
                return tableView.dequeueReusableCell(withIdentifier: AccountViewController.logoutDeviceCellReuseId, for: indexPath)
            }
        } else if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AccountDisplayItemCell.reuseId, for: indexPath) as! AccountDisplayItemCell
            cell.nameLabel.text = "BTLocAccountId".localizedBTBaseString
            cell.valueLabel.text = accountService.localAccount.accountId
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AccountDisplayItemCell.reuseId, for: indexPath) as! AccountDisplayItemCell
            cell.nameLabel.text = "BTLocUsername".localizedBTBaseString
            cell.valueLabel.text = accountService.localAccount.accountId
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AccountEditableItemCell.reuseId, for: indexPath) as! AccountEditableItemCell
            cell.nameLabel.text = "BTLocNick".localizedBTBaseString
            cell.valueLabel.text = accountService.localAccount.nick
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AccountEditableItemCell.reuseId, for: indexPath) as! AccountEditableItemCell
            cell.nameLabel.text = "BTLocEmail".localizedBTBaseString
            cell.valueLabel.text = accountService.localAccount.email
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AccountEditableItemCell.reuseId, for: indexPath) as! AccountEditableItemCell
            cell.nameLabel.text = "BTLocPassword".localizedBTBaseString
            cell.valueLabel.text = "********"
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: AccountDisplayItemCell.reuseId, for: indexPath) as! AccountDisplayItemCell
        cell.nameLabel.text = "Error Property"
        cell.valueLabel.text = "Fix Issue"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0 {
            if indexPath.section == 1 {
                let ok = UIAlertAction(title: "BTLocLogoutGame".localizedBTBaseString, style: .default) { _ in
                    self.sessionService?.logoutClient()
                }
                showAlert("BTLocLogoutGame".localizedBTBaseString, msg: "BTLocMsgLogoutGame".localizedBTBaseString, actions: [ALERT_ACTION_CANCEL, ok])
            } else if indexPath.section == 2 {
                let ok = UIAlertAction(title: "BTLocLogoutDevice".localizedBTBaseString, style: .default) { _ in
                    self.sessionService?.logoutDevice()
                }
                showAlert("BTLocLogoutDevice".localizedBTBaseString, msg: "BTLocMsgLogoutDevice".localizedBTBaseString, actions: [ALERT_ACTION_CANCEL, ok])
            }
        } else if indexPath.row == 2 {
            performSegue(withIdentifier: "UpdateNick", sender: self)
        } else if indexPath.row == 3 {
            performSegue(withIdentifier: "UpdateEmail", sender: self)
        } else if indexPath.row == 4 {
            performSegue(withIdentifier: "UpdatePassword", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section > 0 {
            return 56
        } else {
            return 64
        }
    }
}
