//
//  PushBannerView.swift
//  PushBannerViewComponent
//
//  Created by Perennial on 18/04/17.
//  Copyright © 2017 Priti. All rights reserved.
//

import UIKit

let APP:UIWindow = UIApplication.shared.delegate!.window!!
let CLOSE_PUSH_SEC: TimeInterval    = 5
let SHOW_ANIM_DUR                   = 0.5
let HIDE_ANIM_DUR                   = 0.35
let BANNER_VIEW_HEIGHT : CGFloat    = 72
let CORNER_RADIUS : CGFloat         = 2.0
let FONT : UIFont = UIFont.systemFont(ofSize: 14)
var PUSH_VIEW : PushBannerView? = PushBannerView.sharedInstance()

class PushBannerView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel : UILabel!
    @IBOutlet weak var imageView    : UIImageView!
    
    var onClickBlock : (() -> Void)?
    var closeTimer: Timer?
    var currentMessage : String?
    var messageTap : UITapGestureRecognizer?
    
    //Singleton instance
    
    static var sharedPushBannerView :  PushBannerView!
    
    //MARK:- Initialize shared instance
    
    class func sharedInstance() -> PushBannerView? {
        
        if (sharedPushBannerView == nil) {
            
            sharedPushBannerView = UINib(nibName: "PushBannerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? PushBannerView
            sharedPushBannerView?.setUpUI()
        }
        return sharedPushBannerView
    }
    
    //MARK:- Lifecycle (of sort)
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        let f = self.frame
        let width = UIApplication.shared.keyWindow?.bounds.width
        self.frame = CGRect(x: f.minX, y: f.minY, width: width!, height: f.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    func setUpUI() {
        
        let frame  = self.frame
        let width  = UIApplication.shared.keyWindow?.bounds.width
        
        let height = frame.height
        self.frame = CGRect(x: frame.minX, y: -height, width: width!, height: height)
        
        let cVframe = self.containerView.frame
        self.containerView.frame = CGRect(x: cVframe.minX, y: cVframe.minY, width: self.frame.width, height: height)
        
        self.layer.zPosition  = CGFloat(MAXFLOAT)
        self.isExclusiveTouch = true
        
        APP.addSubview(PUSH_VIEW!)
        self.imageView.layer.cornerRadius   = CORNER_RADIUS
        self.imageView.layer.masksToBounds  = true
    }
    
    func showNotificationWithMessage(message: String, clickClosure: (() -> Void)?) {
        
        PUSH_VIEW?.showAutoHideNotificationWithMessage(message)
        PUSH_VIEW?.onClickBlock = clickClosure
    }
    
    func showAutoHideNotificationWithMessage(_ message: String) {
        
        self.showNotificationWithMessage(message)
        
        if((PUSH_VIEW?.closeTimer) != nil) {
            
            PUSH_VIEW?.closeTimer?.invalidate()
            PUSH_VIEW?.closeTimer = nil
        }
        
        PUSH_VIEW?.closeTimer = Timer.scheduledTimer(timeInterval: CLOSE_PUSH_SEC, target: self, selector: #selector(PushBannerView.close), userInfo: nil, repeats: false)
    }
    
    func showNotificationWithMessage(_ message: String) {
        
        PUSH_VIEW?.changeUI()
        PUSH_VIEW?.currentMessage = message
        PUSH_VIEW?.removeTapGesture()
        PUSH_VIEW?.perform(#selector(addTapGesture), with: nil, afterDelay: 1.0)
        
        let messageString = NSString(string: message)
        let tempSize = CGSize(width: 215, height: CGFloat(FLT_MAX))
        
        let newMessageSize = messageString.boundingRect(with: tempSize, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin], attributes: [NSFontAttributeName: FONT], context: nil).size
        
        var frame = PUSH_VIEW!.frame
        PUSH_VIEW?.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: max(newMessageSize.height, BANNER_VIEW_HEIGHT))
        
        PUSH_VIEW?.messageLabel.text = message
        APP.windowLevel = UIWindowLevelNormal
        
        frame = PUSH_VIEW!.frame
        PUSH_VIEW?.frame = CGRect(x: frame.minX, y: -frame.height, width: frame.width, height: frame.height)
        APP.addSubview(PUSH_VIEW!)
        
        //Show
        UIView.animate(withDuration: SHOW_ANIM_DUR, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            frame = PUSH_VIEW!.frame
            PUSH_VIEW!.frame = CGRect(x: frame.minX, y: 0.0, width: frame.width, height: frame.height)
            }, completion: { (completed) in
                
        })
        
    }
    
    func closeWithCompletion(completion: (() -> Void)?) {
        
        PUSH_VIEW?.closeTimer?.invalidate()
        PUSH_VIEW?.closeTimer = nil
        
        UIView.animate(withDuration: HIDE_ANIM_DUR, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            let frame = PUSH_VIEW!.frame
            PUSH_VIEW!.frame = CGRect(x: frame.minX, y: -frame.height, width: frame.width, height: frame.height)
        }) { (completed) in
            
            if(completion != nil) {
                completion!()
            }
        }
        
    }
    
    func close() {
        
        PUSH_VIEW?.removeTapGesture()
        PUSH_VIEW?.closeWithCompletion(completion: nil)
        PUSH_VIEW?.onClickBlock = nil
    }
    
    //MARK:- Actions
    
    func messageTapAction() {
        
        if(PUSH_VIEW?.onClickBlock != nil) {
            
            PUSH_VIEW?.onClickBlock!()
        }
        self.close()
    }
    
    func removeTapGesture() {
        
        if(self.messageTap != nil) {
            
            self.containerView.removeGestureRecognizer(self.messageTap!)
            self.messageTap = nil
        }
    }
    
    func addTapGesture() {
        
        self.messageTap = UITapGestureRecognizer(target: self, action: #selector(messageTapAction))
        self.containerView.addGestureRecognizer(self.messageTap!)
    }
    
    func changeUI() {
        
//        messageLabel.setAlignment()
//        if(DataManager.selectedAppLanguage() == .arabic) {
//            
//            self.reloadRTLView(PushBannerView.sharedPushBannerView!)
//        }
    }
}
