//
//  GameWallViewController.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//

import MobilePlayer
import SDWebImage
import StoreKit
import UIKit

class GameWallBannerItemCell: UITableViewCell {
    static let reuseId = "GameWallBannerItemCell"

    @IBOutlet var playVideoButton: UIButton!

    @IBOutlet var playGameButton: UIButton!

    @IBOutlet var itemIcon: UIImageView! {
        didSet {
            itemIcon.clipsToBounds = true
            itemIcon.layer.cornerRadius = 8
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

    static let iconPlaceholder: UIImage? = { UIImage.BTSDKUIImage(named: "ikons_grid_2")?.withRenderingMode(.alwaysTemplate) }()
    static let starIconTintColor: UIColor = { UIColor(hexString: "#FEB406") }()

    var gameWallItem: BTGameWallItem! {
        didSet {
            let itemIconUrl = URL(string: gameWallItem.iconUrl!)
            itemIcon.tintColor = BTBaseUIConfig.GlobalTintColor
            itemIcon.sd_setImage(with: itemIconUrl, placeholderImage: GameWallBannerItemCell.iconPlaceholder)
            gameTitle.text = gameWallItem.getLocalizedGameName()
            for i in 0 ..< starImages.count {
                if Float(i) < gameWallItem.stars {
                    starImages[i].tintColor = GameWallBannerItemCell.starIconTintColor.withAlphaComponent(1)
                } else if Float(i) < gameWallItem.stars + 0.5 {
                    starImages[i].tintColor = GameWallBannerItemCell.starIconTintColor.withAlphaComponent(0.5)
                } else {
                    starImages[i].tintColor = GameWallBannerItemCell.starIconTintColor.withAlphaComponent(0)
                }
            }
        }
    }

    @IBAction func onClickPlayVideo(_: Any) {
        let videoURL = URL(string: gameWallItem.videoUrl)!
        let playerVC = MobilePlayerViewController(contentURL: videoURL)
        playerVC.title = gameTitle.text
        let gameUrl = URL(string: "itms-apps://itunes.apple.com/app/id\(gameWallItem.appLink.iOSAppId!)")!
        playerVC.activityItems = [gameTitle.text ?? "", gameUrl]
        if let img = self.itemIcon.image {
            playerVC.activityItems?.append(img)
        }
        rootController?.present(playerVC, animated: true, completion: nil)
    }

    @IBAction func onClickPlayGame(_: Any) {
        let gameName = gameWallItem.getLocalizedGameName()
        let title = String(format: "BTLocTitleOpenGameXOrOpenStore".localizedBTBaseString, gameName)
        let msg = String(format: "BTLocMsgOpenGameXOrOpenStore".localizedBTBaseString, gameName)
        let ok = UIAlertAction(title: "BTLocPlayNow".localizedBTBaseString, style: .default) { _ in
            self.playGame()
        }
        rootController?.showAlert(title, msg: msg, actions: [ALERT_ACTION_CANCEL, ok])
    }

    func playGame() {
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
            vc.delegate = self
        }
    }

    deinit {
        debugLog("Deinited:\(self.description)")
    }
}

extension GameWallBannerItemCell: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

class GameWallViewController: UIViewController {
    var gamewall: BTGameWall!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loadingProgressView: UIProgressView! {
        didSet {
            loadingProgressView.isHidden = true
        }
    }

    @IBOutlet var refreshButton: UIButton! {
        didSet {
            refreshButton.SetupBTBaseUI()
        }
    }

    private var loadingTimer: Timer!
    private var loading: Bool {
        get {
            return !loadingProgressView.isHidden
        }
        set {
            if let _ = loadingProgressView {
                if loadingProgressView.isHidden == newValue {
                    loadingProgressView.isHidden = !newValue
                    if newValue {
                        refreshButton?.isHidden = true
                        loadingProgressView.progress = 0
                        loadingTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(loadingTimerTick(t:)), userInfo: nil, repeats: true)
                    } else {
                        refreshButton?.isHidden = (gamewall?.gameItemCount ?? 0) > 0
                        loadingTimer?.invalidate()
                        loadingTimer = nil
                    }
                }
            }
        }
    }

    @objc private func loadingTimerTick(t _: Timer) {
        if let pv = loadingProgressView {
            pv.progress += 0.1
            if pv.progress >= 1 {
                pv.progress = 0
            }
        }
    }

    @IBAction func onClickRefresh(_: Any) {
        refreshGamewallList()
    }

    @IBAction func onClickClose(_: Any) {
        BTBaseHomeEntry.closeHomeController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        gamewall = BTServiceContainer.getGameWall()
        gamewall.loadCachedGamewallConfig()
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        refreshGamewallList()
    }

    func refreshGamewallList() {
        if !loading {
            loading = true
            gamewall.refreshGameWallList {
                self.loading = false
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onGameWallListUpdated(a:)), name: BTGameWall.onGameWallListUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onClickTabbarItem(a:)), name: BTBaseHomeController.DidSelectViewController, object: nil)
        tableView.reloadData()
    }

    var lastClickTabbarDate = Date()
    @objc private func onClickTabbarItem(a: Notification) {
        if let vc = a.userInfo?[kDidSelectViewController] as? UIViewController, vc == self.navigationController {
            if abs(lastClickTabbarDate.timeIntervalSinceNow) < 1 {
                refreshGamewallList()
            } else {
                lastClickTabbarDate = Date()
            }
        }
    }

    @objc private func onGameWallListUpdated(a _: Notification) {
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        loadingTimer?.invalidate()
        loadingTimer = nil
        debugLog("Deinited:\(self.description)")
    }
}

extension GameWallViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        let cnt = gamewall?.gameItemCount ?? 0
        return cnt
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GameWallBannerItemCell.reuseId, for: indexPath) as! GameWallBannerItemCell
        cell.gameWallItem = gamewall.getItem(index: indexPath.row)
        cell.rootController = self
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 76
    }
}
