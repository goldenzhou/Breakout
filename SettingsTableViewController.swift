//
//  SettingsTableViewController.swift
//  Breakout
//
//  Created by Liuyu Zhou on 2/26/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var Title: UILabel!
    
       @IBOutlet weak var GravitySwitch: UISwitch!
    
    @IBOutlet weak var GravityText: UILabel!
    
    @IBOutlet weak var BrickText: UILabel!
    
    @IBOutlet weak var BrickStepper: UIStepper!
    
    @IBAction func BrickChanged(sender: UIStepper) {
        BrickText.text = Int(sender.value).description
    }
    func stateChanged(switchState: UISwitch) {
        if switchState.on {
            GravityText.text = "Gravity On"
            println("Gravity on")
        } else {
            GravityText.text = "Gravity Off"
            println("Gravity off")

        }
    }
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var SliderText: UILabel!
    
    @IBAction func SliderChanged(sender: UISlider) {
        var currentValue = sender.value
        
        SliderText.text = "\(currentValue)"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Title.text = "Game Settings"
        GravityText.text = "Gravity On"
        BrickText.text = "10"
        SliderText.text = "0.5"
        GravitySwitch.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        BrickStepper.wraps = true
        BrickStepper.autorepeat = true
        BrickStepper.maximumValue = 10
        
        BallNumber.wraps = true
        BallNumber.autorepeat = true
        BallNumber.maximumValue = 5
        BallNumberText.text = "1"
        
    }
    
    
    @IBOutlet weak var BallNumberText: UILabel!
    
    @IBOutlet weak var BallNumber: UIStepper!

    
    @IBAction func BallNumberChanged(sender: UIStepper) {
        BallNumberText.text = Int(sender.value).description

    }

}
