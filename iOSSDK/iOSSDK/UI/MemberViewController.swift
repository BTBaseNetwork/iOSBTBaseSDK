//
//  MemberViewController.swift
//  iOSSDK
//
//  Created by Alex Chow on 2018/6/3.
//  Copyright © 2018年 btbase. All rights reserved.
//
import StoreKit
import TXScrollLabelView
import UIKit

fileprivate let MemberCardRowHeight: CGFloat = 100
fileprivate let MemberProductRowHeight: CGFloat = 64
fileprivate let NoMemberTipsRowHeight: CGFloat = 64
fileprivate let MemberCardFooterHeight: CGFloat = 16
fileprivate let MemberTipsScrollingDuration: TimeInterval = 0.3
fileprivate let MemberExpiresAlertDays: Int = 3

let guestModeEnabled = true

class MemberCardCell: UITableViewCell {
    static let reuseId = "MemberCardCell"
    let memberNormalColor = UIColor.white
    let memberTintColor = BTBaseUIConfig.GlobalTintColor
    let memberAlertColor = UIColor.red
    
    weak var rootViewController: MemberViewController!
    
    @IBOutlet var memberTypeLabel: UILabel!
    
    @IBOutlet var expiresDateLabel: UILabel!
    
    func refresh() {
        let service = BTServiceContainer.getBTMemberService()!
        let member = service.localProfile.members.first
        let isGuestMode = rootViewController.isGuest
        refreshViews(member: member, guest: isGuestMode)
    }
    
    func refreshViews(member: BTMember!, guest isGuest: Bool) {
        if member != nil {
            var memberTypeName = ""
            switch member.memberType {
            case BTMember.MEMBER_TYPE_PREMIUM: memberTypeName = "BTLocMemberTypePremium".localizedBTBaseString
            case BTMember.MEMBER_TYPE_ADVANCED: memberTypeName = "BTLocMemberTypeAdvance".localizedBTBaseString
            default: break
            }
            
            if isGuest {
                let locStr = "BTLocGuest".localizedBTBaseString
                memberTypeLabel.text = "\(memberTypeName)(\(locStr))"
            } else {
                memberTypeLabel.text = memberTypeName
            }
            
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            if member.expiredDateTs > Date().timeIntervalSince1970 {
                formatter.dateFormat = "BTLocMemberExpiredDateFormat".localizedBTBaseString
            } else {
                formatter.dateFormat = "BTLocMemberExpiredDateOverFormat".localizedBTBaseString
            }
            expiresDateLabel.text = formatter.string(from: Date(timeIntervalSince1970: member.expiredDateTs))
            expiresDateLabel.textColor = member.expiredDateTs > Date().addDays(MemberExpiresAlertDays).timeIntervalSince1970 ? memberTintColor : memberAlertColor
            memberTypeLabel.textColor = memberTintColor
        } else {
            memberTypeLabel.text = isGuest ? "BTLocGuestMode".localizedBTBaseString : "BTLocMemberTypeNoSubscription".localizedBTBaseString
            expiresDateLabel.text = "BTLocMemberTypeNoSubscription".localizedBTBaseString
            expiresDateLabel.textColor = memberNormalColor
            memberTypeLabel.textColor = memberNormalColor
        }
    }
}

class MemberProductCell: UITableViewCell {
    static let reuseId = "MemberProductCell"
    var purchaseButtonObserve: Any?
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var purchaseButton: UIButton! {
        didSet {
            purchaseButton.SetupBTBaseUI()
        }
    }
    
    var product: BTMemberService.MemberProduct! {
        didSet {
            if product == nil {
                purchaseButton.isEnabled = false
            } else {
                titleLabel?.text = product.product.localizedTitle
                priceLabel?.text = product.enabled ? product.product.localizedPrice : "BTLocMemberProductNotOnSale".localizedBTBaseString
                purchaseButton.isEnabled = product.enabled
            }
        }
    }
    
    weak var rootController: MemberViewController!
    
    @IBAction func onClickPurchase(_: Any) {
        rootController?.purchase(p: product.product)
    }
    
    deinit {
        debugLog("Deinited:\(self.description)")
    }
}

class MemberViewController: UIViewController {
    static let noMemberProductCellReuseId = "NoMemberProductCell"
    @IBOutlet var signInButton: UIButton! {
        didSet {
            signInButton.SetupBTBaseUI()
        }
    }
    
    var memberTipsLabel: TXScrollLabelView!
    @IBOutlet var memberTipsView: UIView!
    
