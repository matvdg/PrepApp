
import UIKit
import Charts

class HomeViewController: UIViewController, ChartViewDelegate {
	
    @IBOutlet weak var pieView: PieChartView!
	
    @IBOutlet weak var menuButton:UIBarButtonItem!

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
        //pie settings
        self.pieView.delegate = self
        self.pieView.usePercentValuesEnabled = true
        self.pieView.holeTransparent = true
        self.pieView.holeRadiusPercent = 0.30
        self.pieView.transparentCircleRadiusPercent = 0.31
        self.pieView.drawHoleEnabled = true
        //data
        self.pieView.data = self.getChartData()
        //centerText
        self.pieView.centerTextColor = UIColor.blueColor()
        self.pieView.centerText = ""
        self.pieView.centerTextFont = UIFont(name: "Segoe UI", size: 17)!
        //description
        self.pieView.descriptionFont = UIFont(name: "Segoe UI", size: 17)!
        self.pieView.descriptionText = ""
        self.pieView.descriptionTextColor = UIColor.redColor()
        //rotation
        self.pieView.rotationAngle = 0
        self.pieView.rotationEnabled = true
        self.pieView.drawSliceTextEnabled = true
        
        self.renderLogo()
       
	}
    
    func getChartData() -> ChartData {
        
        var yVals: [ChartDataEntry] = []
        for i in 0..<3
        {
            var mult: Double = Double(arc4random_uniform(100) + 100 / 100)
            yVals.append(BarChartDataEntry(value: mult, xIndex: i))
        
        }
        var dataSet : PieChartDataSet = PieChartDataSet(yVals: yVals)
        dataSet.sliceSpace = 10.0
        var colors: [UIColor] = [colorBio,colorPhy,colorChi]
        dataSet.colors = colors
        var data: PieChartData = PieChartData(xVals: ["Biologie","Physique","Chimie"], dataSet: dataSet)
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
    
    func renderLogo(){
        let logo = UIImageView(frame: CGRectMake(self.view!.bounds.width / 2 - 55, self.view!.bounds.height / 2 - 35, 110, 110))
        logo.image = UIImage(named: "logoHD")
        self.view.addSubview(logo)
    }
	

}
