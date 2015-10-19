//
//  TimerViewController.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/9.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController,UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate {

    var increaseTime : Int = 0
    var decreaseTime : Int = 0
    var decreaseTimeDefault : Int = 5 * 60 * 100
    var increaseTimer : NSTimer!
    var decreaseTimer : NSTimer!
    
    @IBOutlet weak var increaseView: AnimatableTimerView!
    @IBOutlet weak var decreaseView: AnimatableTimerView!
    
    @IBOutlet weak var increaseTimeLabel: UILabel!
    @IBOutlet weak var decreaseTimeLabel: UILabel!
    
    @IBOutlet weak var decreaseTimePicker: UIPickerView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var containerScrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        decreaseTime = decreaseTimeDefault
        increaseTimeLabel.text = self.timeToString(increaseTime)
        decreaseTimeLabel.text = self.timeToString(decreaseTime)
        containerScrollView.delegate = self
        decreaseTimePicker.hidden = true
        increaseView.animateType = TimeAnimateType.IncreaseType
        decreaseView.animateType = TimeAnimateType.DecreaseType
        
        let decreaseTimeLabelTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "decreaseLabelTaped")
        decreaseTimeLabel.addGestureRecognizer(decreaseTimeLabelTapGesture)
        
        let decreaseViewTapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "decreaseViewTaped")
        decreaseView.addGestureRecognizer(decreaseViewTapGesture)
        
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
    
    func timeToString(aTime : Int) -> String {
        if aTime >= 360000 {
            return String(format:"%.2d:%.2d:%.2d.%.2d",aTime/360000 , (aTime/6000)%60 , (aTime/100)%60 , aTime%100)
        }else{
            return String(format:"%.2d:%.2d.%.2d",aTime/6000 , (aTime/100)%60 , aTime%100)
        }
    }
   
    func increaseTimerTrigger() {
        increaseTime += 10
        increaseTimeLabel.text = self.timeToString(increaseTime)
        increaseView.animateProgress += 1 / 600
        increaseView.setNeedsDisplay()
    }
    func decreaseTimerTrigger() {
        decreaseTime -= 10
        if decreaseTime < 0 {
            decreaseTimer.invalidate()
            decreaseTimer = nil
            decreaseTime = decreaseTimeDefault
            decreaseTimeLabel.text = self.timeToString(decreaseTime)
        }else{
            decreaseTimeLabel.text = self.timeToString(decreaseTime)
            decreaseView.animateProgress += 10.0 / CGFloat(decreaseTimeDefault)
            decreaseView.setNeedsDisplay()
        }
    }
    @IBAction func increaseTimerButtonClicked(sender: UIButton) {
        if increaseTimer == nil {
            if decreaseTimer == nil {
                increaseTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "increaseTimerTrigger", userInfo: nil, repeats: true)
            }
        }else{
            increaseTimer.invalidate()
            increaseTimer = nil
        }
    }
    @IBAction func decreaseTimerButtonClicked(sender: UIButton) {
        if decreaseTimer == nil {
            if increaseTimer == nil {
                decreaseTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "decreaseTimerTrigger", userInfo: nil, repeats: true)
            }
        }else{
            decreaseTimer.invalidate()
            decreaseTimer = nil
        }
    }
    
    //Decrease Time Picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 3
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        switch component {
        case 0:
            return 5
        case 1,2:
            return 60
        default:
            return 0
        }
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        switch component {
        case 0:
            return String(format: "%d小时",row)
        case 1:
            return String(format: "%d分钟",row)
        case 2:
            return String(format: "%d秒",row)
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
            decreaseTimeLabel.text = self.timeToString(decreaseTime)
            decreaseView.animateProgress = 0
            decreaseView.setNeedsDisplay()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