    @IBOutlet var orderListButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    var products: [BTMemberService.MemberProduct]! {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet var loadingProgressView: UIProgressView! {
        didSet {
            loadingProgressView.isHidden = true
        }
    }
    
    private var loadingTimer: Timer!
    private var loading: Bool {
        get {
            return !(loadingProgressView?.isHidden ?? true)
        }
        set {
            if let _ = loadingProgressView {
                if loadingProgressView.isHidden == newValue {
                    loadingProgressView.isHidden = !newValue
                    if newValue {
                        loadingProgressView.progress = 0
                        loadingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(loadingTimerTick(t:)), userInfo: nil, repeats: true)
                    } else {
                        loadingTimer?.invalidate()
                        loadingTimer = nil
                    }
                }
            }
        }
    }
    
    fileprivate(set) var isLogined = false
    fileprivate(set) var isGuest = false
    
    @objc private func loadingTimerTick(t _: Timer) {
        if let pv = loadingProgressView {
            pv.progress += 0.1
            if pv.progress >= 1 {
                pv.progress = 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupBTBaseUI()
        reloadProducts()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.backgroundColor = view.backgroundColor
        NotificationCenter.default.addObserver(self, selector: #selector(onRefreshProductsEvent(a:)), name: BTMemberService.onRefreshProductsEvent, object: nil)
    }
    
    func startScrollMessages(msgs: [String]) {
        memberTipsLabel?.endScrolling()
        memberTipsLabel?.removeFromSuperview()
        
        memberTipsLabel = TXScrollLabelView(textArray: msgs, type: .leftRight, velocity: MemberTipsScrollingDuration, options: .curveEaseIn, inset: UIEdgeInsets.zero)
        memberTipsLabel.scrollTitleColor = BTBaseUIConfig.GlobalTintColor
        memberTipsLabel.backgroundColor = UIColor.clear
        memberTipsView.addSubview(memberTipsLabel)
        
        memberTipsLabel.frame = memberTipsView.bounds
        
        memberTipsLabel.beginScrolling()
    }
    
    @objc private func onRefreshProductsEvent(a: Notification) {
        if let state = a.userInfo?[kBTRefreshMemberProductsStateKey] as? Int {
            DispatchQueue.main.async {
                self.loading = (state == BTRefreshMemberProductsStateStart)
            }
        }
    }
    
    var purchaseObserver: NSObjectProtocol!
    func purchase(p: SKProduct) {
        if isGuest {
            showConfirmGuestPurchaseMember(p: p)
        } else {
            purchaseMember(p: p)
        }
    }
    
    func showConfirmGuestPurchaseMember(p: SKProduct) {
        let title = "BTLocTitleGuestPurchaseLimit".localizedBTBaseString
        let msg = "BTLocMsgGuestPurchaseLimit".localizedBTBaseString
        
        let signIn = UIAlertAction(title: "BTLocSignIn".localizedBTBaseString, style: .default) { _ in
            self.onClickSignIn(self.signInButton)
        }
        
        let guestPurchase = UIAlertAction(title: "BTLocForceGuestPurchase".localizedBTBaseString, style: .default) { _ in
            self.purchaseMember(p: p)
        }
        
        showAlert(title, msg: msg, actions: [signIn, guestPurchase, ALERT_ACTION_CANCEL])
    }
    
    private func purchaseMember(p: SKProduct) {
        let hud = showActivityHud()
        purchaseObserver = NotificationCenter.default.addObserver(forName: BTMemberService.onPurchaseEvent, object: nil, queue: .main) { a in
            if let event = a.userInfo?[kBTMemberPurchaseEvent] as? Int {
                switch event {
                case BTMemberPurchaseEventValidateFailed, BTMemberPurchaseEventValidateSuccess, BTMemberPurchaseEventPurchaseFailed:
                    hud.hide(animated: true)
                    if let ob = self.purchaseObserver {
                        NotificationCenter.default.removeObserver(ob)
                        self.purchaseObserver = nil
                        if event == BTMemberPurchaseEventValidateSuccess {
                            let title = "BTLocTitleSubscribeMemberSuc".localizedBTBaseString
                            let msg = "BTLocMsgSubscribeMemberSuc".localizedBTBaseString
                            self.showAlert(title, msg: msg)
                        } else if event == BTMemberPurchaseEventPurchaseFailed {
                            let title = "BTLocTitleSubscribeMemberFail".localizedBTBaseString
                            let msg = "BTLocMsgPurchaseCancelOrFail".localizedBTBaseString
                            self.showAlert(title, msg: msg)
                        } else {
                            let title = "BTLocTitleSubscribeMemberFail".localizedBTBaseString
                            let msg = "BTLocMsgSubscribeMemberFail".localizedBTBaseString
                            self.showAlert(title, msg: msg)
                        }
                    }
                default: break
                }
            }
        }
        
        BTServiceContainer.getBTMemberService()?.purchaseMemberProduct(p: p) { _ in
        }
    }
    
    override func viewWillAppear(_: Bool) {
        tableView.reloadData()
        if products == nil || products.count == 0 {
            reloadProducts()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(onMemberProfileUpdated(a:)), name: BTMemberService.onLocalMemberProfileUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onMemberMessagesUpdated(a:)), name: BTMemberService.onMemberMessagesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onMemberProductsUpdated(a:)), name: BTMemberService.onMemberProductsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onClickTabbarItem(a:)), name: BTBaseHomeController.DidSelectViewController, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if memberTipsLabel == nil {
            let msg = "BTLocSubscribeMemberTips".localizedBTBaseString
            startScrollMessages(msgs: [msg])
        } else {
            memberTipsLabel?.beginScrolling()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: BTBaseHomeController.DidSelectViewController, object: nil)
        NotificationCenter.default.removeObserver(self, name: BTMemberService.onMemberProductsUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: BTMemberService.onMemberMessagesUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: BTMemberService.onLocalMemberProfileUpdated, object: nil)
        memberTipsLabel?.pauseScrolling()
    }
    
    @objc func onMemberMessagesUpdated(a _: Notification) {
        if let msgs = BTServiceContainer.getBTMemberService()?.messages {
            startScrollMessages(msgs: msgs)
        }
    }
    
    @objc func onMemberProfileUpdated(a _: Notification) {
        tableView.reloadData()
    }
    
    @objc private func onClickTabbarItem(a: Notification) {
        let lastClickTabbarDate = a.userInfo?[kLastClickTabBarItemDate] as! Date
        if let vc = a.userInfo?[kDidSelectViewController] as? UIViewController, vc == self.navigationController {
            if abs(lastClickTabbarDate.timeIntervalSinceNow) < 1 {
                fetchIAPList()
            }
        }
    }
    
    private func fetchIAPList() {
        if !loading {
            BTServiceContainer.getBTMemberService()?.fetchMemberConfig()
        }
    }
    
    @IBAction func onClickSignIn(_: Any) {
        BTBaseHomeEntry.getEntryViewController().performSegue(withIdentifier: "SignIn", sender: nil)
    }
    
    deinit {
        loadingTimer?.invalidate()
        loadingTimer = nil
        if let ob = self.purchaseObserver {
            NotificationCenter.default.removeObserver(ob)
        }
        NotificationCenter.default.removeObserver(self)
        debugLog("Deinited:\(self.description)")
    }
}

extension MemberViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        isLogined = BTServiceContainer.getBTSessionService()!.isSessionLogined
        if guestModeEnabled {
            isGuest = !isLogined
            signInButton.isHidden = true
            orderListButton.isEnabled = true
            return 3
        } else {
            isGuest = false
            if isLogined {
                signInButton.isHidden = true
                orderListButton.isEnabled = true
                return 3
            }
            signInButton.isHidden = false
            orderListButton.isEnabled = false
            return 0
        }
    }
    
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return products?.count ?? 0
        } else {
            return (products?.count ?? 0) > 0 ? 0 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MemberCardCell.reuseId, for: indexPath) as! MemberCardCell
            cell.rootViewController = self
            cell.refresh()
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MemberProductCell.reuseId, for: indexPath) as! MemberProductCell
            cell.product = products[indexPath.row]
            cell.rootController = self
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: MemberViewController.noMemberProductCellReuseId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let pd = products[indexPath.row]
            showAlert(pd.product.localizedTitle, msg: pd.product.localizedDescription)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func onMemberProductsUpdated(a _: Notification) {
        reloadProducts()
    }
    
    func reloadProducts() {
        if let pdset = BTServiceContainer.getBTMemberService()?.products {
            products = pdset.map { $0 }.sorted(by: { (a, b) -> Bool in
                a.product.price.doubleValue < b.product.price.doubleValue
            })
        } else {
            products = []
            fetchIAPList()
        }
    }
    
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return MemberCardRowHeight
        } else if indexPath.section == 1 {
            return MemberProductRowHeight
        } else {
            return NoMemberTipsRowHeight
        }
    }
    
    func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return MemberCardFooterHeight
        }
        return 0
    }
    
    func tableView(_: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            view.backgroundColor = UIColor.clear
            return view
        } else {
            return nil
        }
    }
}
