//
//  TimerViewController.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/9.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

enum MJZZButtonAnimationType : Int {
    case start
    case stop
}
enum MJZZTimerType : Int {
    case increase
    case decrease
}


class TimerViewController: UIViewController,UIScrollViewDelegate ,UIPickerViewDataSource,UIPickerViewDelegate {

    var currentOnceData : MJZZData?
    var currentTimerType : MJZZTimerType = MJZZTimerType.increase
    var time : Int = 0
    var topTime : Int = 5 * 60 * 100
    var timer : NSTimer!
    var backgroundTimerTask : UIBackgroundTaskIdentifier!

    
    @IBOutlet weak var increaseView: AnimatableTimerView!
    @IBOutlet weak var decreaseView: AnimatableTimerView!
    
    @IBOutlet weak var increaseTimeLabel: UILabel!
    @IBOutlet weak var topTimeLabel: UILabel!
    @IBOutlet weak var topTimeTitle: UILabel!
    @IBOutlet weak var decreaseTimeLabel: UILabel!
    
    @IBOutlet weak var decreaseTimePicker: UIPickerView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var decreaseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bestDurationChanged", name: "MJZZNotificationBestDurationChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillResignActiveHandler", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillEnterForegroundHandler", name: UIApplicationWillEnterForegroundNotification, object: nil)

        setSegmentedControlStyle(segment ,fontSize : 20)
        topTime = MJZZStatisticData.sharedData().bestOnceDuration
        increaseTimeLabel.text = stringFromTime(0)
        decreaseTimeLabel.text = stringFromTime(topTime)
        containerScrollView.delegate = self
        decreaseTimePicker.hidden = true
        increaseView.animateType = TimeAnimateType.IncreaseType
        decreaseView.animateType = TimeAnimateType.DecreaseType
        
        topTimeLabel.hidden = true
        topTimeTitle.hidden = true
        
        let decreaseTimeLabelTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "decreaseLabelTaped")
        decreaseTimeLabel.addGestureRecognizer(decreaseTimeLabelTapGesture)
        
        let decreaseViewTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "decreaseViewTaped")
        decreaseView.addGestureRecognizer(decreaseViewTapGesture)
        
        self.view.bringSubviewToFront(segment)
        
    }
    
    func appWillResignActiveHandler() {
        if timer != nil {
            self.backgroundTimerTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
        }
    }
    func appWillEnterForegroundHandler() {
        if timer != nil {
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTimerTask)
        }
    }
    
    func bestDurationChanged() {
        topTime = MJZZStatisticData.sharedData().bestOnceDuration
        decreaseTimeLabel.text = stringFromTime(topTime)
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0 :
            containerScrollView.scrollRectToVisible(increaseView.frame, animated: true)
        case 1 :
            containerScrollView.scrollRectToVisible(decreaseView.frame, animated: true)
        default :
            break
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        if(containerScrollView.contentOffset.x < containerScrollView.frame.width){
            segment.selectedSegmentIndex = 0
        }else{
            segment.selectedSegmentIndex = 1
        }
    }

   
    func timerTrigger() {
        time += 10
        switch currentTimerType {
        case MJZZTimerType.increase :
            increaseTimeLabel.text = stringFromTime(time)
            increaseView.animateProgress += 1/600
            increaseView.setNeedsDisplay()
        case MJZZTimerType.decrease :
            let dTime = topTime - time
            if dTime < 0 {
                timer.invalidate()
                timer = nil
                currentOnceData?.duration = time
                MJZZStatisticData.appendOnceData(currentOnceData!)
                decreaseTimeLabel.text = stringFromTime(topTime)
                time = 0
                decreaseView.animateProgress = 0
                if UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
                    UIApplication.sharedApplication().endBackgroundTask(self.backgroundTimerTask)
                }
                self.buttonAnimation(self.decreaseButton, status: MJZZButtonAnimationType.stop)
            }else{
                decreaseTimeLabel.text = stringFromTime(topTime - time)
                decreaseView.animateProgress += 10.0/Double(topTime)
            }
            decreaseView.setNeedsDisplay()
        }
    }
    
    func buttonAnimation(button : UIButton , status : MJZZButtonAnimationType){
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            button.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 1, 0)
            }) { (finished) -> Void in
                switch status {
                case MJZZButtonAnimationType.start :
                    button.setImage(UIImage(named: "Icon_Button_Clicked"), forState: UIControlState.Normal)
                case MJZZButtonAnimationType.stop :
                    button.setImage(UIImage(named: "Icon_Button_Normal"), forState: UIControlState.Normal)
                }
                UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    button.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0, 1, 0)
                    }) {  (finished) -> Void in
                        
                }
        }
    }
    
    @IBAction func increaseTimerButtonClicked(sender: UIButton) {
        if timer == nil {
            currentOnceData = MJZZData()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timerTrigger", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            let bestOnceDuration = MJZZStatisticData.sharedData().bestOnceDuration
            if bestOnceDuration > 0 {
                topTimeLabel.text = stringFromTime(bestOnceDuration)
                topTimeTitle.hidden = false
                topTimeLabel.hidden = false
            }
            self.buttonAnimation(self.increaseButton, status: MJZZButtonAnimationType.start)
            currentTimerType = MJZZTimerType.increase
        }else if currentTimerType == MJZZTimerType.increase {
            timer.invalidate()
            timer = nil
            currentOnceData?.duration = time
            MJZZStatisticData.appendOnceData(currentOnceData!)
            increaseTimeLabel.text = stringFromTime(0)
            topTimeLabel.hidden = true
            topTimeTitle.hidden = true
            time = 0
            increaseView.animateProgress = 0
            increaseView.setNeedsDisplay()
            self.buttonAnimation(self.increaseButton, status: MJZZButtonAnimationType.stop)
        } else {
            let alertController : UIAlertController = UIAlertController(title: "", message: "挑战模式已经开启，请先结束再来", preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction : UIAlertAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func decreaseTimerButtonClicked(sender: UIButton) {
        if timer == nil {
            currentOnceData = MJZZData()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timerTrigger", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            self.buttonAnimation(self.decreaseButton, status: MJZZButtonAnimationType.start)
            currentTimerType = MJZZTimerType.decrease
        }else if currentTimerType == MJZZTimerType.decrease{
            timer.invalidate()
            timer = nil
            currentOnceData?.duration = time
            MJZZStatisticData.appendOnceData(currentOnceData!)
            time = 0
            decreaseView.animateProgress = 0
            decreaseView.setNeedsDisplay()
            decreaseTimeLabel.text = stringFromTime(topTime)
            self.buttonAnimation(self.decreaseButton, status: MJZZButtonAnimationType.stop)
        }else{
            let alertController : UIAlertController = UIAlertController(title: "", message: "计时模式已经开启，请先结束再来", preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction : UIAlertAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //Decrease Time Picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 3
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        switch component {
        case 0:
            return 3
        case 1,2:
            return 60
        default:
            return 0
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        switch component {
        case 0:
            return String(format: "\(row)小时")
        case 1:
            return String(format: "\(row)分钟")
        case 2:
            return String(format: "\(row)秒")
        default:
            return String()
        }
    }
    
    func decreaseLabelTaped(){
        if decreaseTimePicker.hidden == true {
            if timer == nil || currentTimerType != MJZZTimerType.decrease{
                decreaseTimePicker.hidden = false
                decreaseTimePicker.selectRow(topTime/360000, inComponent: 0, animated: false)
                decreaseTimePicker.selectRow((topTime/6000)%60, inComponent: 1, animated: false)
                decreaseTimePicker.selectRow((topTime/100)%60, inComponent: 2, animated: false)
            }
        }
    }
    func decreaseViewTaped(){
        if decreaseTimePicker.hidden == false {
            decreaseTimePicker.hidden = true
            topTime = decreaseTimePicker.selectedRowInComponent(0) * 360000 + decreaseTimePicker.selectedRowInComponent(1) * 6000 + decreaseTimePicker.selectedRowInComponent(2) * 100
            decreaseTimeLabel.text = stringFromTime(topTime)
            decreaseView.animateProgress = 0
            decreaseView.setNeedsDisplay()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setSegmentedControlStyle(segment : UISegmentedControl, fontSize aSize : CGFloat){
        segment.setBackgroundImage(UIImage(named: "Segment_Normal")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        segment.setBackgroundImage(UIImage(named: "Segment_Selected")!.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 0)), forState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
        segment.setDividerImage(UIImage(named: "Segment_Separate")?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)), forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
        segment.setDividerImage(UIImage(named: "Segment_Separate")?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)), forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        segment.setDividerImage(UIImage(named: "Segment_Separate")?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)), forLeftSegmentState: UIControlState.Selected, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        segment.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "Heiti SC", size: aSize)! ,
            NSForegroundColorAttributeName : UIColor.darkGrayColor() ],
            forState: UIControlState.Normal)
        segment.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "Heiti SC", size: aSize)! ,
            NSForegroundColorAttributeName : UIColor.redColor() ],
            forState: UIControlState.Selected)
    }

}

func stringFromTime(aTime : Int) -> String {
    if aTime >= 360000 {
        return String(format:"%.2d:%.2d:%.2d.%.2d",aTime/360000 , (aTime/6000)%60 , (aTime/100)%60 , aTime%100)
    }else{
        return String(format:"%.2d:%.2d.%.2d",aTime/6000 , (aTime/100)%60 , aTime%100)
    }
}


