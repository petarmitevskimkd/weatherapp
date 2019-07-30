//
//  WeatherVC.swift
//  weather
//
//  Created by Telekom MK on 7/23/19.
//  Copyright © 2019 petar. All rights reserved.
//

import UIKit
import SceneKit
import SwiftDate
import AlamofireImage
import Alamofire
import URWeatherView
import SpriteKit


class WeatherVC: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    var gradient : CAGradientLayer?
    
    @IBOutlet weak var weatherAnimationView: URWeatherView!
    @IBOutlet weak var starsAndCloudsView: UIView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cityAndCountryLabel: UILabel!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var draggableView: UIView!
    @IBOutlet weak var draggableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var draggableViewBottomConstraintLandscape: NSLayoutConstraint!
    @IBOutlet weak var draggerView: UIView!
    var panGesture = UIPanGestureRecognizer()
    var transY: Double!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var cityCurrentDate: Date!
    var elements = [[String: Weather]]()
    var dayViews: [SingleDayView]!
    var sunRiseAndSetDateFormatter: DateFormatter!
    var yearMonthDayFormatter: DateFormatter!
    var yearMonthDayTimeFormatter: DateFormatter!
    var dayMonthYearTimeFormatter: DateFormatter!
    
    var tempWather: Weather!
    var fromColors: [CGColor]!
    var previousIndex: Int = 0
    var cities: [String:String]!
    var lastCity: String!
    var currentPage: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        self.draggableView.isUserInteractionEnabled = true
        self.draggableView.addGestureRecognizer(panGesture)
        self.dayViews = [SingleDayView]()
        self.cities = (UserDefaults.standard.object(forKey: "cities") as! [String : String])
        self.lastCity = (UserDefaults.standard.object(forKey: "lastCity") as! String)
        self.scrollView.delegate = self
        self.initializeDateFormatters()
        if self.gradient == nil{
            self.gradient = CAGradientLayer()
            self.backgroundView.layer.insertSublayer(self.gradient!, at: 0)
        }
        self.tableView.register(UINib.init(nibName: "CityChooseTVC", bundle: nil), forCellReuseIdentifier: "CityChooseTVC")
        self.tableView.register(UINib.init(nibName: "AddCityTVC", bundle: nil), forCellReuseIdentifier: "AddCityTVC")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.weatherAnimationView.initView(mainWeatherImage: #imageLiteral(resourceName: "test"), backgroundImage: #imageLiteral(resourceName: "test"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fromColors = [UIColor.white.cgColor, UIColor.white.cgColor]
        self.gradient?.colors = self.fromColors
        self.stateImageView.image = self.stateImageView.image?.imageWithColor(color1: UIColor.init(rgb: 0xffffff))
        if NetworkState.isConnected() {
            self.getDataFor(self.cities[lastCity]!)
        }else{
            if OfflineDB.store.load("lastWeather") != nil{
                self.elements.append([self.cities[lastCity]!:OfflineDB.store.decode(OfflineDB.store.load("lastWeather")!)])
                self.changeMainViewToDesiredWOEID(self.cities[lastCity]!)
            }else{
                self.showNotReachable(self)
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradient?.frame = self.backgroundView.frame
        self.draggableView.layer.cornerRadius = 35
        self.draggerView.layer.cornerRadius = 4
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        
    }
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.currentPage = scrollView.contentOffset.x / scrollView.bounds.width
        
    }
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.alignSubviews()
        self.scrollView.contentOffset = CGPoint.init(x: self.currentPage * scrollView.bounds.width, y: 0)
    }
    
    func alignSubviews(){
        
        self.scrollView.contentSize = CGSize.init(width: CGFloat(self.scrollView.frame.width) * CGFloat(self.dayViews.count), height: self.scrollView.frame.height)
        for (index, element) in self.dayViews.enumerated(){
            element.frame = CGRect.init(x: CGFloat(self.scrollView.frame.width) * CGFloat(index), y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
            self.view.layoutIfNeeded()
            self.view.setNeedsLayout()
            
        }
        
    }
    
    
    func initializeDateFormatters(){
        self.sunRiseAndSetDateFormatter = DateFormatter()
        self.sunRiseAndSetDateFormatter.dateFormat = Config.FORMATsunRiseAndSet
        
        self.yearMonthDayFormatter = DateFormatter()
        self.yearMonthDayFormatter.dateFormat = Config.FORMATyearMonthDay
        
        self.yearMonthDayTimeFormatter = DateFormatter()
        self.yearMonthDayTimeFormatter.dateFormat = Config.FORMATyearMonthDayTime
        
        self.dayMonthYearTimeFormatter = DateFormatter()
        self.dayMonthYearTimeFormatter.dateFormat = Config.FORMATdayMontYear
    }
    
    func changeMainViewToDesiredWOEID(_ woeid: String!){
        var weatherData: Weather?
        for e in self.elements{
            if e.keys.contains(woeid){
                weatherData = e[woeid]
                break
            }
        }
        
        guard let weather = weatherData else{return}
        if self.cities[weather.title!] == nil {
            self.cities[weather.title!] = woeid
            UserDefaults.standard.set(self.cities, forKey: "cities")
            self.tableView.reloadData()
        }
        self.scrollView.subviews.forEach({ $0.removeFromSuperview() })
        self.tempWather = weather
        OfflineDB.store.save("lastWeather", OfflineDB.store.encode(weather))
        UserDefaults.standard.set(weather.title!, forKey: "lastCity")
        self.lastCity = (UserDefaults.standard.object(forKey: "lastCity") as! String)
        self.animate(weather.consolidated_weather?.first?.weather_state_abbr!)
        self.cityCurrentDate = changeCurrentDateTo(weather.timezone!)
        self.scrollView.contentSize = CGSize.init(width: CGFloat(self.scrollView.frame.width * CGFloat(Float(weather.consolidated_weather!.count))), height: self.scrollView.frame.height)
        self.scrollView.setContentOffset(.zero, animated: false)
        self.dayViews.removeAll()
        for (index, element) in weather.consolidated_weather!.enumerated(){
            let dayView = SingleDayView()
            self.dayViews.append(dayView)
            dayView.frame = CGRect.init(x: CGFloat(self.scrollView.frame.width) * CGFloat(index), y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
            self.scrollView.addSubview(dayView)
            self.addElementsInScrollViewSubviews(dayView, element, weather)
            
        }
        var toColors: [CGColor]!
        if cityCurrentDate > (self.tempWather.sun_rise!.toDate()?.date)! && cityCurrentDate < (self.tempWather.sun_set?.toDate()?.date)!{
            switch ((self.tempWather.consolidated_weather?.first?.weather_state_abbr!)!){
            case "c":
                toColors = [UIColor.init(rgb: 0x00d5e).cgColor, UIColor.init(rgb: 0x00d5e8).cgColor, UIColor.init(rgb: 0xef73e).cgColor]
                break
            case "lc", "lr", "s", "sl":
                toColors = [UIColor.init(rgb: 0x265e7b).cgColor, UIColor.init(rgb: 0x9cc0d3).cgColor]
                break
            case "hc", "hr", "t", "h":
                toColors = [UIColor.init(rgb: 0x3e5f68).cgColor, UIColor.init(rgb: 0x303d43).cgColor]
                break
            case "sn":
                toColors = [UIColor.init(rgb: 0x9f9f9f).cgColor, UIColor.init(rgb: 0x445157).cgColor]
                break
            default:
                toColors = [UIColor.init(rgb: 0x00d5e).cgColor, UIColor.init(rgb: 0x00d5e8).cgColor, UIColor.init(rgb: 0xef73e).cgColor]
                break
            }
        }else{
            switch ((self.tempWather.consolidated_weather?.first?.weather_state_abbr!)!){
            case "c":
                toColors = [UIColor.init(rgb: 0x14264a).cgColor, UIColor.init(rgb: 0x0b4969).cgColor]
                break
            case "lc", "lr", "s", "sl":
                toColors = [UIColor.init(rgb: 0x274352).cgColor, UIColor.init(rgb: 0x455c67).cgColor]
                break
            case "hc", "hr", "t", "h":
                toColors = [UIColor.init(rgb: 0x264852).cgColor, UIColor.init(rgb: 0x202d36).cgColor]
                break
            case "sn":
                toColors = [UIColor.init(rgb: 0x5a5a5a).cgColor, UIColor.init(rgb: 0x262d31).cgColor]
                break
            default:
                toColors = [UIColor.init(rgb: 0x14264a).cgColor, UIColor.init(rgb: 0x0b4969).cgColor]
                break
            }
        }
        
        let grAnimation = CABasicAnimation(keyPath: "colors")
        grAnimation.fromValue = fromColors
        grAnimation.toValue = toColors
        grAnimation.duration = 0.5
        grAnimation.isRemovedOnCompletion = false
        grAnimation.fillMode = .both
        grAnimation.timingFunction = CAMediaTimingFunction.init(name: .linear)
        self.gradient?.add(grAnimation, forKey: nil)
        self.fromColors = toColors
    }
    func changeCurrentDateTo(_ timeZone: String!) -> Date{
        let format = DateFormatter()
        format.timeZone = TimeZone(identifier: timeZone)!
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dateString = format.string(from: Date())
        return format.date(from: dateString)!
    }
    
    func addElementsInScrollViewSubviews(_ dayView: SingleDayView, _ weather: ConsolidatedWeatherElement, _ result: Weather){
        
        if (weather.applicable_date?.toDate()!.isToday)!{
            dayView.dayLabel.text = "Today"
        }else if (weather.applicable_date?.toDate()!.isTomorrow)!{
            dayView.dayLabel.text = "Tomorow"
        }else{
            dayView.dayLabel.text = self.dayMonthYearTimeFormatter.string(from: (weather.applicable_date?.toDate()!.date)!)
        }
        
        
        
        dayView.minTempLabel.text = String(format:"%d%@c",Int(weather.min_temp!),"\u{00B0}")
        dayView.maxTempLabel.text = String(format:"%d%@c",Int(weather.max_temp!),"\u{00B0}")
        dayView.humidityLabel.text = "\(String(weather.humidity!)) %"
        dayView.visibilityLabel.text = String(format:"%.1f km", (weather.visibility!) * 1.609344)
        dayView.pressureLabel.text = "\(Int(weather.air_pressure!)) mb"
        
        if weather.predictability! < 30{
            dayView.predictabilityImageView.image = UIImage.init(named: "p1")
        }else if weather.predictability! >= 30 && weather.predictability! < 50{
            dayView.predictabilityImageView.image = UIImage.init(named: "p2")
        }else if weather.predictability! >= 50 && weather.predictability! < 70{
            dayView.predictabilityImageView.image = UIImage.init(named: "p3")
        }else{
            dayView.predictabilityImageView.image = UIImage.init(named: "p4")
        }
        
        if weather.wind_direction_compass!.count == 1{
            dayView.windDirectionImageView.image = UIImage.init(named: (weather.wind_direction_compass!.lowercased()))
        }else{
            dayView.windDirectionImageView.image = UIImage.init(named: (weather.wind_direction_compass!.suffix(2) .lowercased()))
        }
        dayView.windSpeedLabel.text = String(format:"%.1f km/h", (weather.wind_speed!) * 1.609344)
        dayView.sunRiseLabel.text = String(format: "%02d:%02d", Calendar.current.component(.hour, from: result.sun_rise!.toDate()!.date), Calendar.current.component(.minute, from:  result.sun_rise!.toDate()!.date))
        dayView.sunSetLabel.text = String(format: "%02d:%02d", Calendar.current.component(.hour, from: result.sun_set!.toDate()!.date), Calendar.current.component(.minute, from:  result.sun_set!.toDate()!.date))
        
        
        self.temperatureLabel.text = String(format:"%d%@c",Int((result.consolidated_weather?.first?.the_temp!)!),"\u{00B0}")
        self.stateLabel.text = (result.consolidated_weather?.first?.weather_state_name!)
        self.cityAndCountryLabel.text = "\(result.title!.uppercased()),\(result.parent!.title!)"
        
        let url = ApiConfig.apiURL + ApiConfig.imageApi + ((result.consolidated_weather?.first?.weather_state_abbr!)!) + ".png"
        if Services.shared.imageCache.image(withIdentifier: ((result.consolidated_weather?.first?.weather_state_abbr!)!)) == nil{
            self.background {
                Alamofire.request(url,method: .get, encoding: JSONEncoding.default).validate(statusCode: 200..<300).validate()
                    .responseImage { response in
                        switch response.result{
                        case .success:
                            self.main {
                                self.stateImageView.image = response.result.value!.imageWithColor(color1: UIColor.init(rgb: 0xffffff))
                                Services.shared.imageCache.add(response.result.value!, withIdentifier: ((result.consolidated_weather?.first?.weather_state_abbr!)!))
                            }
                            
                        case .failure(let error):
                            self.showErrorAlert(self, "Error getting images, error description: \(error.localizedDescription)")
                        }
                }
            }
        }else{
            self.stateImageView.image  = Services.shared.imageCache.image(withIdentifier: ((result.consolidated_weather?.first?.weather_state_abbr!)!))!.imageWithColor(color1: UIColor.init(rgb: 0xffffff))
        }
        
    }
    
    func background(work: @escaping () -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            work()
        }
    }
    
    func main(work: @escaping () -> ()) {
        DispatchQueue.main.async {
            work()
        }
    }
}

