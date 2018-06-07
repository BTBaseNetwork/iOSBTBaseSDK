//
//  MemberViewController.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import UIKit

class MemberViewController: UIViewController {
    override func viewWillAppear(_: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(onMemberProfileUpdated(a:)), name: BTMemberService.onLocalMemberProfileUpdated, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onMemberProfileUpdated(a _: Notification) {
    }
}
