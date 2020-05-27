//
//  ActivityView.swift
//  BlackRockApp
//
//  Created by Salvatore Capuozzo on 27/05/2020.
//  Copyright © 2020 Salvatore Capuozzo. All rights reserved.
//

import Foundation
import UIKit

class ActivityView: UIView {
    struct Static {
        static var activityView = ActivityView()
    }
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        self.initAll()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initAll() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        self.frame = window.frame
        self.center = window.center
        self.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        let loadingView: UIView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = window.center
        loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.style = UIActivityIndicatorView.Style.large
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        self.addSubview(loadingView)
        actInd.startAnimating()
    }
    
    static func show() {
        Static.activityView.initAll()
        remove()
        UIApplication.shared.keyWindow?.addSubview(Static.activityView)
    }
    
    static func remove() {
        Static.activityView.removeFromSuperview()
    }
    
    static func remove(withDelay delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            remove()
        }
    }
}
