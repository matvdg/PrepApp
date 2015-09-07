
import UIKit
import Charts

class HomeViewController: UIViewController, ChartViewDelegate {
	
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var chePieChart: PieChartView!
    @IBOutlet weak var phyPieChart: PieChartView!
    @IBOutlet weak var bioPieChart: PieChartView!
    @IBOutlet weak var levelButton: UIButton!
    @IBOutlet weak var graphView: UIView!
    
    enum pie: Int {
        case biology = 1, physics, chemistry
    }
    
    @IBAction func showStats(sender: AnyObject) {
        self.performSegueWithIdentifier("showStats", sender: self)
    }
    
    var type: pie = .biology
    let offsetAngle: CGFloat = 265

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = colorGreyBackgound
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
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
        self.welcome.text = "Bonjour, \(User.currentUser!.firstName) \(User.currentUser!.lastName) !"
        self.renderChemistryPieChart()
        self.renderPhysicsPieChart()
        self.renderBiologyPieChart()
        self.renderLevel()

       
	}
    
    func swiped(gesture : UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.Left:
                println("right")
                self.performSegueWithIdentifier("showNews", sender: self)
            
            default:
                println("other")
                break
                
            }
    
        }
    }
    
    func renderBiologyPieChart(){
        
        //pie settings
        self.self.bioPieChart.delegate = self
        self.self.bioPieChart.backgroundColor = UIColor.clearColor()
        self.self.bioPieChart.usePercentValuesEnabled = false
        self.bioPieChart.holeTransparent = true
        self.bioPieChart.holeColor = colorGreyBackgound
        self.bioPieChart.holeRadiusPercent = 0
        self.bioPieChart.transparentCircleRadiusPercent = 0
        self.bioPieChart.drawHoleEnabled = false
        self.bioPieChart.drawSliceTextEnabled = false
        self.bioPieChart.drawMarkers = false
        self.bioPieChart.legend.setCustom(colors: [UIColor.clearColor()], labels: [""])
        //data
        self.type = .biology
        self.bioPieChart.data = self.getChartData(self.type.rawValue)
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
        self.phyPieChart.holeColor = colorGreyBackgound
        self.phyPieChart.holeRadiusPercent = 0.75
        self.phyPieChart.transparentCircleRadiusPercent = 0.80
        self.phyPieChart.drawHoleEnabled = true
        self.phyPieChart.drawSliceTextEnabled = true
        self.phyPieChart.drawMarkers = false
        self.phyPieChart.legend.setCustom(colors: [UIColor.clearColor()], labels: [""])
        //data
        self.type = .physics
        self.phyPieChart.data = self.getChartData(self.type.rawValue)
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
        self.chePieChart.holeColor = colorGreyBackgound
        self.chePieChart.holeRadiusPercent = 0.805
        self.chePieChart.transparentCircleRadiusPercent = 0.84
        self.chePieChart.drawHoleEnabled = true
        self.chePieChart.drawSliceTextEnabled = false
        self.chePieChart.drawMarkers = false
        self.chePieChart.legend.setCustom(colors: [UIColor.clearColor()], labels: [""])
        //data
        self.type = .chemistry
        self.chePieChart.data = self.getChartData(self.type.rawValue)
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
    
    func getChartData(pie: Int) -> ChartData {
        
        var yVals: [ChartDataEntry] = []
        switch pie {
        case 1 :
            yVals.append(BarChartDataEntry(value: 100, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 0, xIndex: 2))
        case 2 :
            yVals.append(BarChartDataEntry(value: 100, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 0, xIndex: 2))
        case 3 :
            yVals.append(BarChartDataEntry(value: 100, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 0, xIndex: 2))
        default :
            yVals.append(BarChartDataEntry(value: 50, xIndex: 1))
        }
        var dataSet : PieChartDataSet = PieChartDataSet(yVals: yVals)
        dataSet.sliceSpace = 10.0
        var colors: [UIColor] = [colorBio,colorPhy,colorChe]
        
        switch pie {
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
    
    ///called when touchID failed, authenticated = false
    func logout() {
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
        println(User.currentUser!.printUser())
        self.levelButton.layer.cornerRadius = self.levelButton.frame.width / 2
    }
    
    func showGraph() {
        self.graphView.hidden = false
        self.title = "Performances"
    }
    func hideGraph() {
            self.graphView.hidden = true
        self.title = "Accueil"
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
