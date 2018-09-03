//
//  GameWallViewController.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//
import AVKit
import AVPlayerCacheSupport
import BTSDK_SDWebImage
import StoreKit
import UIKit

fileprivate let GameWallBannerItemRowHeight: CGFloat = 76

class GameWallBannerItemCell: UITableViewCell, AVPlayerViewControllerDelegate {
    static let reuseId = "GameWallBannerItemCell"

    @IBOutlet var playVideoButton: UIButton!

    @IBOutlet var playGameButton: UIButton!

    @IBOutlet var itemIcon: UIImageView! {
        didSet {
            itemIcon.clipsToBounds = true
            itemIcon.layer.cornerRadius = 8
        }
    }

    @IBOutlet var new: UIImageView! {
        didSet {
            new.tintColor = UIColor(hexString: "#1D9BF6")
        }
    }

    @IBOutlet var hot: UIImageView! {
        didSet {
            hot.tintColor = UIColor(hexString: "#FC2125")
        }
    }

    @IBOutlet var gameStatusLabel: UILabel!
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
            itemIcon.tintColor = BTBaseUIConfig.GlobalTintColor
            itemIcon.sd_setImage(with: URL(string: gameWallItem.localizedIconUrl), placeholderImage: GameWallBannerItemCell.iconPlaceholder)
            gameTitle.text = gameWallItem.localizedGameName
            playVideoButton.isHidden = String.isNullOrWhiteSpace(gameWallItem.localizedVideoUrl)

            new.isHidden = !gameWallItem.hasNewLabel // Raw Value: 1
            hot.isHidden = !gameWallItem.hasHotLabel // Raw Value: 2

