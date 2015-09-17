
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
//    var bioPerf: [Double] = []
//    var phyPerf: [Double] = []
//    var chePerf: [Double] = []
//    var questionsAnswered: [Double] = []
//    var weeksBeforeExam : [String] = []
    
    var bioPerf: [Double] = [60, 66, 70, 75, 72, 70, 73, 80, 82, 84, 86]
    var phyPerf: [Double] = [70, 68, 65, 57, 43, 62, 66, 64, 66, 70, 72]
    var chePerf: [Double] = [40, 43, 45, 48, 48, 51, 55, 62, 73, 80, 92]
    var questionsAnswered: [Double] = [25, 34, 22, 3, 10, 50, 63, 57, 69, 80, 98]
    var weeksBeforeExam : [String] = ["10", "9", "8", "7", "6", "5", "4", "3", "2", "1", "0"]

    var hideTimer = NSTimer()
    var animationTimer = NSTimer()
    var counterAnimationNotification = 0
    var statsPanelDisplayed: Bool = false
    var currentStatsPanelDisplayed: Int = 0
    var type: subject = .biology
    let offsetAngle: CGFloat = 270
    var legendLeftAxis = UILabel()
    var legendRightAxis = UILabel()
    var legendXAxis = UILabel()
    var noDataLabel = UILabel()
    
    //@IBOutlets properties
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var notificationMessage: UILabel!
    @IBOutlet weak var chePieChart: PieChartView!
    @IBOutlet weak var phyPieChart: PieChartView!
    @IBOutlet weak var bioPieChart: PieChartView!
    @IBOutlet weak var levelButton: UIButton!
    @IBOutlet weak var perfChart: CombinedChartView!
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
        self.perfChart.layer.zPosition = 7
        self.legend.layer.zPosition = 0
        self.noDataLabel.layer.zPosition = 8
        self.notificationMessage.layer.zPosition = 5
        //other customization
        self.legend.text = "Inclinez en mode paysage pour voir votre graphe performance. Glissez à droite pour voir le fil d'actualité Prep'App."
        self.stats.hidden = true
        self.view.backgroundColor = colorGreyBackground
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
        
