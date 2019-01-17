//
//  AddUpdateUserAssetsViewController.swift
//  SDKTest
//
//  Created by Alex Chow on 2019/1/17.
//  Copyright © 2019 btbase. All rights reserved.
//

import UIKit
import BTBaseSDK

extension UIViewController{
    func showAlert(title:String?,msg:String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}

class AddUpdateUserAssetsViewController: UIViewController {

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var assetsTextField: UITextField!
    @IBOutlet weak var assetIdTextField: UITextField!
    @IBOutlet weak var recordIdLabel: UILabel!
    @IBOutlet weak var bundleLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var isAdd = false
    
    var assets:BTUserAssets!
    
    private func refreshUI(){
        categoryTextField?.text = assets?.category
        amountTextField?.text = "\(assets?.amount ?? 1)"
        assetsTextField?.text = assets?.assets
        assetIdTextField?.text = assets?.assetsId
        recordIdLabel?.text = "\(assets?.id ?? 0)"
        bundleLabel?.text = Bundle.main.bundleIdentifier
        accountLabel?.text = assets?.accountId
    }
    
    @IBAction func onClickAdd(_ sender: Any) {
        if let service = BTBaseSDK.userAssetsService(){
            assets.amount = Int(self.amountTextField.text ?? "1") ?? 1
            assets.category = self.categoryTextField.text
            assets.assetsId = self.assetIdTextField.text
            assets.assets = self.assetsTextField.text
            service.addNewAssets(newAssets: assets) { (resAssets) in
                if let a = resAssets{
                    self.assets = a
                    DispatchQueue.main.async {
                        self.refreshUI()
                        self.showAlert(title: "Added", msg: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", msg: "No Result Return")
                    }
                }
            }
        }
    }
    
    @IBAction func onClickUpdate(_ sender: Any) {
        if let service = BTBaseSDK.userAssetsService(){
            assets.amount = Int(self.amountTextField.text ?? "1") ?? 1
            assets.category = self.categoryTextField.text
            assets.assetsId = self.assetIdTextField.text
            assets.assets = self.assetsTextField.text
            service.updateAssets(modifiedAssets: assets) { (resAssets) in
                if let a = resAssets{
                    self.assets = a
                    DispatchQueue.main.async {
                        self.refreshUI()
                        self.showAlert(title: "Update OK", msg: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", msg: "No Result Return")
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addButton.isHidden = !isAdd
        self.updateButton.isHidden = isAdd
        self.assetIdTextField.isEnabled = isAdd
        self.categoryTextField.isEnabled = isAdd
        refreshUI()
    }
    
    static func addUserAssets(nvc:UINavigationController) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddUpdateUserAssetsViewController") as! AddUpdateUserAssetsViewController
        let assets = BTUserAssets()
        assets.category = "Test"
        assets.amount = 1
        assets.assets = "Test"
        assets.assetsId = "TestAssetsId"
        assets.accountId = "Default"
        vc.assets = assets
        vc.isAdd = true
        nvc.pushViewController(vc, animated: true)
    }
    
    static func updateUserAssets(nvc:UINavigationController,assets:BTUserAssets) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddUpdateUserAssetsViewController") as! AddUpdateUserAssetsViewController
        vc.assets = assets
        vc.isAdd = false
        nvc.pushViewController(vc, animated: true)
    }
}
