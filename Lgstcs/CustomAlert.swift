//
//  CustomAlert.swift
//  Lgstcs
//
//  Created by Michael Latson on 6/11/15.
//  Copyright (c) 2015 Lgstcs Co. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore 

enum AlertStyle {
    case Success,Error,Warning,None
    case CustomImag(imageFile:String)
}

class CustomAlert: UIViewController {
    
    let kBakcgroundTansperancy: CGFloat = 0.7
    let kHeightMargin: CGFloat = 10.0
    let KTopMargin: CGFloat = 20.0
    let kWidthMargin: CGFloat = 10.0
    let kAnimatedViewHeight: CGFloat = 70.0
    let kMaxHeight: CGFloat = 500.0
    var kContentWidth: CGFloat = 300.0
    let kButtonHeight: CGFloat = 35.0
    var textViewHeight: CGFloat = 90.0
    let kTitleHeight:CGFloat = 30.0
    var strongSelf:CustomAlert?
    var contentView = UIView()
    var titleLabel: UILabel = UILabel()
    var buttons: [UIButton] = []
    var animatedView: AnimatableView?
    var imageView:UIImageView?
    var subTitleTextView = UITextView()
    var userAction:((isOtherButton: Bool) -> Void)? = nil
    let kFont = "Helvetica"
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.view.frame = UIScreen.mainScreen().bounds
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        self.view.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:kBakcgroundTansperancy)
        self.view.addSubview(contentView)
        
        //Retaining itself strongly so can exist without strong refrence
        strongSelf = self
        
    }
    
    func setupContentView() {
        
        contentView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleTextView)
        contentView.backgroundColor = UIColorFromRGB(0xFFFFFF)
        contentView.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor
        view.addSubview(contentView)
    }
    
    func setupTitleLabel() {
        titleLabel.text = ""
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: kFont, size:25)
        titleLabel.textColor = UIColorFromRGB(0x575757)
    }
    
    func setupSubtitleTextView() {
        subTitleTextView.text = ""
        subTitleTextView.textAlignment = .Center
        subTitleTextView.font = UIFont(name: kFont, size:16)
        subTitleTextView.textColor = UIColorFromRGB(0x797979)
        subTitleTextView.editable = false
    }
    
    func resizeAndRelayout() {
        
        var mainScreenBounds = UIScreen.mainScreen().bounds
        self.view.frame.size = mainScreenBounds.size
        var x: CGFloat = kWidthMargin
        var y: CGFloat = KTopMargin
        var width: CGFloat = kContentWidth - (kWidthMargin*2)
        
        if animatedView != nil {
            animatedView!.frame = CGRect(x: (kContentWidth - kAnimatedViewHeight) / 2.0, y: y, width: kAnimatedViewHeight, height: kAnimatedViewHeight)
            contentView.addSubview(animatedView!)
            y += kAnimatedViewHeight + kHeightMargin
        }
        
        if imageView != nil {
            imageView!.frame = CGRect(x: (kContentWidth - kAnimatedViewHeight) / 2.0, y: y, width: kAnimatedViewHeight, height: kAnimatedViewHeight)
            contentView.addSubview(imageView!)
            y += imageView!.frame.size.height + kHeightMargin
        }
        
        
        // Title
        if self.titleLabel.text != nil {
            titleLabel.frame = CGRect(x: x, y: y, width: width, height: kTitleHeight)
            contentView.addSubview(titleLabel)
            y += kTitleHeight + kHeightMargin
        }
        
        // Subtitle
        if self.subTitleTextView.text.isEmpty == false {
            let subtitleString = subTitleTextView.text! as NSString
            let rect = subtitleString.boundingRectWithSize(CGSize(width: width, height:0.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:[NSFontAttributeName:subTitleTextView.font], context:nil)
            textViewHeight = ceil(rect.size.height) + 10.0
            subTitleTextView.frame = CGRect(x: x, y: y, width: width, height: textViewHeight)
            contentView.addSubview(subTitleTextView)
            y += textViewHeight + kHeightMargin
        }
        
        var buttonRect:[CGRect] = []
        for button in buttons {
            let string = button.titleForState(UIControlState.Normal)! as NSString
            buttonRect.append(string.boundingRectWithSize(CGSize(width: width, height:0.0), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:[NSFontAttributeName:button.titleLabel!.font], context:nil))
        }
        
        var totalWidth: CGFloat = 0.0
        if buttons.count == 2 {
            totalWidth = buttonRect[0].size.width + buttonRect[1].size.width + kWidthMargin + 40.0
        }
        else{
            totalWidth = buttonRect[0].size.width + 20.0
        }
        y += kHeightMargin
        var buttonX = (kContentWidth - totalWidth ) / 2.0
        for var i = 0; i <  buttons.count; i++ {
            
            buttons[i].frame = CGRect(x: buttonX, y: y, width: buttonRect[i].size.width + 20.0, height: buttonRect[i].size.height + 10.0)
            buttonX = buttons[i].frame.origin.x + kWidthMargin + buttonRect[i].size.width + 20.0
            buttons[i].layer.cornerRadius = 5.0
            self.contentView.addSubview(buttons[i])
            buttons[i].addTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchUpInside)
            
        }
        y += kHeightMargin + buttonRect[0].size.height + 10.0
        
        contentView.frame = CGRect(x: (mainScreenBounds.size.width - kContentWidth) / 2.0, y: (mainScreenBounds.size.height - y) / 2.0, width: kContentWidth, height: y)
        contentView.clipsToBounds = true
    }
    
    func pressed(sender: UIButton!) {
        self.closeAlert(sender.tag)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var sz = UIScreen.mainScreen().bounds.size
        let sver = UIDevice.currentDevice().systemVersion as NSString
        let ver = sver.floatValue
        if ver < 8.0 {
            // iOS versions before 7.0 did not switch the width and height on device roration
            if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
                let ssz = sz
                sz = CGSize(width:ssz.height, height:ssz.width)
            }
        }
        self.resizeAndRelayout()
    }
    
    
    func buttonTapped(btn:UIButton) {
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    func closeAlert(buttonIndex:Int){
        
        if userAction !=  nil {
            
            var isOtherButton = buttonIndex == 0 ? true: false
            CustomAlertContext.shouldNotAnimate = true
            userAction!(isOtherButton: isOtherButton)
            CustomAlertContext.shouldNotAnimate = false
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.view.alpha = 0.0
            }) { (Bool) -> Void in
                self.view.removeFromSuperview()
                self.cleanUpAlert()
                
                //Releasing strong refrence of itself.
                self.strongSelf = nil
        }
    }
    
    func cleanUpAlert() {
        
        if self.animatedView != nil {
            self.animatedView!.removeFromSuperview()
            self.animatedView = nil
        }
        self.contentView.removeFromSuperview()
        self.contentView = UIView()
    }
    
    func showAlert(title: String) -> CustomAlert {
        self.showAlert(title, subTitle: nil, style: .None)
        return self
    }
    
    func showAlert(title: String, subTitle: String?, style: AlertStyle) -> CustomAlert {
        self.showAlert(title, subTitle: subTitle, style: style, buttonTitle: "OK")
        return self
        
    }
    
    func showAlert(title: String, subTitle: String?, style: AlertStyle,buttonTitle: String, action: ((isOtherButton: Bool) -> Void)? = nil) -> CustomAlert {
        self.showAlert(title, subTitle: subTitle, style: style, buttonTitle: buttonTitle,buttonColor: UIColorFromRGB(0xAEDEF4))
        userAction = action
        return self
        
        
    }
    
    func showAlert(title: String, subTitle: String?, style: AlertStyle,buttonTitle: String,buttonColor: UIColor,action: ((isOtherButton: Bool) -> Void)? = nil) -> CustomAlert {
        self.showAlert(title, subTitle: subTitle, style: style, buttonTitle: buttonTitle,buttonColor: buttonColor,otherButtonTitle:
            nil)
        userAction = action
        return self
        
    }
    
    func showAlert(title: String, subTitle: String?, style: AlertStyle,buttonTitle: String,buttonColor: UIColor,otherButtonTitle:
        String?, action: ((isOtherButton: Bool) -> Void)? = nil) -> CustomAlert {
            self.showAlert(title, subTitle: subTitle, style: style, buttonTitle: buttonTitle,buttonColor: buttonColor,otherButtonTitle:
                otherButtonTitle,otherButtonColor: UIColor.redColor())
            userAction = action
            return self
            
    }
    
    func showAlert(title: String, subTitle: String?, style: AlertStyle,buttonTitle: String,buttonColor: UIColor,otherButtonTitle:
        String?, otherButtonColor: UIColor?,action: ((isOtherButton: Bool) -> Void)? = nil) {
            userAction = action
            let window = UIApplication.sharedApplication().keyWindow?.subviews.first as! UIView
            window.addSubview(view)
            view.frame = window.bounds
            self.setupContentView()
            self.setupTitleLabel()
            self.setupSubtitleTextView()
            
            
            switch style {
                
            case .Success:
                self.animatedView = SuccessAnimatedView()
                
            case .Error:
                self.animatedView = CancelAnimatedView()
                
            case .Warning:
                self.animatedView = InfoAnimatedView()
                
            case let .CustomImag(imageFile):
                if let image = UIImage(named: imageFile) {
                    self.imageView = UIImageView(image: image)
                }
            case .None:
                self.animatedView = nil
            }
            
            self.titleLabel.text = title
            
            if subTitle != nil {
                self.subTitleTextView.text = subTitle
            }
            
            buttons = []
            if buttonTitle.isEmpty == false {
                
                var button: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
                button.setTitle(buttonTitle, forState: UIControlState.Normal)
                button.backgroundColor = buttonColor
                button.userInteractionEnabled = true
                button.tag = 0
                buttons.append(button)
                
                
            }
            
            if otherButtonTitle != nil && otherButtonTitle!.isEmpty == false {
                
                var button: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
                button.setTitle(otherButtonTitle, forState: UIControlState.Normal)
                button.backgroundColor = otherButtonColor
                button.addTarget(self, action: "pressed:", forControlEvents: UIControlEvents.TouchUpInside)
                button.tag = 1
                buttons.append(button)
            }
            
            resizeAndRelayout()
            
            if CustomAlertContext.shouldNotAnimate == true {
                
                //Do not animate Alert
                if self.animatedView != nil {
                    self.animatedView!.animate()
                }
                
            }
            else {
                
                animateAlert()
            }
    }
    
    func animateAlert() {
        
        view.alpha = 0;
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.alpha = 1.0;
        })
        
        var previousTransform = self.contentView.transform
        self.contentView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 0.0);
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.contentView.layer.transform = CATransform3DMakeScale(1.1, 1.1, 0.0);
            
            }) { (Bool) -> Void in
                
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    
                    self.contentView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 0.0);
                    
                    }) { (Bool) -> Void in
                        
                        UIView.animateWithDuration(0.1, animations: { () -> Void in
                            
                            self.contentView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 0.0);
                            if self.animatedView != nil {
                                self.animatedView!.animate()
                            }
                            
                            }) { (Bool) -> Void in
                                
                                self.contentView.transform = previousTransform
                        }
                }
        }
    }
    
    private struct CustomAlertContext {
        static var shouldNotAnimate = false
    }
}

