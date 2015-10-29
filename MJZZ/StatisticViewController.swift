//
//  StatisticViewController.swift
//  MJZZ
//
//  Created by MJsaka on 15/10/9.
//  Copyright © 2015年 MJsaka. All rights reserved.
//

import UIKit
class MJZZDataIndex : NSObject{
    var yearIndex : Int
    var monthIndex : Int
    var dayIndex : Int
    var index : Int
    
    override init(){
        yearIndex = 0
        monthIndex = 0
        dayIndex = 0
        index = 0
    }
}
@objc enum MJZZDataScope : Int{
    case year
    case month
    case day
}
class StatisticViewController: UIViewController , UITableViewDataSource ,UITableViewDelegate {
    
    @IBOutlet weak var leftBarButtonItems: UIBarButtonItem!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var graphScrollView: UIScrollView!
    @IBOutlet weak var graphScopeSegment: UISegmentedControl!
    @IBOutlet weak var axisYView: StatisticAxisYView!
    let graphView : MJZZGraphView = MJZZGraphView()
    @IBOutlet weak var tableView: UITableView!
    
    let selectedDataIndex : MJZZDataIndex = MJZZDataIndex()
    var selectedDataScope : MJZZDataScope = MJZZDataScope.year
    var currentDataArray : [MJZZDataProtocol] = MJZZStatisticData.sharedData().data
    var minDuration : Int = 0
    var maxDuration : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        leftBarButtonItems.title = ""
        setSegmentedControlStyle(graphScopeSegment , fontSize : 16)
        
