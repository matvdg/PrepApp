
import UIKit
import Charts

class HomeViewController: UIViewController, ChartViewDelegate {
    
    //properties
    enum subject: Int {
        case biology = 1, physics, chemistry
    }
    var bio: Double = 0
    var phy: Double = 0
    var che: Double = 0
    var bioNumber: Int = 0
    var phyNumber: Int = 0
    var cheNumber: Int = 0
    var bioNumberToDo: Int = 0
    var phyNumberToDo: Int = 0
    var cheNumberToDo: Int = 0
    var hideTimer = NSTimer()
    var animationTimer = NSTimer()
    var counterAnimationNotification = 0
    var statsPanelDisplayed: Bool = false
    var currentStatsPanelDisplayed: Int = 0
    var type: subject = .biology
    let offsetAngle: CGFloat = 270
    
    //@IBOutlets properties
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var notificationMessage: UILabel!
    @IBOutlet weak var chePieChart: PieChartView!
    @IBOutlet weak var phyPieChart: PieChartView!
    @IBOutlet weak var bioPieChart: PieChartView!
    @IBOutlet weak var levelButton: UIButton!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var bioButton: UIButton!
    @IBOutlet weak var cheButton: UIButton!
    @IBOutlet weak var phyButton: UIButton!
    @IBOutlet weak var bioLogo: UIImageView!
    @IBOutlet weak var cheLogo: UIImageView!
    @IBOutlet weak var phyLogo: UIImageView!
    @IBOutlet weak var stats: UILabel!
    @IBOutlet weak var legend: UILabel!
    @IBOutlet weak var target: UIImageView!
    
    
    
    //@IBAction methods
    @IBAction func showBioStats(sender: AnyObject) {
        Sound.playTrack("next")
        if self.statsPanelDisplayed {
            if self.currentStatsPanelDisplayed == 1 {
                self.statsPanelDisplayed = false
                self.stats.hidden = true
            } else {
                self.currentStatsPanelDisplayed = 1
                self.stats.text = "\(Int(self.bio))%    -    \(self.bioNumber) \(self.singularOrPlural(1, type: 0))    Niveau suivant : \(self.bioNumberToDo) \(self.singularOrPlural(1, type: 1))"
                self.stats.backgroundColor = colorBio
                self.stats.hidden = false
            }
        } else {
            self.statsPanelDisplayed = true
            self.currentStatsPanelDisplayed = 1
            self.stats.text = "\(Int(self.bio))%    -    \(self.bioNumber) \(self.singularOrPlural(1, type: 0))    Niveau suivant : \(self.bioNumberToDo) \(self.singularOrPlural(1, type: 1))"
            self.stats.backgroundColor = colorBio
            self.stats.hidden = false
        }
    }
    
    @IBAction func showPhyStats(sender: AnyObject) {
        Sound.playTrack("next")
        if self.statsPanelDisplayed {
            if self.currentStatsPanelDisplayed == 2 {
                self.statsPanelDisplayed = false
                self.stats.hidden = true
            } else {
                self.currentStatsPanelDisplayed = 2
                self.stats.text = "\(Int(self.phy))%    -    \(self.phyNumber) \(self.singularOrPlural(2, type: 0))    Niveau suivant : \(self.phyNumberToDo) \(self.singularOrPlural(2, type: 1))"
                self.stats.backgroundColor = colorPhy
                self.stats.hidden = false
            }
        } else {
            self.statsPanelDisplayed = true
            self.currentStatsPanelDisplayed = 2
            self.stats.text = "\(Int(self.phy))%    -    \(self.phyNumber) \(self.singularOrPlural(2, type: 0))    Niveau suivant : \(self.phyNumberToDo) \(self.singularOrPlural(2, type: 1))"
            self.stats.backgroundColor = colorPhy
            self.stats.hidden = false
        }
    }
    