            let showStars = !gameWallItem.isComingSoon && !gameWallItem.isReservable
            setStars(showStars: showStars, stars: gameWallItem.stars)
            updateGameStatusLabel()
        }
    }

    private func updateGameStatusLabel() {
        gameStatusLabel.isHidden = false
        if gameWallItem.isComingSoon {
            gameStatusLabel.text = "BTLocGameStatusComingSoon".localizedBTBaseString
        } else if gameWallItem.isReservable {
            gameStatusLabel.text = "BTLocGameStatusReservable".localizedBTBaseString
        } else {
            gameStatusLabel.isHidden = true
        }
    }

    private func setStars(showStars: Bool, stars: Float) {
        for i in 0 ..< starImages.count {
            starImages[i].isHidden = false
            if !showStars {
                starImages[i].isHidden = true
            } else if i < Int(stars) {
                starImages[i].tintColor = GameWallBannerItemCell.starIconTintColor.withAlphaComponent(1)
            } else if i < Int(stars + 0.5) {
                starImages[i].tintColor = GameWallBannerItemCell.starIconTintColor.withAlphaComponent(0.5)
            } else {
                starImages[i].tintColor = GameWallBannerItemCell.starIconTintColor.withAlphaComponent(0)
            }
        }
    }

    @IBAction func onClickPlayVideo(_: Any) {
        let videoUrl = URL(string: gameWallItem.localizedVideoUrl)!

        if let item = try? AVPlayerItem.mc_playerItem(withRemoteURL: videoUrl) {
            let player = AVPlayer(playerItem: item)
            let vc = BTVideoPlayerViewController()
            vc.player = player
            let playVideoBtn = playVideoButton
            vc.didDisappearAction = {
                UIView.animate(withDuration: 0.3, animations: {
                    playVideoBtn?.transform = CGAffineTransform(scaleX: 1, y: 1)
                    playVideoBtn?.alpha = 1
                }) { _ in
                }
            }

            vc.loopVideo = gameWallItem.videoLoop
            vc.closeVideoOnEnd = gameWallItem.closeVideo

            UIView.animate(withDuration: 0.3, animations: {
                playVideoBtn?.transform = CGAffineTransform(scaleX: 3.6, y: 3.6)
                playVideoBtn?.alpha = 0
            }) { _ in
                self.rootController?.present(vc, animated: true) {
                    vc.player?.play()
                }
            }
        }
    }

    @IBAction func onClickPlayGame(_: Any) {
        let gameName = gameWallItem.localizedGameName
        var title = ""
        var msg = ""
        var actions = [UIAlertAction]()
        if gameWallItem.isComingSoon {
            title = gameName
            msg = String(format: "BTLocMsgGameComingSoon".localizedBTBaseString, gameName)
            actions.append(ALERT_ACTION_OK)
        } else if gameWallItem.isReservable {
            title = gameName
            msg = String(format: "BTLocMsgOpenStoreToReserve".localizedBTBaseString, gameName)
            actions.append(ALERT_ACTION_CANCEL)
            actions.append(UIAlertAction(title: "BTLocReserveGame".localizedBTBaseString, style: .default, handler: { _ in
                self.showAppProductViewController()
            }))
        } else {
            title = String(format: "BTLocTitleOpenGameXOrOpenStore".localizedBTBaseString, gameName)
            msg = String(format: "BTLocMsgOpenGameXOrOpenStore".localizedBTBaseString, gameName)
            BTBaseSDK.shareAuthentication()
            let ok = UIAlertAction(title: "BTLocPlayNow".localizedBTBaseString, style: .default) { _ in
                self.playGame()
            }
            let cancel = UIAlertAction(title: "CANCEL".bahamutCommonLocalizedString, style: .cancel) { _ in
                #if RELEASE
                BTBaseSDK.clearSharedAuthentication()
                #endif
            }
            actions.append(cancel)
            actions.append(ok)
        }

        rootController?.showAlert(title, msg: msg, actions: actions)
    }

    func playGame() {
        if let appId = BTBaseSDK.config.appStoreID, appId == gameWallItem.appLink.iOSAppId {
            BTBaseHomeEntry.closeHomeController()
            return
        }
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
            if UIApplication.shared.statusBarOrientation.isPortrait {
                let vc = SKStoreProductViewController()
                vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: appId], completionBlock: nil)
                rootVc.present(vc, animated: true, completion: nil)
                vc.delegate = self
            } else if let url = URL(string: "https://itunes.apple.com/app/id\(appId)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
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
    var gamewallItems = [BTGameWallItem]()

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
            if loading == newValue {
                return
            }

            refreshButton?.isHidden = gamewallItems.count > 0 || newValue
            loadingProgressView?.isHidden = !newValue
            if newValue {
                loadingProgressView.progress = 0
                loadingTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(loadingTimerTick(t:)), userInfo: nil, repeats: true)
            } else {
                loadingTimer?.invalidate()
                loadingTimer = nil
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
        refreshGamewallList(force: true)
    }

    @IBAction func onClickClose(_: Any) {
        BTBaseHomeEntry.closeHomeController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        BTServiceContainer.getGameWall()?.loadCachedGamewallConfig()
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = view.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        refreshGamewallList()
    }

    func refreshGamewallList(force: Bool = false) {
        if !loading, let gw = BTServiceContainer.getGameWall() {
            loading = true
            gw.refreshGameWallList(force: force) {
                self.loading = false
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onGameWallListUpdated(a:)), name: BTGameWall.onGameWallListUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onClickTabbarItem(a:)), name: BTBaseHomeController.DidSelectViewController, object: nil)
    }

    @objc private func onClickTabbarItem(a: Notification) {
        let vc = a.userInfo?[kDidSelectViewController] as? UIViewController
        let lastVc = a.userInfo?[kLastSelectViewController] as? UIViewController
        let lastClickTabbarDate = a.userInfo?[kLastClickTabBarItemDate] as! Date

        if vc == navigationController {
            if vc == lastVc {
                if tableView.contentOffset.y > 0 {
                    if tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 0 {
                        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                } else if abs(lastClickTabbarDate.timeIntervalSinceNow) < 1 {
                    refreshGamewallList(force: true)
                }
            } else {
                tableView.reloadData()
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
        gamewallItems = BTServiceContainer.getGameWall()?.getSortedItemsByPriority() ?? []
        refreshButton?.isHidden = gamewallItems.count > 0 || loading
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return gamewallItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GameWallBannerItemCell.reuseId, for: indexPath) as! GameWallBannerItemCell
        cell.rootController = self
        cell.gameWallItem = gamewallItems[indexPath.row]
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return GameWallBannerItemRowHeight
    }
}
