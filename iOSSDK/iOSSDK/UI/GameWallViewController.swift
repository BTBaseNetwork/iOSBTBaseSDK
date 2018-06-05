//
//  GameWallViewController.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import SDWebImage
import StoreKit
import UIKit

class GameWallBannerItemCell: UITableViewCell {
    static let reuseId = "GameWallBannerItemCell"

    @IBOutlet var playVideoButton: UIButton! {
        didSet {
            playVideoButton.setImage(playVideoButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
            playVideoButton.imageView?.tintColor = UIColor.red
        }
    }

    @IBOutlet var playGameButton: UIButton! {
        didSet {
            playGameButton.setImage(playGameButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
            playGameButton.imageView?.tintColor = UIColor.blue
        }
    }

    @IBOutlet var itemIcon: UIImageView! {
        didSet {
            itemIcon.layer.cornerRadius = 8
            itemIcon.layer.masksToBounds = true
        }
    }

    @IBOutlet var gameTitle: UILabel!
    @IBOutlet var star0: UIImageView!
    @IBOutlet var star1: UIImageView!
    @IBOutlet var star2: UIImageView!
    @IBOutlet var star3: UIImageView!
    @IBOutlet var star4: UIImageView!
    var starImages: [UIImageView] { return [star0, star1, star2, star3, star4] }

    weak var rootController: UIViewController?

    static let iconPlaceholder = UIImage.BTSDKUIImage(named: "ikons_205")

    var gameWallItem: BTGameWallItem! {
        didSet {
            itemIcon.sd_setImage(with: URL(string: gameWallItem.iconUrl!), placeholderImage: GameWallBannerItemCell.iconPlaceholder)
            gameTitle.text = gameWallItem.gameName
            for i in 0 ..< starImages.count {
                if Float(i) < gameWallItem.stars {
                    starImages[i].tintColor = UIColor.yellow
                } else if Float(i) < gameWallItem.stars + 0.5 {
                    starImages[i].tintColor = UIColor.yellow.withAlphaComponent(0.5)
                } else {
                    starImages[i].tintColor = UIColor.clear
                }
            }
        }
    }

    @IBAction func onClickPlayVideo(_: Any) {
    }

    @IBAction func onClickPlayGame(_: Any) {
        let url = URL(string: gameWallItem.appLink.iOSUrlScheme)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:]) { suc in
                if !suc {
                    self.showAppProductViewController()
                }
            }
        } else {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            } else {
                showAppProductViewController()
            }
        }
    }

    func showAppProductViewController() {
        if let appId = gameWallItem?.appLink?.iOSAppId, let rootVc = rootController {
            let vc = SKStoreProductViewController()
            vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: appId], completionBlock: nil)
            rootVc.present(vc, animated: true, completion: nil)
        }
    }
}

class GameWallViewController: UIViewController {
    var gamewall: BTGameWall!
    @IBOutlet var tableView: UITableView!

    @IBAction func onClickClose(_: Any) {
        BTBaseHomeEntry.closeHomeController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        gamewall = BTServiceContainer.getGameWall()
        gamewall.loadCachedGamewallConfig()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(onGameWallListUpdated(a:)), name: BTGameWall.onGameWallListUpdated, object: nil)
        gamewall.refreshGameWallList()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func onGameWallListUpdated(a _: Notification) {
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension GameWallViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return gamewall?.gameItemCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GameWallBannerItemCell.reuseId, for: indexPath) as! GameWallBannerItemCell
        cell.gameWallItem = gamewall.getItem(index: indexPath.row)
        cell.rootController = self
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 72
    }
}