// MARK: SCROLLVIEW DELEGATE
extension WeatherVC: UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let indexOfPage = self.scrollView.contentOffset.x / self.scrollView.frame.size.width
        
        if indexOfPage >= 0.0 && indexOfPage.truncatingRemainder(dividingBy: 1) == 0{
            if Int(indexOfPage) != self.previousIndex{
                self.previousIndex = Int(indexOfPage)
                UIView.animate(withDuration: 0.35, animations: {
                    self.starsAndCloudsView.alpha = 0
                    self.weatherAnimationView.alpha = 0
                    self.stateImageView.alpha = 0
                    self.temperatureLabel.alpha = 0
                    self.stateLabel.alpha = 0
                }) { (Bool) in
                    self.animate(self.tempWather.consolidated_weather?[Int(indexOfPage)].weather_state_abbr!)
                    self.temperatureLabel.text = String(format:"%d%@c",Int((self.tempWather.consolidated_weather?[Int(indexOfPage)].the_temp!)!),"\u{00B0}")
                    self.stateLabel.text = self.tempWather.consolidated_weather?[Int(indexOfPage)].weather_state_name!
                    
                    let url = ApiConfig.apiURL + ApiConfig.imageApi + ((self.tempWather.consolidated_weather?[Int(indexOfPage)].weather_state_abbr!)!) + ".png"
                    if Services.shared.imageCache.image(withIdentifier: ((self.tempWather.consolidated_weather?[Int(indexOfPage)].weather_state_abbr!)!)) == nil{
                        self.background {
                            Alamofire.request(url,method: .get, encoding: JSONEncoding.default).validate(statusCode: 200..<300).validate()
                                .responseImage { response in
                                    switch response.result{
                                    case .success:
                                        self.main {
                                            self.stateImageView.image = response.result.value!.imageWithColor(color1: UIColor.init(rgb: 0xffffff))
                                            Services.shared.imageCache.add(response.result.value!, withIdentifier: ((self.tempWather.consolidated_weather?[Int(indexOfPage)].weather_state_abbr!)!))
                                        }
                                        
                                    case .failure(let error):
                                        self.showErrorAlert(self, "Error getting images, error description: \(error.localizedDescription)")
                                    }
                            }
                        }
                    }else{
                        self.stateImageView.image  = Services.shared.imageCache.image(withIdentifier: ((self.tempWather.consolidated_weather?[Int(indexOfPage)].weather_state_abbr!)!))!.imageWithColor(color1: UIColor.init(rgb: 0xffffff))
                    }
                    UIView.animate(withDuration: 0.35
                        , animations: {
                            self.starsAndCloudsView.alpha = 1
                            self.weatherAnimationView.alpha = 1
                            self.stateImageView.alpha = 1
                            self.temperatureLabel.alpha = 1
                            self.stateLabel.alpha = 1
                    })
                }
                var toColors: [CGColor]!
                if cityCurrentDate > (self.tempWather.sun_rise!.toDate()?.date)! && cityCurrentDate < (self.tempWather.sun_set?.toDate()?.date)!{
                    switch ((self.tempWather.consolidated_weather?[Int(indexOfPage)].weather_state_abbr!)!){
                    case "c":
                        toColors = [UIColor.init(rgb: 0x00d5e).cgColor, UIColor.init(rgb: 0x00d5e8).cgColor, UIColor.init(rgb: 0xef73e).cgColor]
                        break
                    case "lc", "lr", "s", "sl":
                        toColors = [UIColor.init(rgb: 0x265e7b).cgColor, UIColor.init(rgb: 0x9cc0d3).cgColor]
                        break
                    case "hc", "hr", "t", "h":
                        toColors = [UIColor.init(rgb: 0x3e5f68).cgColor, UIColor.init(rgb: 0x303d43).cgColor]
                        break
                    case "sn":
                        toColors = [UIColor.init(rgb: 0x9f9f9f).cgColor, UIColor.init(rgb: 0x445157).cgColor]
                        break
                    default:
                        toColors = [UIColor.init(rgb: 0x00d5e).cgColor, UIColor.init(rgb: 0x00d5e8).cgColor, UIColor.init(rgb: 0xef73e).cgColor]
                        break
                    }
                }else{
                    switch ((self.tempWather.consolidated_weather?[Int(indexOfPage)].weather_state_abbr!)!){
                    case "c":
                        toColors = [UIColor.init(rgb: 0x14264a).cgColor, UIColor.init(rgb: 0x0b4969).cgColor]
                        break
                    case "lc", "lr", "s", "sl":
                        toColors = [UIColor.init(rgb: 0x274352).cgColor, UIColor.init(rgb: 0x455c67).cgColor]
                        break
                    case "hc", "hr", "t", "h":
                        toColors = [UIColor.init(rgb: 0x264852).cgColor, UIColor.init(rgb: 0x202d36).cgColor]
                        break
                    case "sn":
                        toColors = [UIColor.init(rgb: 0x5a5a5a).cgColor, UIColor.init(rgb: 0x262d31).cgColor]
                        break
                    default:
                        toColors = [UIColor.init(rgb: 0x14264a).cgColor, UIColor.init(rgb: 0x0b4969).cgColor]
                        break
                    }
                }
                
                let grAnimation = CABasicAnimation(keyPath: "colors")
                grAnimation.fromValue = fromColors
                grAnimation.toValue = toColors
                grAnimation.duration = 1.0
                grAnimation.isRemovedOnCompletion = false
                grAnimation.fillMode = .both
                grAnimation.timingFunction = CAMediaTimingFunction.init(name: .linear)
                self.gradient?.add(grAnimation, forKey: nil)
                self.fromColors = toColors
            }
        }
    }
}



