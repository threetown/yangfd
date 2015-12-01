//
//  CUTESurroundingListViewController.swift
//  currant
//
//  Created by Foster Yin on 10/15/15.
//  Copyright © 2015 BBTechgroup. All rights reserved.
//

import UIKit


@objc(CUTESurroundingListViewController)
class CUTESurroundingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  UISearchBarDelegate, UISearchDisplayDelegate, CUTESurroundingSearchDelegate {

    private var form:CUTESurroundingForm
    var postcodeIndex:String?

    weak var tableView:UITableView!
    private var hintLabel:UILabel?


    init(form:CUTESurroundingForm) {
        self.form = form
        super.init(nibName:nil, bundle:nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        self.tableView = self.view as! UITableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(hex6: 0xeeeeee)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.allowsSelection = false

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hex6: 0xeeeeee)
        self.tableView.backgroundView = backgroundView

//        self.definesPresentationContext = true

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.title = STR("SurroundingList/周边")
        self.showBarButtonItems()

        //if default search don't add surrounding, user can add them
        self.showHintLabel(self.form.ticket.property.surroundings.count == 0)
    }

    private func showHintLabel(show:Bool) {
        if (show) {
            if self.hintLabel == nil {
                let label = UILabel()
                label.textColor = UIColor(hex6: 0x999999)
                label.textAlignment = NSTextAlignment.Center
                label.numberOfLines = 0
                label.font = UIFont.systemFontOfSize(16)
                label.text = STR("SurroundingList/点击右上角“+”，添加周边的学校和地铁")
                self.tableView.backgroundView?.addSubview(label)
                label.frame = CGRectMake(0, (self.view.frame.size.height - 40) / 2, label.superview!.bounds.size.width, 40)
                self.hintLabel = label
            }
        }

        self.hintLabel?.hidden = !show
    }

    func checkShowSurroundingAddTooltip() {

        let userDefaultKey = CUTE_USER_DEFAULT_TIP_SURROUNDING_ADD_DISPLAYED
        if !NSUserDefaults.standardUserDefaults().boolForKey(userDefaultKey)
        {

            let toolTips = CUTETooltipView(targetPoint: CGPointMake(self.view.frame.size.width - 25, 54), hostView: self.navigationController?.view, tooltipText: STR("SurroundingList/点此搜索添加学校或地铁"), arrowDirection: JDFTooltipViewArrowDirection.Up, width: 200)
            toolTips.show()

            do {
                //https://github.com/steipete/Aspects/issues/51
                let closure:((Void)->Void) = {  toolTips.hideAnimated(true) }
                let block: @convention(block) Void -> Void = closure
                let objectBlock = unsafeBitCast(block, AnyObject.self)

                try self.aspect_hookSelector("viewWillDisappear:", withOptions: AspectOptions(rawValue: AspectOptions.PositionBefore.rawValue | AspectOptions.OptionAutomaticRemoval.rawValue), usingBlock: objectBlock)
                try self.view.aspect_hookSelector("hitTest:withEvent:", withOptions: AspectOptions(rawValue: AspectOptions.PositionBefore.rawValue | AspectOptions.OptionAutomaticRemoval.rawValue), usingBlock: objectBlock)
            }
            catch let error as NSError {
                print(error)
            }

            toolTips.show()

            NSUserDefaults.standardUserDefaults().setBool(true, forKey: userDefaultKey)
        }

    }

