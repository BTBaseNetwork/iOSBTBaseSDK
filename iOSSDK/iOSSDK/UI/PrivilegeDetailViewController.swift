//
//  PrivilegeDetailViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2019/1/9.
//  Copyright © 2019 btbase. All rights reserved.
//

import UIKit

class PrivilegeCell: UITableViewCell {
    
    static let cellHeight:CGFloat = 86
    static let reuseId = "PrivilegeCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
}

class PrivilegeDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = UIColor.clear
    }
    
    @IBAction func onClickClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    static func show(rootVC:UIViewController){
        if let bundle = Bundle.iOSBTBaseSDKUI{
            let vc = instanceFromStoryBoard(BTBaseMainStoryboard, identifier: "PrivilegeDetailViewController", bundle: bundle) as! PrivilegeDetailViewController
            let nvc = UINavigationController(rootViewController: vc)
            nvc.navigationBar.barStyle = .blackTranslucent
            nvc.navigationBar.tintColor = BTBaseUIConfig.GlobalTintColor
            rootVC.present(nvc, animated: true, completion: nil)
        }
    }
}

typealias PrivilegeCellModel = (iconLocKey:String,titleLocKey:String,descLocKey:String)

private let privileges:[PrivilegeCellModel] = [
    ("BTLocMemberPrivIcon0","BTLocMemberPrivTitle0","BTLocMemberPrivDesc0"),
    ("BTLocMemberPrivIcon1","BTLocMemberPrivTitle1","BTLocMemberPrivDesc1"),
    ("BTLocMemberPrivIcon2","BTLocMemberPrivTitle2","BTLocMemberPrivDesc2"),
    ("BTLocMemberPrivIcon3","BTLocMemberPrivTitle3","BTLocMemberPrivDesc3")
]

//MARK: UITableViewDelegate
extension PrivilegeDetailViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return privileges.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return PrivilegeCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PrivilegeCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PrivilegeCell.reuseId, for: indexPath) as! PrivilegeCell
        let model = privileges[indexPath.row]
        cell.iconImageView.image = UIImage.BTSDKUIImage(named: model.iconLocKey.localizedBTBaseString)
        cell.titleLabel.text = model.titleLocKey.localizedBTBaseString
        cell.descLabel.text = model.descLocKey.localizedBTBaseString
        return cell
    }
}