        graphView.backgroundColor = UIColor.whiteColor()
        graphScrollView.addSubview(graphView)
        let graphViewTapGesture = UITapGestureRecognizer(target: self, action: "graphViewTaped:")
        graphView.addGestureRecognizer(graphViewTapGesture)
        graphView.setNeedsDisplay()
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
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshAll()
    }
    
    override func viewWillDisappear(animated: Bool) {
        tableView.setEditing(false, animated: true)
        rightBarButtonItem.title = "编辑"
        leftBarButtonItems.title = ""
    }
    
    @IBAction func graphScopeSegmentChanged(sender: UISegmentedControl) {
        switch graphScopeSegment.selectedSegmentIndex {
        case 0 :
            selectedDataScope = .year
        case 1 :
            selectedDataScope = .month
        case 2 :
            selectedDataScope = .day
        default :
            break
        }
        refreshAll()
    }
    
    func graphViewTaped(sender : UITapGestureRecognizer) {
        let index : Int = Int(sender.locationInView(graphView).x) / 40
        if index < currentDataArray.count {
            let aDuration : Int = currentDataArray[index].duration
            let aY : CGFloat = (1.0 - CGFloat( aDuration - minDuration ) / CGFloat( maxDuration - minDuration )) * graphView.frame.height * 0.85
            if abs(aY - sender.locationInView(graphView).y) < 20 || sender.locationInView(graphView).y > graphView.frame.height * 0.85 {
                switch selectedDataScope {
                case .year :
                    selectedDataIndex.yearIndex = index
                    selectedDataIndex.monthIndex = 0
                    selectedDataIndex.dayIndex = 0
                case .month :
                    selectedDataIndex.monthIndex = index
                    selectedDataIndex.dayIndex = 0
                case .day :
                    selectedDataIndex.dayIndex = index
                }
                self.refreshAll()
            }
        }
    }
    
    func updataSelectedDataIndexAndScope() {
        let statisticData : MJZZStatisticData = MJZZStatisticData.sharedData()
        if statisticData.data.isEmpty{
            return
        }
        if selectedDataIndex.yearIndex >= statisticData.data.count {
            selectedDataIndex.yearIndex = statisticData.data.count - 1
            selectedDataScope = MJZZDataScope.year
            graphScopeSegment.selectedSegmentIndex = 0
            return
        }
        let selectedYearData = statisticData.data[selectedDataIndex.yearIndex]
        if selectedDataIndex.monthIndex >= selectedYearData.data.count {
            selectedDataIndex.monthIndex = selectedYearData.data.count - 1
            selectedDataScope = MJZZDataScope.month
            graphScopeSegment.selectedSegmentIndex = 1
            return
        }
        let selectedMonthData = selectedYearData.data[selectedDataIndex.monthIndex]
        if selectedDataIndex.dayIndex >= selectedMonthData.data.count {
            selectedDataIndex.dayIndex = selectedMonthData.data.count - 1
            selectedDataScope = MJZZDataScope.day
            graphScopeSegment.selectedSegmentIndex = 2
        }
    }
    
    func refreshAll() {
        let statisticData : MJZZStatisticData = MJZZStatisticData.sharedData()
        if statisticData.data.isEmpty{
            return
        }
        switch selectedDataScope {
        case .year :
            currentDataArray = statisticData.data
        case .month :
            let selectedYearData = statisticData.data[selectedDataIndex.yearIndex]
            currentDataArray = selectedYearData.data
        case .day :
            let selectedYearData = statisticData.data[selectedDataIndex.yearIndex]
            let selectedMonthData = selectedYearData.data[selectedDataIndex.monthIndex]
            currentDataArray = selectedMonthData.data
        }
        var longestGraphDataDuration : Int = 0
        var shortestGraphDataDuration = Int(INT64_MAX)
        for aData in currentDataArray {
            if aData.duration > longestGraphDataDuration {
                longestGraphDataDuration = aData.duration
            }
            if aData.duration < shortestGraphDataDuration {
                shortestGraphDataDuration = aData.duration
            }
        }
        minDuration = Int(Double(shortestGraphDataDuration) * 0.9)
        maxDuration = Int(Double(longestGraphDataDuration) * 1.1)
        self.refreshGraphView()
        self.refreshGraphAxisYView()
        tableView.reloadData()
    }
    
    func refreshGraphView() {
        graphView.currentDataArray = currentDataArray
        graphView.minDuration = minDuration
        graphView.maxDuration = maxDuration
        graphView.selectedDataScope = selectedDataScope
        graphView.selectedDataIndex = selectedDataIndex
        graphView.frame.size.height = axisYView.frame.height
        var aWidth : CGFloat = CGFloat(currentDataArray.count * 40 + 80)
        if aWidth < self.view.frame.width {
            aWidth = self.view.frame.width
        }
        graphView.frame.size.width = aWidth
        graphView.frame.origin = CGPoint(x: 0, y: 0)
        graphScrollView.contentSize = graphView.frame.size
        var index : Int
        switch selectedDataScope {
        case .year :
            index = selectedDataIndex.yearIndex
        case .month :
            index = selectedDataIndex.monthIndex
        case .day :
            index = selectedDataIndex.dayIndex
        }
        var scrollX : CGFloat = CGFloat(40 * index) - 0.3 * graphScrollView.frame.width
        let minScrollX : CGFloat = 0
        let maxScrollX : CGFloat = graphView.frame.width - graphScrollView.frame.width
        if scrollX > maxScrollX {
            scrollX = maxScrollX
        }else if scrollX < minScrollX {
            scrollX = minScrollX
        }
        graphScrollView.setContentOffset(CGPoint(x: scrollX, y: 0), animated: true)
        graphView.setNeedsDisplay()

    }
    func refreshGraphAxisYView() {
        axisYView.minDuration = minDuration
        axisYView.maxDuration = maxDuration
        axisYView.setNeedsDisplay()
    }
    
    
    @IBAction func editClicked(sender: UIBarButtonItem) {
        if tableView.editing {
            tableView.setEditing(false, animated: true)
            rightBarButtonItem.title = "编辑"
            leftBarButtonItems.title = ""
        } else {
            tableView.setEditing(true, animated: true)
            rightBarButtonItem.title = "完成"
        }
    }
    
    
    @IBAction func deleteClicked(sender: UIBarButtonItem) {
        if let indexPaths : [NSIndexPath] = tableView.indexPathsForSelectedRows {
            var indexes : [Int] = [Int]()
            for indexPath in indexPaths {
                indexes.append(indexPath.row)
            }
            indexes = indexes.sort()
            let alertController : UIAlertController = UIAlertController(title: "", message: "确定删除？", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction : UIAlertAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
            let confirmAction : UIAlertAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                MJZZStatisticData.deleteDataAtIndexes(indexes, withSelectedDataIndex: self.selectedDataIndex, withSelectedDataScope: self.selectedDataScope)
                self.leftBarButtonItems.title = ""
                self.updataSelectedDataIndexAndScope()
                self.refreshAll()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var aNum : Int = 0
        if !currentDataArray.isEmpty {
            var selectedDataIndexOfCurrentScope : Int = 0

            switch selectedDataScope {
            case .year :
                selectedDataIndexOfCurrentScope = selectedDataIndex.yearIndex
            case .month :
                selectedDataIndexOfCurrentScope = selectedDataIndex.monthIndex
            case .day :
                selectedDataIndexOfCurrentScope = selectedDataIndex.dayIndex
            }
            aNum = currentDataArray[selectedDataIndexOfCurrentScope].data.count
        }
        return aNum
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var aString : String
        if !currentDataArray.isEmpty {
            var aData : MJZZDataProtocol
            switch selectedDataScope{
            case .year :
                aData = currentDataArray[selectedDataIndex.yearIndex]
                aString = String(format:"%d年累计:",aData.time.year)
                aString += compactStringFromTime(aData.duration)
            case .month :
                aData = currentDataArray[selectedDataIndex.monthIndex]
                aString = String(format:"%d年%d月累计:",aData.time.year,aData.time.month)
                aString += compactStringFromTime(aData.duration)
            case .day :
                aData = currentDataArray[selectedDataIndex.dayIndex]
                aString = String(format:"%d年%d月%d日累计:",aData.time.year,aData.time.month,aData.time.day)
                aString += compactStringFromTime(aData.duration)
            }
        } else {
            aString = "您还没有任何锻炼数据"
        }
        return aString
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let aCell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("StatisticTableViewCell") as UITableViewCell!
        let startTimeLabel : UILabel = aCell.viewWithTag(2) as! UILabel
        let durationLabel : UILabel = aCell.viewWithTag(3) as! UILabel
        
        var aData : MJZZDataProtocol
        switch selectedDataScope{
        case .year :
            aData = currentDataArray[selectedDataIndex.yearIndex].data[indexPath.row]
            durationLabel.text = compactStringFromTime(aData.duration)
            startTimeLabel.text = String(format:"%d月",aData.time.month)
        case .month :
            aData = currentDataArray[selectedDataIndex.monthIndex].data[indexPath.row]
            durationLabel.text = compactStringFromTime(aData.duration)
            startTimeLabel.text = String(format:"%d日",aData.time.day)
        case .day :
            aData = currentDataArray[selectedDataIndex.dayIndex].data[indexPath.row]
            durationLabel.text = compactStringFromTime(aData.duration)
            startTimeLabel.text = String(format:"%.2d:%.2d",aData.time.hour,aData.time.minute)
        }
        return aCell
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let alertController : UIAlertController = UIAlertController(title: "", message: "确定删除？", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction : UIAlertAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
            let confirmAction : UIAlertAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                MJZZStatisticData.deleteDataAtIndexes([indexPath.row], withSelectedDataIndex: self.selectedDataIndex, withSelectedDataScope: self.selectedDataScope)
                self.updataSelectedDataIndexAndScope()
                self.refreshAll()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle{
        return UITableViewCellEditingStyle.Delete
    }
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String?{
        return "删除"
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if !tableView.editing {
            switch selectedDataScope{
            case .year :
                selectedDataScope = MJZZDataScope.month
                selectedDataIndex.monthIndex = indexPath.row
                graphScopeSegment.selectedSegmentIndex = 1
            case .month :
                selectedDataScope = MJZZDataScope.day
                selectedDataIndex.dayIndex = indexPath.row
                graphScopeSegment.selectedSegmentIndex = 2
            case .day :
                break
            }
            self.refreshAll()
        } else {
            if (tableView.indexPathsForSelectedRows != nil) {
                leftBarButtonItems.title = "删除"
            }
        }
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView.indexPathsForSelectedRows == nil) {
            leftBarButtonItems.title = ""
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
