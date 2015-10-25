//
//  TimerViewController.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/9.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

enum buttonAnimationType : Int {
    case start
    case stop
}


class TimerViewController: UIViewController,UIScrollViewDelegate ,UIPickerViewDataSource,UIPickerViewDelegate {

    var currentOnceData : MJZZData?
    var increaseTime : Int = 0
    var decreaseTime : Int = 0
    var decreaseTimeDefault : Int = 5 * 60 * 100
    var increaseTimer : NSTimer!
    var decreaseTimer : NSTimer!
    
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
        
        setSegmentedControlStyle(segment ,fontSize : 20)
        decreaseTime = decreaseTimeDefault
        increaseTimeLabel.text = stringFromTime(increaseTime)
        decreaseTimeLabel.text = stringFromTime(decreaseTime)
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

   
    func increaseTimerTrigger() {
        increaseTime += 10
        increaseTimeLabel.text = stringFromTime(increaseTime)
        increaseView.animateProgress += 1/600
        increaseView.setNeedsDisplay()
    }
    func decreaseTimerTrigger() {
        decreaseTime -= 10
        if decreaseTime < 0 {
            decreaseTimer.invalidate()
            decreaseTimer = nil
            currentOnceData?.duration = decreaseTimeDefault - decreaseTime
            MJZZStatisticData.appendOnceData(currentOnceData!)
            decreaseTime = decreaseTimeDefault
            decreaseTimeLabel.text = stringFromTime(decreaseTime)
            self.buttonAnimation(self.decreaseButton, status: buttonAnimationType.stop)
        }else{
            decreaseTimeLabel.text = stringFromTime(decreaseTime)
            decreaseView.animateProgress += 10.0/Double(decreaseTimeDefault)
            decreaseView.setNeedsDisplay()
        }
    }
    
    func buttonAnimation(button : UIButton , status : buttonAnimationType){
        UIView.animateKeyframesWithDuration(0.5, delay: 0, options:UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.25, animations: { () -> Void in
                button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
            })
            UIView.addKeyframeWithRelativeStartTime(0.25, relativeDuration: 0.25, animations: { () -> Void in
                button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.25, animations: { () -> Void in
                button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2 * 3))
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.75, relativeDuration: 0.25, animations: { () -> Void in
                button.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 2))
                button.alpha = 0.5
            })
            }, completion:{ (finished) -> Void in
                switch status {
                case buttonAnimationType.start :
                    button.setImage(UIImage(named: "Icon_Button_Clicked"), forState: UIControlState.Normal)
                case buttonAnimationType.stop :
                    button.setImage(UIImage(named: "Icon_Button_Normal"), forState: UIControlState.Normal)
                }
                button.alpha = 1.0
        })
    }
    
    @IBAction func increaseTimerButtonClicked(sender: UIButton) {
        if increaseTimer == nil {
            if decreaseTimer == nil {
                currentOnceData = MJZZData()
                increaseTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "increaseTimerTrigger", userInfo: nil, repeats: true)
                let topTime = MJZZStatisticData.sharedData().bestOnceDuration
                if topTime > 0 {
                    topTimeLabel.text = stringFromTime(topTime)
                    topTimeTitle.hidden = false
                    topTimeLabel.hidden = false
                }
                self.buttonAnimation(self.increaseButton, status: buttonAnimationType.start)
            }
        }else{
            topTimeLabel.hidden = true
            topTimeTitle.hidden = true
            increaseTimer.invalidate()
            increaseTimer = nil
            currentOnceData?.duration = increaseTime
            MJZZStatisticData.appendOnceData(currentOnceData!)
            let topTime = MJZZStatisticData.sharedData().bestOnceDuration
            if topTime > decreaseTimeDefault {
                decreaseTimeDefault = topTime
                decreaseTime = decreaseTimeDefault
                decreaseTimeLabel.text = stringFromTime(decreaseTimeDefault)
            }
            increaseTime = 0
            increaseTimeLabel.text = stringFromTime(increaseTime)
            increaseView.animateProgress = 0
            increaseView.setNeedsDisplay()
            self.buttonAnimation(self.increaseButton, status: buttonAnimationType.stop)
        }
    }
    @IBAction func decreaseTimerButtonClicked(sender: UIButton) {
        if decreaseTimer == nil {
            if increaseTimer == nil {
                currentOnceData = MJZZData()
                decreaseTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "decreaseTimerTrigger", userInfo: nil, repeats: true)
                self.buttonAnimation(self.decreaseButton, status: buttonAnimationType.start)
            }
        }else{
            decreaseTimer.invalidate()
            decreaseTimer = nil
            decreaseView.animateProgress = 0
            decreaseView.setNeedsDisplay()
            currentOnceData?.duration = decreaseTimeDefault - decreaseTime
            MJZZStatisticData.appendOnceData(currentOnceData!)
            decreaseTime = decreaseTimeDefault
            decreaseTimeLabel.text = stringFromTime(decreaseTime)
            self.buttonAnimation(self.decreaseButton, status: buttonAnimationType.stop)
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
        if decreaseTimePicker.hidden == true && decreaseTimer == nil{
            decreaseTimePicker.hidden = false
            decreaseTimePicker.selectRow(decreaseTimeDefault/360000, inComponent: 0, animated: false)
            decreaseTimePicker.selectRow((decreaseTimeDefault/6000)%60, inComponent: 1, animated: false)
            decreaseTimePicker.selectRow((decreaseTimeDefault/100)%60, inComponent: 2, animated: false)
        }
    }
    func decreaseViewTaped(){
        if decreaseTimePicker.hidden == false {
            decreaseTimePicker.hidden = true
            decreaseTimeDefault = decreaseTimePicker.selectedRowInComponent(0) * 360000 + decreaseTimePicker.selectedRowInComponent(1) * 6000 + decreaseTimePicker.selectedRowInComponent(2) * 100
            decreaseTime = decreaseTimeDefault
            decreaseTimeLabel.text = stringFromTime(decreaseTime)
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