// MARK: -

// MARK: Animatable Views

class AnimatableView: UIView {
    
    func animate(){
        println("Should overide by subclasss")
    }
}

class CancelAnimatedView: AnimatableView {
    
    var circleLayer = CAShapeLayer()
    var crossPathLayer = CAShapeLayer()
    
    init() {
        super.init(frame: CGRect())
    }
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        var t = CATransform3DIdentity;
        t.m34 = 1.0 / -500.0;
        t = CATransform3DRotate(t, CGFloat(90.0 * M_PI / 180.0), 1, 0, 0);
        circleLayer.transform = t
        crossPathLayer.opacity = 0.0
        
    }
    
    override func layoutSubviews() {
        setupLayers()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var outlineCircle: CGPath  {
        var path = UIBezierPath()
        let startAngle: CGFloat = CGFloat((0) / 180.0 * M_PI)  //0
        let endAngle: CGFloat = CGFloat((360) / 180.0 * M_PI)   //360
        path.addArcWithCenter(CGPointMake(self.frame.size.width/2.0, self.frame.size.width/2.0), radius: self.frame.size.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        return path.CGPath
    }
    
    var crossPath: CGPath  {
        var path = UIBezierPath()
        var factor:CGFloat = self.frame.size.width / 5.0
        path.moveToPoint(CGPoint(x: self.frame.size.height/2.0-factor,y: self.frame.size.height/2.0-factor))
        path.addLineToPoint(CGPoint(x: self.frame.size.height/2.0+factor,y: self.frame.size.height/2.0+factor))
        path.moveToPoint(CGPoint(x: self.frame.size.height/2.0+factor,y: self.frame.size.height/2.0-factor))
        path.addLineToPoint(CGPoint(x: self.frame.size.height/2.0-factor,y: self.frame.size.height/2.0+factor))
        
        return path.CGPath
    }
    
    func setupLayers() {
        
        circleLayer.path = outlineCircle
        circleLayer.fillColor = UIColor.clearColor().CGColor;
        circleLayer.strokeColor = UIColorFromRGB(0xF27474).CGColor;
        circleLayer.lineCap = kCALineCapRound
        circleLayer.lineWidth = 4;
        circleLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        circleLayer.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
        self.layer.addSublayer(circleLayer)
        
        crossPathLayer.path = crossPath
        crossPathLayer.fillColor = UIColor.clearColor().CGColor;
        crossPathLayer.strokeColor = UIColorFromRGB(0xF27474).CGColor;
        crossPathLayer.lineCap = kCALineCapRound
        crossPathLayer.lineWidth = 4;
        crossPathLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        crossPathLayer.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
        self.layer.addSublayer(crossPathLayer)
        
    }
    
    override func animate() {
        
        var t = CATransform3DIdentity;
        t.m34 = 1.0 / -500.0;
        t = CATransform3DRotate(t, CGFloat(90.0 * M_PI / 180.0), 1, 0, 0);
        
        var t2 = CATransform3DIdentity;
        t2.m34 = 1.0 / -500.0;
        t2 = CATransform3DRotate(t2, CGFloat(-M_PI), 1, 0, 0);
        
        let animation = CABasicAnimation(keyPath: "transform")
        var time = 0.3
        animation.duration = time;
        animation.fromValue = NSValue(CATransform3D: t)
        animation.toValue = NSValue(CATransform3D:t2)
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        self.circleLayer.addAnimation(animation, forKey: "transform")
        
        
        var scale = CATransform3DIdentity;
        scale = CATransform3DScale(scale, 0.3, 0.3, 0)
        
        
        let crossAnimation = CABasicAnimation(keyPath: "transform")
        crossAnimation.duration = 0.3;
        crossAnimation.beginTime = CACurrentMediaTime() + time
        crossAnimation.fromValue = NSValue(CATransform3D: scale)
        crossAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.8, 0.7, 2.0)
        crossAnimation.toValue = NSValue(CATransform3D:CATransform3DIdentity)
        self.crossPathLayer.addAnimation(crossAnimation, forKey: "scale")
        
        var fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.duration = 0.3;
        fadeInAnimation.beginTime = CACurrentMediaTime() + time
        fadeInAnimation.fromValue = 0.3
        fadeInAnimation.toValue = 1.0
        fadeInAnimation.removedOnCompletion = false
        fadeInAnimation.fillMode = kCAFillModeForwards
        self.crossPathLayer.addAnimation(fadeInAnimation, forKey: "opacity")
    }
    
}