//        self.bioPerf = FactoryHistory.getScoring().getPerf(1)
//        self.phyPerf = FactoryHistory.getScoring().getPerf(2)
//        self.chePerf = FactoryHistory.getScoring().getPerf(3)
//        self.questionsAnswered = FactoryHistory.getScoring().getQuestionsAnswered()
//        self.weeksBeforeExam = FactoryHistory.getScoring().getWeeksBeforeExam()
//        self.checkNumberOfData()
    }
    
    func checkNumberOfData() {
        var max = self.weeksBeforeExam.count
        if self.bioPerf.count < max {
            max = self.bioPerf.count
        }
        if self.phyPerf.count < max {
            max = self.phyPerf.count
        }
        if self.chePerf.count < max {
            max = self.chePerf.count
        }
        while self.weeksBeforeExam.count != max {
            self.weeksBeforeExam.removeLast()
        }
        while self.questionsAnswered.count != max {
            self.questionsAnswered.removeLast()
        }
        while self.bioPerf.count != max {
            self.bioPerf.removeLast()
        }
        while self.phyPerf.count != max {
            self.phyPerf.removeLast()
        }
        while self.chePerf.count != max {
            self.chePerf.removeLast()
        }
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
    
    func renderPerfChart() {
        //settings
        self.perfChart.delegate = self
        self.perfChart.noDataText = ""
        self.perfChart.noDataTextDescription = ""
        self.perfChart.drawBarShadowEnabled = false
        self.perfChart.drawGridBackgroundEnabled = false
        self.perfChart.drawOrder = [CombinedChartDrawOrder.Bar.rawValue, CombinedChartDrawOrder.Line.rawValue]
        self.perfChart.backgroundColor = colorGreyBackground
        self.perfChart.drawMarkers = true
        self.perfChart.highlightEnabled = false
        self.perfChart.highlightPerDragEnabled = false
        self.perfChart.scaleYEnabled = false
        self.perfChart.drawHighlightArrowEnabled = false
        self.perfChart.userInteractionEnabled = true
        self.levelButton.userInteractionEnabled = false
    
        self.perfChart.autoScaleMinMaxEnabled = true
        self.perfChart.rightAxis.drawGridLinesEnabled = false
        self.perfChart.rightAxis.axisLineColor = colorGreenAppButtons
        self.perfChart.rightAxis.startAtZeroEnabled = true
        self.perfChart.rightAxis.axisLineWidth = 4
        self.perfChart.rightAxis.labelFont = UIFont(name: "Segoe UI", size: 12)!
        self.perfChart.rightAxis.labelCount = 10
        self.perfChart.rightAxis.labelTextColor = colorGreenAppButtons
        var formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 3
        formatter.maximumFractionDigits = 0
        formatter.minimumSignificantDigits = 1
        formatter.maximumSignificantDigits = 3
        self.perfChart.rightAxis.valueFormatter = formatter
        
        self.perfChart.leftAxis.drawGridLinesEnabled = false
        self.perfChart.leftAxis.customAxisMax = 100
        self.perfChart.leftAxis.axisLineColor = colorGreenAppButtons
        self.perfChart.leftAxis.startAtZeroEnabled = true
        self.perfChart.leftAxis.axisLineWidth = 4
        self.perfChart.leftAxis.labelCount = 10
        self.perfChart.leftAxis.labelFont = UIFont(name: "Segoe UI", size: 10)!
        self.perfChart.leftAxis.labelTextColor = colorGreenAppButtons

        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.minimumIntegerDigits = 3
        formatter.maximumIntegerDigits = 3
        formatter.maximumFractionDigits = 0   
        formatter.maximumSignificantDigits = 3
        formatter.minimumSignificantDigits = 1
        
        self.perfChart.leftAxis.valueFormatter = formatter
        
        
        self.perfChart.xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.Bottom
        self.perfChart.xAxis.drawGridLinesEnabled = false
        self.perfChart.xAxis.axisLineColor = colorGreenAppButtons
        self.perfChart.xAxis.axisLineWidth = 4
        
        //data
        self.getPerfChartData()
        
        //description
        self.perfChart.descriptionFont = UIFont(name: "Segoe UI", size: 17)!
        self.perfChart.descriptionText = ""
        self.perfChart.legend.font = UIFont(name: "Segoe UI", size: 10)!
        
        

    }
    
    func renderLegendAxis() {
        self.legendXAxis = UILabel(frame: CGRectMake(self.view.bounds.width - 210, self.view.bounds.height - 40, 190, 30))
        self.legendLeftAxis = UILabel(frame: CGRectMake(35, 50, 150, 20))
        self.legendRightAxis = UILabel(frame: CGRectMake(self.view.bounds.width - 250, 50, 220, 20))
        self.legendLeftAxis.text = "Questions réussies (%)"
        self.legendRightAxis.text = "Nombre de questions répondues"
        self.legendXAxis.text = "Semaines avant le concours"
        self.legendLeftAxis.textColor = colorGreenAppButtons
        self.legendRightAxis.textColor = colorGreenAppButtons
        self.legendXAxis.textColor = UIColor.blackColor()
        self.legendLeftAxis.font = UIFont(name: "Segoe UI", size: 15)
        self.legendRightAxis.font = UIFont(name: "Segoe UI", size: 15)
        self.legendXAxis.font = UIFont(name: "Segoe UI", size: 15)
        self.view.addSubview(self.legendXAxis)
        self.view.addSubview(self.legendLeftAxis)
        self.view.addSubview(self.legendRightAxis)
        self.legendLeftAxis.layer.zPosition = 8
        self.legendRightAxis.layer.zPosition = 8
        self.legendXAxis.layer.zPosition = 8
        
        
    }
    
    func removeLegendAxis(){
        self.legendLeftAxis.removeFromSuperview()
        self.legendRightAxis.removeFromSuperview()
        self.legendXAxis.removeFromSuperview()
        self.noDataLabel.removeFromSuperview()
    }
    
    func getPieChartData(subject: Int) -> ChartData {
        
        
        var yVals: [ChartDataEntry] = []
        switch subject {
        case 1 :
            yVals.append(BarChartDataEntry(value: self.bio, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 100-self.bio, xIndex: 2))
        case 2 :
            yVals.append(BarChartDataEntry(value: self.phy, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 100-self.phy, xIndex: 2))
        case 3 :
            yVals.append(BarChartDataEntry(value: self.che, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 100-self.che, xIndex: 2))
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
            colors = [colorGreyBackground]
        }
        dataSet.colors = colors
        dataSet.valueTextColor = UIColor.clearColor()
        var data: PieChartData = PieChartData(xVals: ["",""], dataSet: dataSet)
        return data
    }
    
    func getPerfChartData() {
        if self.weeksBeforeExam.count < 2 {
            self.noDataLabel = UILabel(frame: CGRectMake(0, self.view.bounds.height / 2 - 100, self.view.bounds.width, 200))
            self.noDataLabel.text = "Pas assez de données pour le moment. Le graphe performances nécessite au moins deux semaines de données, veuillez revenir plus tard."
            self.noDataLabel.font = UIFont(name: "Segoe UI", size: 20)
            self.noDataLabel.numberOfLines = 4
            self.noDataLabel.textAlignment = NSTextAlignment.Center
            self.noDataLabel.textColor = colorGreenAppButtons
            self.noDataLabel.layer.zPosition = 8
            self.view.addSubview(self.noDataLabel)
        } else {
            //biology
            var dataEntries: [ChartDataEntry] = []
            for i in 0..<weeksBeforeExam.count {
                let dataEntry = ChartDataEntry(value: self.bioPerf[i], xIndex: i)
                dataEntries.append(dataEntry)
            }
            let bioLineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Biologie")
            bioLineChartDataSet.colors = [colorBio]
            bioLineChartDataSet.lineWidth = 5.0
            bioLineChartDataSet
            bioLineChartDataSet.circleColors = [colorBio]
            bioLineChartDataSet.circleHoleColor = colorBio
            bioLineChartDataSet.circleRadius = 2
            bioLineChartDataSet.valueTextColor = UIColor.clearColor()
            bioLineChartDataSet.drawCubicEnabled = true
            bioLineChartDataSet.drawValuesEnabled = false
            bioLineChartDataSet.axisDependency = ChartYAxis.AxisDependency.Left
            
            //physics
            dataEntries = []
            for i in 0..<self.weeksBeforeExam.count {
                let dataEntry = ChartDataEntry(value: self.phyPerf[i], xIndex: i)
                dataEntries.append(dataEntry)
            }
            let phyLineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Physique")
            phyLineChartDataSet.colors = [colorPhy]
            phyLineChartDataSet.lineWidth = 5.0
            phyLineChartDataSet.circleColors = [colorPhy]
            phyLineChartDataSet.circleHoleColor = colorPhy
            phyLineChartDataSet.circleRadius = 2
            phyLineChartDataSet.valueTextColor = UIColor.clearColor()
            phyLineChartDataSet.drawCubicEnabled = true
            phyLineChartDataSet.drawValuesEnabled = false
            phyLineChartDataSet.axisDependency = ChartYAxis.AxisDependency.Left
            
            //chemistry
            dataEntries = []
            for i in 0..<self.weeksBeforeExam.count {
                let dataEntry = ChartDataEntry(value: self.chePerf[i], xIndex: i)
                dataEntries.append(dataEntry)
            }
            let cheLineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Chimie")
            cheLineChartDataSet.colors = [colorChe]
            cheLineChartDataSet.lineWidth = 5.0
            cheLineChartDataSet.circleColors = [colorChe]
            cheLineChartDataSet.circleHoleColor = colorChe
            cheLineChartDataSet.circleRadius = 2
            cheLineChartDataSet.valueTextColor = UIColor.clearColor()
            cheLineChartDataSet.drawCubicEnabled = true
            cheLineChartDataSet.drawValuesEnabled = false
            cheLineChartDataSet.axisDependency = ChartYAxis.AxisDependency.Left
            
            //barChart
            dataEntries = []
            for i in 0..<self.weeksBeforeExam.count {
                let dataEntry = BarChartDataEntry(value: self.questionsAnswered[i], xIndex: i)
                dataEntries.append(dataEntry)
            }
            let barDataSet = BarChartDataSet(yVals: dataEntries, label: "Nombre de questions répondues")
            barDataSet.colors = [colorGreenLogo.colorWithAlphaComponent(0.5)]
            barDataSet.valueTextColor = UIColor.clearColor()
            barDataSet.drawValuesEnabled = false
            barDataSet.axisDependency = ChartYAxis.AxisDependency.Right
            
            //global
            let lineChartData = LineChartData(xVals: self.weeksBeforeExam, dataSets: [bioLineChartDataSet,phyLineChartDataSet,cheLineChartDataSet])
            let barChartData = BarChartData(xVals: self.weeksBeforeExam, dataSet: barDataSet)
            var data = CombinedChartData(xVals: self.weeksBeforeExam)
            data.lineData = lineChartData
            data.barData = barChartData
            self.perfChart.data = data
            self.renderLegendAxis()
        }
        
        
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
                self.notificationMessage.center = CGPointMake(self.notificationMessage.center.x, 42)
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
                self.notificationMessage.center = CGPointMake(self.notificationMessage.center.x, 42)
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
            self.animationTimer.invalidate()
            self.hideTimer.invalidate()
            self.counterAnimationNotification = 0
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
        self.renderPerfChart()
        self.hidePieCharts(true)
        self.perfChart.hidden = false
        self.title = "Performances"
    }
    
    func hideGraph() {
        self.removeLegendAxis()
        self.levelButton.userInteractionEnabled = true
        self.perfChart.hidden = true
        self.noDataLabel.hidden = true
        self.title = "Accueil"
        self.animatePieCharts()
    }
    
    func hidePieCharts(bool: Bool) {
        self.chePieChart.hidden = bool
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if let statsVC = segue.destinationViewController as? StatsViewController {
            // Pass the selected object to the new view controller.
        }
    }

	

}
