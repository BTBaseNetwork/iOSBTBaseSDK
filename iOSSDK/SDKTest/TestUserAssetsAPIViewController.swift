//
//  TestUserAssetsAPIViewController.swift
//  SDKTest
//
//  Created by Alex Chow on 2019/1/17.
//  Copyright © 2019 btbase. All rights reserved.
//

import UIKit
import BTBaseSDK

class UserAssetsCell: UITableViewCell {
    static let reuseId = "UserAssetsCell"
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
}

class TestUserAssetsAPIViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectRetrieveTypeButton: UIButton!
    @IBOutlet weak var retrieveTypeTextField: UITextField!
    
    enum RetrieveType {
        case all,assetsId,category
    }
    
    var retrieveType = RetrieveType.all{
        didSet{
            switch retrieveType {
            case .all:
                selectRetrieveTypeButton?.setTitle("All", for: .normal)
                retrieveTypeTextField.isEnabled = false
            case .assetsId:
                selectRetrieveTypeButton?.setTitle("AssetsId", for: .normal)
                retrieveTypeTextField.isEnabled = true
            case .category:
                selectRetrieveTypeButton?.setTitle("Category", for: .normal)
                retrieveTypeTextField.isEnabled = true
            }
        }
    }
    
    var userAssets:[BTUserAssets]!{
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.retrieveTypeTextField.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !BTBaseSDK.isLogined {
            let alert = UIAlertController(title: "Login First", message: "Need Login", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel) { (ac) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClickAddUserAssets(_ sender: Any) {
        if let nvc = self.navigationController{
            AddUpdateUserAssetsViewController.addUserAssets(nvc: nvc)
        }
    }
    
    @IBAction func onClickSelectRetrieveType(_ sender: Any) {
        let actionAll = UIAlertAction(title: "All", style: .default) { (ac) in
            self.retrieveType = .all
        }
        
        let actionAssetsId = UIAlertAction(title: "AssetsId", style: .default) { (ac) in
            self.retrieveType = .assetsId
        }
        
        let actionCategory = UIAlertAction(title: "Category", style: .default) { (ac) in
            self.retrieveType = .category
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = UIAlertController(title: "Select A Retrieve Type", message: nil, preferredStyle: .alert)
        alert.addAction(actionAll)
        alert.addAction(actionAssetsId)
        alert.addAction(actionCategory)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClickRetrieve(_ sender: Any) {
        switch retrieveType {
        case .all:
            BTBaseSDK.userAssetsService()?.retrieveUserAssets(callback: { (assets) in
                self.userAssets = assets
            })
        case .assetsId:
            if let id = self.retrieveTypeTextField.text{
                BTBaseSDK.userAssetsService()?.retrieveUserAssets(byAssetsId: id, callback: { (assets) in
                    self.userAssets = assets
                })
            }
        case .category:
            if let cat = self.retrieveTypeTextField.text{
                BTBaseSDK.userAssetsService()?.retrieveUserAssets(byCategory: cat, callback: { (assets) in
                    self.userAssets = assets
                })
            }
        }
        
    }
}

extension TestUserAssetsAPIViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAssets.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return userAssets != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserAssetsCell.reuseId, for: indexPath) as! UserAssetsCell
        let model = userAssets[indexPath.row]
        cell.topLabel.text = "\(model.category ?? "Empty"):\(model.assetsId ?? "Empty"):\(model.id)"
        cell.bottomLabel.text = "\(model.assets ?? "Empty"):\(model.id)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let nvc = self.navigationController{
            let model = userAssets[indexPath.row]
            AddUpdateUserAssetsViewController.updateUserAssets(nvc: nvc, assets: model)
        }
    }
}
