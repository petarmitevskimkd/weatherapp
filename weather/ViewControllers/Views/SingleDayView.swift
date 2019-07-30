//
//  SingleDayView.swift
//  weather
//
//  Created by Telekom MK on 7/23/19.
//  Copyright © 2019 petar. All rights reserved.
//

import UIKit

class SingleDayView: UIView {

    var view: UIView!
    
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirectionImageView: UIImageView!
    @IBOutlet weak var sunRiseLabel: UILabel!
    @IBOutlet weak var sunSetLabel: UILabel!
    @IBOutlet weak var centarSeparator: UIView!
    @IBOutlet weak var predictabilityImageView: UIImageView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    func initializeSubviews() {
        let xibFileName = "SingleDayView"
        self.view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)![0] as? UIView
        self.view.frame = self.bounds
        self.containerView.layer.cornerRadius = 30
        self.centarSeparator.layer.cornerRadius = 1
        self.addSubview(self.view)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 30
    }

}
