
import UIKit
import Charts

class HomeViewController: UIViewController, ChartViewDelegate {
	
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var newsButton: UIButton!
    
    enum pie: Int {
        case biology = 1, physics, chemistry
    }
    var type: pie = .biology

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Segoe UI", size: 20)!]
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: "failed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: "update", object: nil)

		if self.revealViewController() != nil {
			menuButton.target = self.revealViewController()
			menuButton.action = "revealToggle:"
			self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.newsButton.layer.cornerRadius = 6.0
        self.welcome.text = "Bonjour, \(User.currentUser!.firstName) \(User.currentUser!.lastName) !"
        self.renderChemistryPieChart()
        self.renderPhysicsPieChart()
        self.renderBiologyPieChart()
        self.renderLevel()

       
	}
    
    func renderBiologyPieChart(){
        var bioPie = PieChartView(frame: CGRectMake(100, 0, self.view.bounds.width-200, self.view.bounds.height))
        //pie settings
        bioPie.delegate = self
        bioPie.backgroundColor = UIColor.clearColor()
        bioPie.usePercentValuesEnabled = false
        bioPie.holeTransparent = true
        bioPie.holeRadiusPercent = 0.75
        bioPie.transparentCircleRadiusPercent = 0.75
        bioPie.drawHoleEnabled = true
        bioPie.drawSliceTextEnabled = false
        bioPie.drawMarkers = false
        bioPie.legend.setCustom(colors: [UIColor.clearColor()], labels: [""])
        //data
        self.type = .biology
        bioPie.data = self.getChartData(self.type.rawValue)
        //centerText
        bioPie.centerTextColor = UIColor.blueColor()
        bioPie.centerText = ""
        bioPie.centerTextFont = UIFont(name: "Segoe UI", size: 17)!
        //description
        bioPie.descriptionFont = UIFont(name: "Segoe UI", size: 17)!
        bioPie.descriptionText = ""
        bioPie.descriptionTextColor = UIColor.redColor()
        //rotation
        bioPie.rotationAngle = 267
        bioPie.rotationEnabled = false
        //displaying
        var bioLogo = UIImageView(frame: CGRectMake(self.view.bounds.width/2 + 5, self.view.bounds.height/2 - 85, 14, 14))
        bioLogo.image = UIImage(named: "bio")
        self.view.addSubview(bioPie)
        self.view.addSubview(bioLogo)

    }
    
    func renderPhysicsPieChart(){
        var phyPie = PieChartView(frame: CGRectMake(70, 0, self.view.bounds.width-140, self.view.bounds.height))
        //pie settings
        phyPie.delegate = self
        phyPie.backgroundColor = UIColor.clearColor()
        phyPie.usePercentValuesEnabled = true
        phyPie.holeTransparent = true
        phyPie.holeRadiusPercent = 0.72
        phyPie.transparentCircleRadiusPercent = 0.77
        phyPie.drawHoleEnabled = true
        phyPie.drawSliceTextEnabled = true
        phyPie.drawMarkers = false
        phyPie.legend.setCustom(colors: [UIColor.clearColor()], labels: [""])
        //data
        self.type = .physics
        phyPie.data = self.getChartData(self.type.rawValue)
        //centerText
        phyPie.centerTextColor = UIColor.blueColor()
        phyPie.centerText = ""
        phyPie.centerTextFont = UIFont(name: "Segoe UI", size: 17)!
        //description
        phyPie.descriptionFont = UIFont(name: "Segoe UI", size: 17)!
        phyPie.descriptionText = ""
        phyPie.descriptionTextColor = UIColor.redColor()
        //rotation
        phyPie.rotationAngle = 267
        phyPie.rotationEnabled = false
        //displaying

        self.view.addSubview(phyPie)
        var phyLogo = UIImageView(frame: CGRectMake(self.view.bounds.width/2 + 5, self.view.bounds.height/2 - 110, 14, 14))
        phyLogo.image = UIImage(named: "phy")
        self.view.addSubview(phyLogo)

    }
    
    func renderChemistryPieChart(){
        var chePie = PieChartView(frame: CGRectMake(40, 0, self.view.bounds.width-80, self.view.bounds.height))
        //pie settings
        chePie.delegate = self
        chePie.backgroundColor = UIColor.clearColor()
        chePie.usePercentValuesEnabled = true
        chePie.holeTransparent = true
        chePie.holeRadiusPercent = 0.78
        chePie.transparentCircleRadiusPercent = 0.82
        chePie.drawHoleEnabled = true
        chePie.drawSliceTextEnabled = false
        chePie.drawMarkers = false
        chePie.legend.setCustom(colors: [UIColor.clearColor()], labels: [""])
        //data
        self.type = .chemistry
        chePie.data = self.getChartData(self.type.rawValue)
        //centerText
        chePie.centerTextColor = UIColor.blueColor()
        chePie.centerText = ""
        chePie.centerTextFont = UIFont(name: "Segoe UI", size: 17)!
        //description
        chePie.descriptionFont = UIFont(name: "Segoe UI", size: 17)!
        chePie.descriptionText = ""
        chePie.descriptionTextColor = UIColor.redColor()
        //rotation
        chePie.rotationAngle = 267
        chePie.rotationEnabled = false
        //displaying

        self.view.addSubview(chePie)
        var chiLogo = UIImageView(frame: CGRectMake(self.view.bounds.width/2 + 5, self.view.bounds.height/2 - 145, 14, 14))
        chiLogo.image = UIImage(named: "chi")
        self.view.addSubview(chiLogo)

    }
    
    func getChartData(pie: Int) -> ChartData {
        
        var yVals: [ChartDataEntry] = []
        switch pie {
        case 1 :
            yVals.append(BarChartDataEntry(value: 70, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 30, xIndex: 2))
        case 2 :
            yVals.append(BarChartDataEntry(value: 50, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 50, xIndex: 2))
        case 3 :
            yVals.append(BarChartDataEntry(value: 80, xIndex: 1))
            yVals.append(BarChartDataEntry(value: 20, xIndex: 2))
        default :
            yVals.append(BarChartDataEntry(value: 50, xIndex: 1))
        }
        var dataSet : PieChartDataSet = PieChartDataSet(yVals: yVals)
        dataSet.sliceSpace = 10.0
        var colors: [UIColor] = [colorBio,colorPhy,colorChi]
        
        switch pie {
        case 1 :
            colors = [colorBio,UIColor.clearColor()]
        case 2 :
            colors = [colorPhy,UIColor.clearColor()]
        case 3 :
            colors = [colorChi,UIColor.clearColor()]
        default :
            colors = [UIColor.clearColor()]
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
        let level = UIButton(frame: CGRectMake(self.view!.bounds.width / 2 - 55, self.view!.bounds.height / 2 - 65, 110, 110))
        level.backgroundColor = colorGreenLogo
        level.layer.borderColor = UIColor.whiteColor().CGColor
        level.layer.borderWidth = 6
        
        level.setTitle(User.currentUser!.level.levelPrepApp(), forState: .Normal)
        level.titleLabel!.font = UIFont(name: "Times New Roman", size: 40)
        println(User.currentUser!.printUser())
        level.layer.cornerRadius = 55
        self.view.addSubview(level)
    }
	

}
