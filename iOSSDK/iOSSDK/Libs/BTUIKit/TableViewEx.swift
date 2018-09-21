//
//  TableViewEx.swift
//  Vessage
//
//  Created by Alex Chow on 2017/3/30.
//  Copyright © 2017年 Bahamut. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    func setSeparatorFullWidth() {
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
    }
}

extension UITableView {
    func autoRowHeight() {
        estimatedRowHeight = rowHeight
        rowHeight = UITableView.automaticDimension
    }
}