class InfoAnimatedView: AnimatableView {
    
    var circleLayer = CAShapeLayer()
    var crossPathLayer = CAShapeLayer()
    
    init() {
        super.init(frame: CGRect())
    }
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    override func layoutSubviews() {
        setupLayers()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var outlineCircle: CGPath  {
        var path = UIBezierPath()
        let startAngle: CGFloat = CGFloat((0) / 180.0 * M_PI)  //0
        let endAngle: CGFloat = CGFloat((360) / 180.0 * M_PI)   //360
        path.addArcWithCenter(CGPointMake(self.frame.size.width/2.0, self.frame.size.width/2.0), radius: self.frame.size.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        var factor:CGFloat = self.frame.size.width / 1.5
        path.moveToPoint(CGPoint(x: self.frame.size.width/2.0 , y: 15.0))
        path.addLineToPoint(CGPoint(x: self.frame.size.width/2.0,y: factor))
        path.moveToPoint(CGPoint(x: self.frame.size.width/2.0,y: factor + 10.0))
        path.addArcWithCenter(CGPoint(x: self.frame.size.width/2.0,y: factor + 10.0), radius: 1.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        return path.CGPath
    }
    
    func setupLayers() {
        
        circleLayer.path = outlineCircle
        circleLayer.fillColor = UIColor.clearColor().CGColor;
        circleLayer.strokeColor = UIColorFromRGB(0xF8D486).CGColor;
        circleLayer.lineCap = kCALineCapRound
        circleLayer.lineWidth = 4;
        circleLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        circleLayer.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
        self.layer.addSublayer(circleLayer)
    }
    
    override func animate() {
        
        var colorAnimation = CABasicAnimation(keyPath:"strokeColor")
        colorAnimation.duration = 1.0;
        colorAnimation.repeatCount = HUGE
        colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        colorAnimation.autoreverses = true
        colorAnimation.fromValue = UIColorFromRGB(0xF7D58B).CGColor
        colorAnimation.toValue = UIColorFromRGB(0xF2A665).CGColor
        circleLayer.addAnimation(colorAnimation, forKey: "strokeColor")
    }
}


class SuccessAnimatedView: AnimatableView {
    
    var circleLayer = CAShapeLayer()
    var outlineLayer = CAShapeLayer()
    
    init() {
        super.init(frame: CGRect())
        self.setupLayers()
        circleLayer.strokeStart = 0.0
        circleLayer.strokeEnd = 0.0
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        circleLayer.strokeStart = 0.0
        circleLayer.strokeEnd = 0.0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        setupLayers()
    }
    
    
    var outlineCircle: CGPath {
        var path = UIBezierPath()
        let startAngle: CGFloat = CGFloat((0) / 180.0 * M_PI)  //0
        let endAngle: CGFloat = CGFloat((360) / 180.0 * M_PI)   //360
        path.addArcWithCenter(CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0), radius: self.frame.size.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        return path.CGPath
    }
    
    var path: CGPath {
        var path = UIBezierPath()
        var startAngle:CGFloat = CGFloat((60) / 180.0 * M_PI) //60
        var endAngle:CGFloat = CGFloat((200) / 180.0 * M_PI)  //190
        path.addArcWithCenter(CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0), radius: self.frame.size.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addLineToPoint(CGPoint(x: 36.0 - 10.0 ,y: 60.0 - 10.0))
        path.addLineToPoint(CGPoint(x: 85.0 - 20.0, y: 30.0 - 20.0))
        
        return path.CGPath
        
    }
    
    
    func setupLayers() {
        
        outlineLayer.position = CGPointMake(0,
            0);
        outlineLayer.path = outlineCircle
        outlineLayer.fillColor = UIColor.clearColor().CGColor;
        outlineLayer.strokeColor = UIColor(red: 150.0/255.0, green: 216.0/255.0, blue: 115.0/255.0, alpha: 1.0).CGColor;
        outlineLayer.lineCap = kCALineCapRound
        outlineLayer.lineWidth = 4;
        outlineLayer.opacity = 0.1
        self.layer.addSublayer(outlineLayer)
        
        circleLayer.position = CGPointMake(0,
            0);
        circleLayer.path = path
        circleLayer.fillColor = UIColor.clearColor().CGColor;
        circleLayer.strokeColor = UIColor(red: 150.0/255.0, green: 216.0/255.0, blue: 115.0/255.0, alpha: 1.0).CGColor;
        circleLayer.lineCap = kCALineCapRound
        circleLayer.lineWidth = 4;
        circleLayer.actions = [
            "strokeStart": NSNull(),
            "strokeEnd": NSNull(),
            "transform": NSNull()
        ]
        
        self.layer.addSublayer(circleLayer)
    }
    
    override func animate() {
        let strokeStart = CABasicAnimation(keyPath: "strokeStart")
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        var factor = 0.045
        strokeEnd.fromValue = 0.00
        strokeEnd.toValue = 0.93
        strokeEnd.duration = 10.0*factor
        var timing = CAMediaTimingFunction(controlPoints: 0.3, 0.6, 0.8, 1.2)
        strokeEnd.timingFunction = timing
        
        strokeStart.fromValue = 0.0
        strokeStart.toValue = 0.68
        strokeStart.duration =  7.0*factor
        strokeStart.beginTime =  CACurrentMediaTime() + 3.0*factor
        strokeStart.fillMode = kCAFillModeBackwards
        strokeStart.timingFunction = timing
        circleLayer.strokeStart = 0.68
        circleLayer.strokeEnd = 0.93
        self.circleLayer.addAnimation(strokeEnd, forKey: "strokeEnd")
        self.circleLayer.addAnimation(strokeStart, forKey: "strokeStart")
    }
    
}

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}



