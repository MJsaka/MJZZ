//
//  TimerViewController.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/9.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {

    var increaseTime : Int = 0
    var decreaseTime : Int = 5 * 60 * 100
    var increaseTimer : NSTimer!
    var decreaseTimer : NSTimer!
    
    @IBOutlet weak var increaseView: UIView!
    @IBOutlet weak var decreaseView: UIView!
    @IBOutlet weak var increaseTimeLabel: UILabel!
    @IBOutlet weak var decreaseTimeLabel: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var containerScrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        increaseTimeLabel.text = self.timeToString(increaseTime)
        decreaseTimeLabel.text = self.timeToString(decreaseTime)
    }
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        let offSetX : Int = sender.selectedSegmentIndex * Int(containerScrollView.frame.width)
        containerScrollView.setContentOffset(CGPoint(x: offSetX, y: 0), animated: true)
    }
    
    func timeToString(aTime : Int) -> String {
        return String.init(format:"%.2d:%.2d.%.2d",aTime/6000 , (aTime/100)%60 , aTime%100)
    }
    
    func increaseTimerStart() {
        increaseTime += 9
        increaseTimeLabel.text = self.timeToString(increaseTime)
    }
    func decreaseTimerStart() {
        decreaseTime -= 9
        decreaseTimeLabel.text = self.timeToString(decreaseTime)
    }
    @IBAction func increaseTimerButtonClicked(sender: UIButton) {
        if(increaseTimer == nil){
            increaseTimer = NSTimer.scheduledTimerWithTimeInterval(0.09, target: self, selector: "increaseTimerStart", userInfo: nil, repeats: true)
        }else{
            increaseTimer.invalidate()
            increaseTimer = nil
        }
    }
    @IBAction func decreaseTimerButtonClicked(sender: UIButton) {
        if(decreaseTimer == nil){
            decreaseTimer = NSTimer.scheduledTimerWithTimeInterval(0.09, target: self, selector: "decreaseTimerStart", userInfo: nil, repeats: true)
        }else{
            decreaseTimer.invalidate()
            decreaseTimer = nil
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