    func showBarButtonItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, block: { (sender) -> Void in

            let searchController = CUTESurroundingSearchViewController(form: self.form, postcodeIndex: self.postcodeIndex!)
            searchController.delegate = self
            let nav = UINavigationController(rootViewController: searchController)
            nav.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            self.navigationController?.presentViewController(nav, animated: true, completion: nil)
        })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.checkShowSurroundingAddTooltip()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (form.ticket.property.surroundings as! [CUTESurrounding]).count
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {


        let cell = tableView.dequeueReusableCellWithIdentifier("surroundingReuseIdentifier")

        var surroundingCell:CUTESurroundingCell

        if cell is CUTESurroundingCell {
            surroundingCell = cell as! CUTESurroundingCell
        }
        else {
            surroundingCell = CUTESurroundingCell(style: UITableViewCellStyle.Default, reuseIdentifier: "surroundingReuseIdentifier")
            surroundingCell.typeButton.addTarget(self, action: "onTypeButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            surroundingCell.durationButton.addTarget(self, action: "onDurationButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            surroundingCell.removeButton.addTarget(self, action: "onRemoveButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            surroundingCell.removeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10)
        }
        let surroundings = form.ticket.property.surroundings as! [CUTESurrounding]
        let surrounding = surroundings[indexPath.row]
        surroundingCell.nameLabel.text = surrounding.name
        surroundingCell.typeImageView.setImageWithURL(NSURL(string: surrounding.type.image)!)
        surroundingCell.typeButton.tag = indexPath.row
        surroundingCell.durationButton.tag = indexPath.row
        surroundingCell.removeButton.tag = indexPath.row


        var trafficTime = surrounding.trafficTimes?.filter({ (time:CUTETrafficTime) -> Bool in
            return time.isDefault
        }).first

        if trafficTime == nil {
            trafficTime = surrounding.trafficTimes?[0]
        }

        if (trafficTime != nil) {
            if trafficTime!.time != nil {
                surroundingCell.typeButton.setTitle(trafficTime!.type!.value, forState: UIControlState.Normal)
                surroundingCell.durationButton.setTitle("\(trafficTime!.time!.value) " + (trafficTime!.time!.unitForDisplay)!, forState: UIControlState.Normal)
            }
            surroundingCell.setNeedsLayout()
        }
        return surroundingCell

    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80;
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    func searchAddSurrounding(surrounding: CUTESurrounding) {
        SVProgressHUD.show()
        self.form.syncTicketWithBlock({ (ticket:CUTETicket!) -> Void in
            var array = Array(ticket.property.surroundings as! [CUTESurrounding])
            array.insert(surrounding, atIndex: 0)
            ticket.property.surroundings = array

        }).continueWithBlock({ (task:BFTask!) -> AnyObject! in
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
            return task
        })
    }

    func onTypeButtonPressed(sender:UIButton) {
        var surroundings = Array(form.ticket.property.surroundings as! [CUTESurrounding])
        let surr = surroundings[sender.tag]
        if (surr.trafficTimes != nil) {

            let modes = surr.trafficTimes!.map({ (time:CUTETrafficTime) -> String in
                return time.type!.value + " \(time.time!.value) " + time.time!.unitForDisplay
            })

            var defaultTimeIndex = 0

            for (index, time) in surr.trafficTimes!.enumerate() {
                if time.isDefault {
                    defaultTimeIndex = index
                    break
                }
            }

            ActionSheetStringPicker.showPickerWithTitle("", rows: modes, initialSelection: defaultTimeIndex, doneBlock: { (picker:ActionSheetStringPicker!, selectedIndex:Int, selectedValue:AnyObject!) -> Void in

                for time in surr.trafficTimes! {
                    time.isDefault = false
                }
                let time = surr.trafficTimes![selectedIndex]
                time.isDefault = true
                self.tableView.reloadData()
                }, cancelBlock: { (picker:ActionSheetStringPicker!) -> Void in
                    
                }, origin: sender)
        }
    }

    func onDurationButtonPressed(sender:UIButton) {
        var surroundings = Array(form.ticket.property.surroundings as! [CUTESurrounding])
        let surr = surroundings[sender.tag]
        if (surr.trafficTimes != nil) {
            var defaultTimeIndex = 0

            for (index, time) in surr.trafficTimes!.enumerate() {
                if time.isDefault {
                    defaultTimeIndex = index
                    break
                }
            }

            let defaultTime = surr.trafficTimes![defaultTimeIndex]
            let timeValue = defaultTime.time!.value
            let aroundValues = getAroundTime(timeValue).map({ (intValue:Int32) -> String in
                return "\(intValue)"
            })
            let timetValueIndex = aroundValues.indexOf("\(timeValue)")

            ActionSheetStringPicker.showPickerWithTitle("", rows: aroundValues, initialSelection:timetValueIndex!, doneBlock: { (picker:ActionSheetStringPicker!, selectedIndex:Int, selectedValue:AnyObject!) -> Void in
                if let value = Int32(selectedValue as! String) {

                    SVProgressHUD.show()
                    self.form.syncTicketWithBlock({ (ticket:CUTETicket!) -> Void in
                        let surr = (ticket.property.surroundings[sender.tag] as! CUTESurrounding)
                        var array = Array(surr.trafficTimes)

                        let oldTrafficTime = array[defaultTimeIndex]
                        let time = CUTETimePeriod(value: value, unit: "minute")
                        let newTrafficTime = CUTETrafficTime()
                        newTrafficTime.type = oldTrafficTime.type
                        newTrafficTime.isDefault = oldTrafficTime.isDefault
                        newTrafficTime.time = time
                        array[defaultTimeIndex] = newTrafficTime

                        //update traffic time just by assign a new array, because the listener listen the trafficTims attribute
                        surr.trafficTimes = array

                    }).continueWithBlock({ (task:BFTask!) -> AnyObject! in
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                        return task
                    })
                }
                }, cancelBlock: { (picker:ActionSheetStringPicker!) -> Void in
                    
                }, origin: sender)
        }

    }

    func onRemoveButtonPressed(sender:UIButton) {
        let index = sender.tag
        SVProgressHUD.show()
        self.form.syncTicketWithBlock({ (ticket:CUTETicket!) -> Void in
            var array = Array(ticket.property.surroundings as! [CUTESurrounding])
            array.removeAtIndex(index)
            ticket.property.surroundings = array
        }).continueWithBlock { (task:BFTask!) -> AnyObject! in
            self.tableView.reloadData()
            self.showHintLabel(self.form.ticket.property.surroundings.count == 0)
            SVProgressHUD.dismiss()
            return task
        }
    }

    private func getAroundTime(timeValue:Int32) -> [Int32] {
        return [timeValue - 30,
            timeValue - 25,
            timeValue - 20,
            timeValue - 15,
            timeValue - 10,
            timeValue - 5,
            timeValue,
            timeValue + 5,
            timeValue + 10,
            timeValue + 15,
            timeValue + 20,
            timeValue + 25,
            timeValue + 30
            ].filter { (value:Int32) -> Bool in
            return value >= 0
        }
    }
}
