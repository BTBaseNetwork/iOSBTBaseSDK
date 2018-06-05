//
//  Browser.swift
//  Bahamut
//
//  Created by AlexChow on 15/10/30.
//  Copyright © 2015年 GStudio. All rights reserved.
//

import Foundation
import UIKit

class SimpleBrowser: UIViewController, UIWebViewDelegate {
    var webView: UIWebView! {
        didSet {
            webView.delegate = self
            if url != nil {
                loadUrl()
            }
        }
    }

    var useCustomTitle = true

    var url: String! {
        didSet {
            if url != nil && webView != nil {
                loadUrl()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView = UIWebView(frame: view.bounds)
        view.addSubview(webView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(SimpleBrowser.back(_:)))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(SimpleBrowser.action(_:)))

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SimpleBrowser.swipeLeft(_:)))
        leftSwipe.direction = .left

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SimpleBrowser.swipeRight(_:)))
        rightSwipe.direction = .right

        webView.addGestureRecognizer(leftSwipe)
        webView.addGestureRecognizer(rightSwipe)
    }

    @objc func swipeLeft(_: UISwipeGestureRecognizer) {
        webView.goForward()
    }

    @objc func swipeRight(_: UISwipeGestureRecognizer) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }

    @objc func back(_: AnyObject) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func action(_: AnyObject) {
        var items = [Any]()
        if let u = url, let ul = URL(string: u) {
            items.append(ul)
        }
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        ac.excludedActivityTypes = [.airDrop, .addToReadingList, .print, .assignToContact]
        if #available(iOS 9.0, *) {
            ac.excludedActivityTypes?.append(.openInIBooks)
        }
        present(ac, animated: true)
    }

    fileprivate func loadUrl() {
        webView.loadRequest(URLRequest(url: URL(string: url)!))
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        if useCustomTitle {
            if let title = webView.stringByEvaluatingJavaScript(from: "document.title") {
                self.title = title
            }
        }
    }

    // "SimpleBrowser"
    @discardableResult
    static func openUrl(_ currentViewController: UIViewController, url: String, title: String?, callback: ((_: SimpleBrowser) -> Void)? = nil) -> SimpleBrowser {
        let controller = SimpleBrowser()
        let navController = UINavigationController(rootViewController: controller)

        controller.useCustomTitle = String.isNullOrWhiteSpace(title)

        DispatchQueue.main.async { () -> Void in
            if let cnvc = currentViewController as? UINavigationController {
                navController.navigationBar.barStyle = cnvc.navigationBar.barStyle
            }
            controller.title = title
            currentViewController.present(navController, animated: true, completion: {
                controller.url = url
                if let cb = callback {
                    cb(controller)
                }
            })
        }
        return controller
    }
}