// MARK: DRAGGEDVIEW
extension WeatherVC: UITableViewDelegate, UITableViewDataSource{
    
    
    @objc func draggedView(_ sender: UIPanGestureRecognizer){
        self.view.bringSubviewToFront(draggableView)
        let translation = sender.translation(in: self.view)
        if UIDevice.current.orientation.isPortrait {
            self.draggableViewBottomConstraint.constant = self.draggableViewBottomConstraint.constant - translation.y
        } else {
            self.draggableViewBottomConstraintLandscape.constant = self.draggableViewBottomConstraintLandscape.constant - translation.y
        }
        if translation.y != 0.0{
            self.transY = Double(translation.y)
        }
        
        if sender.state == .ended {
            if self.transY <= 0{
                UIView.animate(withDuration: 0.3) {
                    if UIDevice.current.orientation.isPortrait {
                        self.draggableViewBottomConstraint.constant = 400
                    }else{
                        self.draggableViewBottomConstraintLandscape.constant = 300
                    }
                    self.view.layoutIfNeeded()
                }
            }else{
                UIView.animate(withDuration: 0.3) {
                    if UIDevice.current.orientation.isPortrait {
                        self.draggableViewBottomConstraint.constant = 60
                    }else{
                        self.draggableViewBottomConstraintLandscape.constant = 40
                    }
                    self.view.layoutIfNeeded()
                }
            }
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == (self.cities.count){
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "AddCityTVC") as? AddCityTVC else{return UITableViewCell()}
            cell.selectionStyle = .none
            return cell
        }else{
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "CityChooseTVC") as? CityChooseTVC else{return UITableViewCell()}
            cell.cityNameLabel.text = Array(self.cities.keys)[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == self.cities.count{
            self.showAlertWithTextField(self)
        }else{
            if NetworkState.isConnected() {
                self.getDataFor(self.cities[Array(self.cities.keys)[indexPath.row]]!)
            }
        }
        
    }
}


// MARK: APICALL
extension WeatherVC{
    func getDataFor(_ woeid: String){
        Services.shared.getDetailsForWOEID(woeid)
        Services.shared.onCompleteGetDetailsForWOEID = { success, error, result in
            self.didFinishGettingDetailsForWOEID(woeid, success, error, result)
        }
    }
    