    @IBAction func showCheStats(sender: AnyObject) {
        Sound.playTrack("next")
        if self.statsPanelDisplayed {
            if self.currentStatsPanelDisplayed == 3 {
                self.statsPanelDisplayed = false
                self.stats.hidden = true
            } else {
                self.currentStatsPanelDisplayed = 3
                self.stats.text = "\(Int(self.che))%    -    \(self.cheNumber) \(self.singularOrPlural(3, type: 0))    Niveau suivant : \(self.cheNumberToDo) \(self.singularOrPlural(3, type: 1))"
                self.stats.backgroundColor = colorChe
                self.stats.hidden = false
            }
        } else {
            self.statsPanelDisplayed = true
            self.currentStatsPanelDisplayed = 3
            self.stats.text = "\(Int(self.che))%    -    \(self.cheNumber) \(self.singularOrPlural(3, type: 0))    Niveau suivant : \(self.cheNumberToDo) \(self.singularOrPlural(3, type: 1))"
            self.stats.backgroundColor = colorChe
            self.stats.hidden = false
        }
    }

    @IBAction func showStats(sender: AnyObject) {
        self.hidePieCharts(true)
        self.performSegueWithIdentifier("showStats", sender: self)
    }
    
    
    //app methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNotification()
        self.bioPieChart.noDataText = ""
        self.bioPieChart.noDataTextDescription = ""
        self.chePieChart.noDataText = ""
        self.chePieChart.noDataTextDescription = ""
        self.phyPieChart.noDataText = ""
        self.phyPieChart.noDataTextDescription = ""
        //retrieving data
        self.renderLevel()
        self.retrieveData()
        //designing border radius buttons
        self.bioButton.layer.cornerRadius = 6
        self.cheButton.layer.cornerRadius = 6
        self.stats.layer.cornerRadius = 6
        self.stats.layer.masksToBounds = true
        //z positions
        self.phyButton.layer.zPosition = 3
        self.phyLogo.layer.zPosition = 4
        self.bioButton.layer.zPosition = 2
        self.bioLogo.layer.zPosition = 4
        self.cheButton.layer.zPosition = 2
        self.cheLogo.layer.zPosition = 4
        self.stats.layer.zPosition = 1
        self.graphView.layer.zPosition = 7
        self.notificationMessage.layer.zPosition = 5
        //other customization
        self.legend.text = "Inclinez en mode paysage pour voir votre graphe performance. Glissez à droite pour voir le fil d'actualité Prep'App."
        self.stats.hidden = true
        self.view.backgroundColor = colorGreyBackgound
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitDay, fromDate: date)
        var currentDay = components.day
        if  User.currentDay != currentDay {
            User.currentDay = currentDay
            self.notificationMessage.text = self.loadNotificationMessage()
            self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("showNotification"), userInfo: nil, repeats: true)
            self.hideTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("hideNotification"), userInfo: nil, repeats: false)
        }
        //notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showGraph", name: "landscape", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideGraph", name: "portrait", object: nil)

        //handling swipe gestures
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.renderPieCharts()
    }
    
    
    //methods
    func retrieveData() {
        var (percent,answers,todo) = FactoryHistory.getScoring().getScore(1)
        self.bio = Double(percent)
        self.bioNumber = answers
        self.bioNumberToDo = todo
        (percent,answers,todo) = FactoryHistory.getScoring().getScore(2)
        self.phy = Double(percent)
        self.phyNumber = answers
        self.phyNumberToDo = todo
        (percent,answers,todo) = FactoryHistory.getScoring().getScore(3)
        self.che = Double(percent)
        self.cheNumber = answers
        self.cheNumberToDo = todo
    }
    
    func loadNotificationMessage() -> String {
        if UserPreferences.welcome {
            UserPreferences.welcome = false
            UserPreferences.saveUserPreferences()
            return "Bienvenue \(User.currentUser!.firstName) \(User.currentUser!.lastName) !"
        } else {
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components(.CalendarUnitHour, fromDate: date)
            let hour = components.hour
            if hour > 18 {
                return "Bonsoir \(User.currentUser!.firstName) !"
            } else {
                return "Bonjour \(User.currentUser!.firstName) !"
            }
            
        }
    }
    
    func singularOrPlural(subject: Int, type: Int) -> String {
        
        var number = 0
        
        switch subject {
        case 1 : //biology
            switch type {
            case 0 : //succeeded
                    number = bioNumber
            case 1 : //todo
                number = bioNumberToDo
            default :
                println("error")
            }
        
        case 2 : //physics
            switch type {
            case 0 : //succeeded
                number = phyNumber
            case 1 : //todo
                number = phyNumberToDo
            default :
                println("error")
            }
        case 3 : //chemistry
            switch type {
            case 0 : //succeeded
                number = cheNumber
            case 1 : //todo
                number = cheNumberToDo
            default :
                println("error")
            }
        default:
            println("error")
        }
        
        switch type {
        case 0 : //succeeded
            if number == 0 || number == 1 {
                return "question réussie"
            } else {
                return "questions réussies"
            }
        case 1 : //todo
            if number == 0 || number == 1 {
                return "question"
            } else {
                return "questions"
            }
        default :
            return "error"
        }
    }
    
    func swiped(gesture : UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Left:
                self.hidePieCharts(true)
                self.performSegueWithIdentifier("showNews", sender: self)
            
            default:
                println("other")
                break
                
            }
    
        }
    }
    
    func renderBiologyPieChart(){
        
        //pie settings
        self.bioPieChart.delegate = self
        self.bioPieChart.backgroundColor = UIColor.clearColor()
        self.bioPieChart.usePercentValuesEnabled = false
        self.bioPieChart.holeTransparent = true
        self.bioPieChart.holeColor = UIColor.clearColor()
        self.bioPieChart.holeRadiusPercent = 0
        self.bioPieChart.transparentCircleRadiusPercent = 0
        self.bioPieChart.drawHoleEnabled = false
        self.bioPieChart.drawSliceTextEnabled = false
        self.bioPieChart.drawMarkers = false
        self.bioPieChart.legend.setCustom(colors: [UIColor.clearColor()], labels: [""])
        //data
        self.type = .biology
        self.bioPieChart.data = self.getPieChartData(self.type.rawValue)
        //centerText
        //self.bioPieChart.centerTextColor = UIColor.blueColor()
        self.bioPieChart.centerText = ""
        self.bioPieChart.centerTextFont = UIFont(name: "Segoe UI", size: 17)!
        //description
        self.bioPieChart.descriptionFont = UIFont(name: "Segoe UI", size: 17)!
        self.bioPieChart.descriptionText = ""
        //self.bioPieChart.descriptionTextColor = UIColor.redColor()
        //rotation
        self.bioPieChart.rotationAngle = self.offsetAngle
        self.bioPieChart.rotationEnabled = false

    }
    
    func renderPhysicsPieChart(){
        //pie settings
        self.phyPieChart.delegate = self
        self.phyPieChart.backgroundColor = UIColor.clearColor()
        self.phyPieChart.usePercentValuesEnabled = true
        self.phyPieChart.holeTransparent = true
        self.phyPieChart.holeColor = UIColor.clearColor()
        self.phyPieChart.holeRadiusPercent = 0.76
        self.phyPieChart.transparentCircleRadiusPercent = 0
        self.phyPieChart.drawHoleEnabled = true
        self.phyPieChart.drawSliceTextEnabled = true
        self.phyPieChart.drawMarkers = false
        self.phyPieChart.legend.setCustom(colors: [UIColor.clearColor()], labels: [""])
        //data
        self.type = .physics
        self.phyPieChart.data = self.getPieChartData(self.type.rawValue)
        //centerText
        self.phyPieChart.centerText = ""
        self.phyPieChart.centerTextFont = UIFont(name: "Segoe UI", size: 17)!
        //description
        self.phyPieChart.descriptionFont = UIFont(name: "Segoe UI", size: 17)!
        self.phyPieChart.descriptionText = ""
        //rotation
        self.phyPieChart.rotationAngle = self.offsetAngle
        self.phyPieChart.rotationEnabled = false

    }
    
    func renderChemistryPieChart(){
        //pie settings
        self.chePieChart.delegate = self
        self.chePieChart.backgroundColor = UIColor.clearColor()
        self.chePieChart.usePercentValuesEnabled = true
        self.chePieChart.holeTransparent = true
        self.chePieChart.holeColor = UIColor.clearColor()
        self.chePieChart.holeRadiusPercent = 0.805
        self.chePieChart.transparentCircleRadiusPercent = 0
        self.chePieChart.drawHoleEnabled = true
        self.chePieChart.drawSliceTextEnabled = false
        self.chePieChart.drawMarkers = false
        self.chePieChart.legend.setCustom(colors: [UIColor.clearColor()], labels: [""])
        //data
        self.type = .chemistry
        self.chePieChart.data = self.getPieChartData(self.type.rawValue)
        //centerText
        self.chePieChart.centerText = ""
        self.chePieChart.centerTextFont = UIFont(name: "Segoe UI", size: 17)!
        //description
        self.chePieChart.descriptionFont = UIFont(name: "Segoe UI", size: 17)!
        self.chePieChart.descriptionText = ""
        //rotation
        self.chePieChart.rotationAngle = self.offsetAngle
        self.chePieChart.rotationEnabled = false

    }
    
    func getPieChartData(subject: Int) -> ChartData {
        
        
        var yVals: [ChartDataEntry] = []
        switch subject {
        case 1 :
            yVals.append(BarChartDataEntry(value: bio, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 100-bio, xIndex: 2))
        case 2 :
            yVals.append(BarChartDataEntry(value: phy, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 100-phy, xIndex: 2))
        case 3 :
            yVals.append(BarChartDataEntry(value: che, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 100-che, xIndex: 2))
        default :
            yVals.append(BarChartDataEntry(value: 50, xIndex: 1))
        }
        var dataSet : PieChartDataSet = PieChartDataSet(yVals: yVals)
        dataSet.sliceSpace = 0.0
        var colors: [UIColor] = [colorBio,colorPhy,colorChe]
        
        switch subject {
        case 1 :
            colors = [colorBio,UIColor.clearColor()]
        case 2 :
            colors = [colorPhy,UIColor.clearColor()]
        case 3 :
            colors = [colorChe,UIColor.clearColor()]
        default :
            colors = [colorGreyBackgound]
        }
        dataSet.colors = colors
        dataSet.valueTextColor = UIColor.clearColor()
        var data: PieChartData = PieChartData(xVals: ["",""], dataSet: dataSet)
        return data
    }
    
    func getPerfChartData(subject: Int) -> ChartData {
        var bio: Double = Double(arc4random()%100)
        var phy: Double = Double(arc4random()%100)
        var che: Double = Double(arc4random()%100)
        
        var yVals: [ChartDataEntry] = []
        switch subject {
        case 1 :
            yVals.append(BarChartDataEntry(value: bio, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 100-bio, xIndex: 2))
        case 2 :
            yVals.append(BarChartDataEntry(value: phy, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 100-phy, xIndex: 2))
        case 3 :
            yVals.append(BarChartDataEntry(value: che, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 100-che, xIndex: 2))
        default :
            yVals.append(BarChartDataEntry(value: 50, xIndex: 1))
        }
        var dataSet : PieChartDataSet = PieChartDataSet(yVals: yVals)
        dataSet.sliceSpace = 10.0
        var colors: [UIColor] = [colorBio,colorPhy,colorChe]
        
        switch subject {
        case 1 :
            colors = [colorBio,colorGreyBackgound]
        case 2 :
            colors = [colorPhy,colorGreyBackgound]
        case 3 :
            colors = [colorChe,colorGreyBackgound]
        default :
            colors = [colorGreyBackgound]
        }
        dataSet.colors = colors
        dataSet.valueTextColor = UIColor.clearColor()
        var data: PieChartData = PieChartData(xVals: ["",""], dataSet: dataSet)
        return data
    }
    
    func showNotification() {
        self.counterAnimationNotification++
        if self.counterAnimationNotification <= 25 {
            self.notificationMessage.center = CGPointMake(self.notificationMessage.center.x, self.notificationMessage.center.y + 2)
        } else {
            self.animationTimer.invalidate()
        }
    }

    func hideNotification() {
        if self.counterAnimationNotification > 0 {
            self.counterAnimationNotification = 0
            self.hideTimer.invalidate()
            self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("hideNotification"), userInfo: nil, repeats: true)
            
        } else {
            self.counterAnimationNotification--
            if self.counterAnimationNotification >= -25 {
                self.notificationMessage.center = CGPointMake(self.notificationMessage.center.x, self.notificationMessage.center.y - 2)
            } else {
                self.animationTimer.invalidate()
            }
        }
        
    }
    
    func hideNotificationLevel() {
        if self.counterAnimationNotification > 0 {
            
            self.renderPieCharts()
            self.counterAnimationNotification = 0
            self.hideTimer.invalidate()
            self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("hideNotification"), userInfo: nil, repeats: true)
            
        } else {
            self.counterAnimationNotification--
            if self.counterAnimationNotification >= -25 {
                self.notificationMessage.center = CGPointMake(self.notificationMessage.center.x, self.notificationMessage.center.y - 2)
            } else {
                self.animationTimer.invalidate()
            }
        }
        
    }

    func logout() {
        ///called when touchID failed, authenticated = false
        println("logging out")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func update() {
        // create alert controller
        let myAlert = UIAlertController(title: "Une mise à jour des questions est disponible", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        // add an "later" button
        myAlert.addAction(UIAlertAction(title: "Plus tard", style: UIAlertActionStyle.Default, handler: nil))
        // add an "update" button
        myAlert.addAction(UIAlertAction(title: "Mettre à jour maintenant", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        // show the alert
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
    func renderLevel(){
        self.levelButton.titleLabel!.font = UIFont(name: "Times New Roman", size: 70)
        self.levelButton.backgroundColor = colorGreenLogo
        self.levelButton.layer.zPosition = 100
        self.levelButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.levelButton.layer.borderWidth = 6
        self.levelButton.setTitle(User.currentUser!.level.levelPrepApp(), forState: .Normal)
        self.levelButton.titleLabel!.adjustsFontSizeToFitWidth = true
        self.levelButton.titleLabel!.numberOfLines = 1
        self.levelButton.titleLabel!.baselineAdjustment = UIBaselineAdjustment.AlignCenters
        self.levelButton.layer.cornerRadius = self.levelButton.frame.width / 2
    }
    
    func renderPieCharts() {
        self.renderLevel()
        self.renderChemistryPieChart()
        self.renderPhysicsPieChart()
        self.renderBiologyPieChart()
        self.hidePieCharts(false)
        self.animatePieCharts()
    }
    
    func animatePieCharts() {
        self.hidePieCharts(false)
        let animation = ChartEasingOption.Linear
        let timeInterval = NSTimeInterval(1.0)
        self.bioPieChart.animate(yAxisDuration: timeInterval, easingOption: animation)
        self.phyPieChart.animate(yAxisDuration: timeInterval, easingOption: animation)
        self.chePieChart.animate(yAxisDuration: timeInterval, easingOption: animation)
        //after animation, one level up if necessary
        while (self.bio == 100 && self.phy == 100 && self.che == 100) {
            //everything at 100%, one level up!
            var win = ["Le travail est la clef du succès !","Félicitations ! Vous avez gagné un niveau !","Le succès naît de la persévérance.","L'obstination est le chemin de la réussite !","Un travail constant vient à bout de tout.","Le mérite résulte de la persévérance.","La persévérance est la mère des succès.","La persévérance fait surmonter bien des obstacles."]
            win.shuffle()
            self.notificationMessage.text = win[0]
            self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("showNotification"), userInfo: nil, repeats: true)
            self.hideTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("hideNotificationLevel"), userInfo: nil, repeats: false)
            User.currentUser!.level = User.currentUser!.level + 1
            User.currentUser!.saveUser()
            //retrieving new data
            self.retrieveData()
        }
    }
    
    func showGraph() {
        self.hidePieCharts(true)
        self.graphView.hidden = false
        self.title = "Performances"
    }
    
    func hideGraph() {
        self.graphView.hidden = true
        self.title = "Accueil"
        self.animatePieCharts()
    }
    
    func hidePieCharts(bool: Bool) {
        //self.bioPieChart.hidden = bool
        //self.phyPieChart.hidden = bool
        self.chePieChart.hidden = bool
        self.target.hidden = bool
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if let profileVC = segue.destinationViewController as? DetailProfileViewController {
            // Pass the selected object to the new view controller.
            profileVC.profileTopics = "Statistiques"
        }
    }

	

}
