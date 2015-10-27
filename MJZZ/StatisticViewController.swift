//
//  StatisticViewController.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/9.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit

class StatisticViewController: UIViewController , UITableViewDataSource ,UITableViewDelegate {

    @IBOutlet weak var axisY5: UILabel!
    @IBOutlet weak var axisY4: UILabel!
    @IBOutlet weak var axisY3: UILabel!
    @IBOutlet weak var axisY2: UILabel!
    @IBOutlet weak var axisY1: UILabel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var graphScrollView: UIScrollView!
    
    @IBOutlet weak var axisYView: StatisticAxisYView!
    let graphView : MJZZGraphView = MJZZGraphView()

    @IBOutlet weak var graphScopeSegment: UISegmentedControl!
    
    let selectedDateIndex : MJZZDateIndex = MJZZDateIndex.currentIndex()
    var selectedGraphScope : GraphScope = GraphScope.year
    var currentGraphDataArray : [MJZZDataProtocol]!
    var axisYMinDuration : Int = 0
    var axisYMaxDuration : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setSegmentedControlStyle(graphScopeSegment , fontSize : 16)
        
        graphView.backgroundColor = UIColor.whiteColor()
        graphScrollView.addSubview(graphView)
        graphScrollView.contentOffset = CGPoint(x: 0, y: 0)
        let graphViewTapGesture = UITapGestureRecognizer(target: self, action: "graphViewTaped:")
        graphView.addGestureRecognizer(graphViewTapGesture)
        if !NSUserDefaults.standardUserDefaults().boolForKey("hasStatisticData") {
            for i in 2001 ... MJZZTime().year{
                let aYear : Int = i
                for j in 1 ... MJZZTime().month {
                    let aMonth : Int = j
                    for k in 1 ... MJZZTime().day {
                        let aDay : Int = k
                        let aData : MJZZData = MJZZData(withTime: MJZZTime(year: aYear, month: aMonth, day: aDay, hour: 0, minute: 0))
                        aData.duration = random() % 360000
                        MJZZStatisticData.appendOnceData(aData)
                    }
                }
            }
        }
        refreshAll()
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshAll()
    }
    
    
    @IBAction func graphScopeChanged(sender: UISegmentedControl) {
        switch graphScopeSegment.selectedSegmentIndex {
        case 0 :
            selectedGraphScope = .year
        case 1 :
            selectedGraphScope = .month
        case 2 :
            selectedGraphScope = .day
        default :
            break
        }
        graphScrollView.contentOffset = CGPoint(x: 0, y: 0)
        refreshAll()
    }
    
    func graphViewTaped(sender : UITapGestureRecognizer) {
        let index : Int = Int(sender.locationInView(graphView).x) / 40
        if index < currentGraphDataArray.count {
            let aDuration : Int = currentGraphDataArray[index].duration
            let aY : CGFloat = (1.0 - CGFloat( aDuration - axisYMinDuration ) / CGFloat( axisYMaxDuration - axisYMinDuration )) * graphView.frame.height * 0.85
            if abs(aY - sender.locationInView(graphView).y) < 20 {
                switch selectedGraphScope {
                case .year :
                    selectedDateIndex.yearIndex = index
                case .month :
                    selectedDateIndex.monthIndex = index
                case .day :
                    selectedDateIndex.dayIndex = index
                }
                self.refreshAll()
            }
        }
    }
    
    func refreshAll() {
        let statisticData : MJZZStatisticData = MJZZStatisticData.sharedData()
        if statisticData.data.count == 0 {
            return
        }
        switch selectedGraphScope {
        case .year :
            currentGraphDataArray = statisticData.data
        case .month :
            let selectedYearData = statisticData.data[selectedDateIndex.yearIndex] as! MJZZYearData
            
            currentGraphDataArray = selectedYearData.data
        case .day :
            let selectedYearData = statisticData.data[selectedDateIndex.yearIndex] as! MJZZYearData
            let selectedMonthData = selectedYearData.data[selectedDateIndex.monthIndex] as! MJZZMonthData

            currentGraphDataArray = selectedMonthData.data
        }
        var longestGraphDataDuration : Int = 0
        var shortestGraphDataDuration = Int(INT64_MAX)
        for aData in currentGraphDataArray {
            if aData.duration > longestGraphDataDuration {
                longestGraphDataDuration = aData.duration
            }
            if aData.duration < shortestGraphDataDuration {
                shortestGraphDataDuration = aData.duration
            }
        }
        axisYMinDuration = Int(Double(shortestGraphDataDuration) * 0.9)
        axisYMaxDuration = Int(Double(longestGraphDataDuration) * 1.1)
        self.refreshGraphView()
        self.refreshGraphAxisYView()
        tableView.reloadData()
    }
    
    func refreshGraphView() {
        graphView.currentGraphDataArray = currentGraphDataArray
        graphView.axisYMinDuration = axisYMinDuration
        graphView.axisYMaxDuration = axisYMaxDuration
        graphView.selectedGraphScope = selectedGraphScope
        graphView.frame.size.height = axisYView.frame.height
        var aWidth : CGFloat = CGFloat(currentGraphDataArray.count * 40 + 80)
        if aWidth < self.view.frame.width {
            aWidth = self.view.frame.width
        }
        graphView.frame.size.width = aWidth
        graphView.frame.origin = CGPoint(x: 0, y: 0)
        graphScrollView.contentSize = graphView.frame.size
        graphView.setNeedsDisplay()
    }
    func refreshGraphAxisYView() {
        axisYView.axisYMinDuration = axisYMinDuration
        axisYView.axisYMaxDuration = axisYMaxDuration
        axisYView.setNeedsDisplay()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var selectedDateIndexOfCurrentScope : Int
        switch selectedGraphScope {
        case .year :
            selectedDateIndexOfCurrentScope = selectedDateIndex.yearIndex
        case .month :
            selectedDateIndexOfCurrentScope = selectedDateIndex.monthIndex
        case .day :
            selectedDateIndexOfCurrentScope = selectedDateIndex.dayIndex
        }
        return currentGraphDataArray[selectedDateIndexOfCurrentScope].data.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var aString : String
        var aTime : MJZZTime
        switch selectedGraphScope{
        case .year :
            aTime = currentGraphDataArray[selectedDateIndex.yearIndex].time
            aString = String(format:"%d年每月累计时长",aTime.year)
        case .month :
            aTime = currentGraphDataArray[selectedDateIndex.monthIndex].time
            aString = String(format:"%d年%d月每天累计时长",aTime.year,aTime.month)
        case .day :
            aTime = currentGraphDataArray[selectedDateIndex.dayIndex].time
            aString = String(format:"%d年%d月%d天每次时长",aTime.year,aTime.month,aTime.day)
        }
        return aString
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let aCell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("StatisticTableViewCell") as UITableViewCell!
        let startTimeLabel : UILabel = aCell.viewWithTag(2) as! UILabel
        let durationLabel : UILabel = aCell.viewWithTag(3) as! UILabel
        
        var aData : MJZZDataProtocol
        
        switch selectedGraphScope{
        case .year :
            aData = currentGraphDataArray[selectedDateIndex.yearIndex].data[indexPath.row]
            durationLabel.text = compactStringFromTime(aData.duration)
            startTimeLabel.text = String(format:"%d月",aData.time.month)
        case .month :
            aData = currentGraphDataArray[selectedDateIndex.monthIndex].data[indexPath.row]
            durationLabel.text = compactStringFromTime(aData.duration)
            startTimeLabel.text = String(format:"%d日",aData.time.day)
        case .day :
            aData = currentGraphDataArray[selectedDateIndex.dayIndex].data[indexPath.row]
            durationLabel.text = compactStringFromTime(aData.duration)
            startTimeLabel.text = String(format:"%.2d:%.2d",aData.time.hour,aData.time.minute)
        }
        return aCell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        if selectedGraphScope == GraphScope.day {
            return true
        }else {
            return false
        }
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

func compactStringFromTime(aTime : Int) -> String {
    switch aTime {
    case 0 ..< 6000 :
        return String(format:"%.2d秒%.2d",aTime/100 , aTime%100)
    case 6000 ..< 360000 :
        return String(format:"%.2d分%.2d秒",aTime/6000 , (aTime/100)%60)
    case 360000 ..< 8640000 :
        return String(format:"%.2d时%.2d分",aTime/360000 , (aTime/6000)%60)
    case 8640000 ..< Int(INT64_MAX) :
        return String(format:"%.2d天%.2d时",aTime/8640000 , (aTime/360000)%24)
    default :
        return String()
    }
}