    func didFinishGettingDetailsForWOEID(_ woeid: String,_ success: Bool!,_ error: Error?,_ result: Data?){
        if success{
            guard let result = result else{
                if error != nil{
                    self.showErrorAlert(self, "General Error, error description: \(error!.localizedDescription)")
                }
                return
            }
            do{
                let jsonResult = try JSONDecoder().decode(Weather.self, from: result)
                for e in self.elements{
                    if e.keys.contains(woeid){
                        self.elements = self.elements.filter(){$0 != e}
                        break
                    }
                }
                self.elements.append([woeid:jsonResult])
                self.changeMainViewToDesiredWOEID(woeid)
            }
            catch {
                self.showErrorAlert(self, "Desired WOEID is not found, or your connection appears to be offline!")
            }
        }else{
            self.showErrorAlert(self, "Desired WOEID is not found, or your connection appears to be offline!")
        }
    }
}


// MARK: ANIMATION
extension WeatherVC{
    func animate(_ weather_state_abbr: String?){
        self.weatherAnimationView.initWeather()
        var weather: URWeatherType!
        
        switch weather_state_abbr {
        case "c":
            if Date() > (self.tempWather.sun_rise!.toDate()?.date)! && Date() < (self.tempWather.sun_set?.toDate()?.date)!{
                weather = .hot
                self.weatherAnimationView.startWeatherSceneBulk(weather)
                self.generateStarsAndClouds("cc")
            }else{
                self.generateStarsAndClouds(weather_state_abbr)
            }
            
            break
            
        case "s", "lr", "h", "sl","hr":
            self.generateStarsAndClouds(weather_state_abbr)
            weather = .rain
            let sceneSize: CGSize = self.weatherAnimationView.weatherSceneSize
            self.weatherAnimationView.weatherGroundEmitterOptions = [URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.290, y: sceneSize.height * 0.572)),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.237, y: sceneSize.height * 0.530)),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.188, y: sceneSize.height * 0.484)),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.101, y: sceneSize.height * 0.475), rangeRatio: 0.042),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.752, y: sceneSize.height * 0.748), rangeRatio: 0.094, degree: -27.0),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.829, y: sceneSize.height * 0.602), rangeRatio: 0.094, degree: -27.0),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.663, y: sceneSize.height * 0.556), rangeRatio: 0.078, degree: -27.0)]
            
            self.weatherAnimationView.startWeatherSceneBulk(weather)
            if weather_state_abbr == "hr"{
                self.weatherAnimationView.birthRate = 900
            }else if weather_state_abbr == "lr"{
                self.weatherAnimationView.birthRate = 100
            }else{
                self.weatherAnimationView.birthRate = 250
            }
            
            break
            
        case "t":
            self.generateStarsAndClouds(weather_state_abbr)
            weather = .lightning
            self.weatherAnimationView.startWeatherSceneBulk(weather)
            break
        case "sn":
            self.generateStarsAndClouds(weather_state_abbr)
            weather = .snow
            let sceneSize: CGSize = self.weatherAnimationView.weatherSceneSize
            self.weatherAnimationView.weatherGroundEmitterOptions = [URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.290, y: sceneSize.height * 0.572)),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.237, y: sceneSize.height * 0.530)),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.188, y: sceneSize.height * 0.484)),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.101, y: sceneSize.height * 0.475), rangeRatio: 0.042),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.752, y: sceneSize.height * 0.748), rangeRatio: 0.094, degree: -27.0),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.829, y: sceneSize.height * 0.602), rangeRatio: 0.094, degree: -27.0),
                                                                     URWeatherGroundEmitterOption(position: CGPoint(x: sceneSize.width * 0.663, y: sceneSize.height * 0.556), rangeRatio: 0.078, degree: -27.0)]
            self.weatherAnimationView.startWeatherSceneBulk(weather)
            
            break
        case "hc", "lc":
            self.weatherAnimationView.stopWeatherScene()
            self.generateStarsAndClouds(weather_state_abbr)
            break
            
        default:
            weather = .none
            self.generateStarsAndClouds(weather_state_abbr)
            self.weatherAnimationView.startWeatherSceneBulk(weather)
            break
        }
        
        self.weatherAnimationView.play()
    }
    
    
    func generateStarsAndClouds(_ weather_state_abbr: String?){
        self.starsAndCloudsView.subviews.forEach({ $0.removeFromSuperview() })
        switch weather_state_abbr {
        case "c":
            for i in 0..<3{
                let subview = UIView.init(frame: self.starsAndCloudsView.bounds)
                subview.backgroundColor = .clear
                switch i{
                case 0:
                    subview.alpha = 0.2
                    break
                case 1:
                    subview.alpha = 0.5
                    break
                case 2:
                    subview.alpha = 0.9
                    break
                default:
                    subview.alpha = 1
                    break
                }
                
                for _ in 0..<100{
                    let starView = UIImageView()
                    let width = Int.random(in: 1 ..< 10)
                    let star = "*".image(size: CGSize.init(width: width, height: width))?.imageWithColor(color1: UIColor.init(rgb: 0xffffff))
                    starView.frame = CGRect.init(x: Int.random(in: 0..<Int(self.view.frame.width)), y: Int.random(in: 0..<Int(self.view.frame.height)), width: width, height: width)
                    starView.image = star
                    subview.addSubview(starView)
                }
                self.starsAndCloudsView.addSubview(subview)
            }
            break
            
        case "hc", "lc":
            var maxCloudCount: Int! = 0
            var minCloudCount: Int! = 0
            switch weather_state_abbr{
            case "hc":
                minCloudCount = 3
                maxCloudCount = 7
                break
            case "lc":
                minCloudCount = 1
                maxCloudCount = 3
                break
            default:
                break
            }
            
            for _ in minCloudCount...maxCloudCount{
                let width = Int.random(in: 100 ..< Int(self.view.frame.width/2))
                let cloudView = UIImageView(frame: CGRect.init(x: Int.random(in: 0..<Int(Int(self.view.frame.width) - width)), y: Int.random(in: 0..<Int(self.view.frame.height/3)), width: width, height: width))
                let imageNum = Int.random(in: 1...2)
                cloudView.image = UIImage.init(named: "cloud\(imageNum)")
                cloudView.alpha = CGFloat(Double.random(in: 0.7...0.9))
                self.starsAndCloudsView.addSubview(cloudView)
                self.animateClouds(cloudView)
            }
            break
        default:
            break
        }
    }
    
    func animateClouds(_ cloud: UIImageView){
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = [cloud.frame.origin.x, cloud.frame.origin.y]
        animation.toValue = [Int.random(in: 0..<Int(self.starsAndCloudsView.frame.width)), cloud.frame.origin.y]
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        animation.duration = CFTimeInterval(Int.random(in: 5..<9))
        cloud.layer.add(animation, forKey: nil)
    }
}


// MARK: ALERTS & ERRORS
extension WeatherVC{
    func showNotReachable(_ controller: UIViewController) {
        let alert = UIAlertController(title: "Offline!", message: "Your connection appears to be ofline and you do not have any previous data! Please try again", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: { _ in
            if NetworkState.isConnected() {
                self.getDataFor(self.cities[self.lastCity]!)
            }else{
                if OfflineDB.store.load("lastWeather") != nil{
                    self.elements.append([self.cities[self.lastCity]!:OfflineDB.store.decode(OfflineDB.store.load("lastWeather")!)])
                    self.changeMainViewToDesiredWOEID(self.cities[self.lastCity]!)
                }else{
                    self.showNotReachable(self)
                }
            }
        }))
        
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithTextField(_ controller: UIViewController) {
        let alertController = UIAlertController(title: "Add new city WOEID", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let woeid = txtField.text {
                self.getDataFor(woeid)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "WOEID"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(_ controller: UIViewController, _ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            
        }))
        controller.present(alert, animated: true, completion: nil)
    }
}
