//
//  BTVideoPlayerViewController.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/7/5.
//  Copyright © 2018年 btbase. All rights reserved.
//

import AVKit
import Foundation

class BTVideoPlayerViewController: AVPlayerViewController {
    var loopVideo = false
    var closeVideoOnEnd = false
    
    var didDisappearAction:(()->Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEndTime), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func didPlayToEndTime(a: Notification) {
        if self.loopVideo {
            self.player?.seek(to: CMTimeMake(0, 1))
            self.player?.play()
        } else if self.closeVideoOnEnd {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        didDisappearAction?()
    }
}
