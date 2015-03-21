//
//  ModuleA_SettingsViewController.swift
//  TeamBEN-A4-ObjC
//
//  Created by Nicole Sliwa on 3/20/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

import UIKit

class ModuleA_SettingsViewController: UIViewController {

    @IBOutlet weak var switchWinkAction: UISwitch!
    @IBOutlet weak var switchBlinkAction: UISwitch!
    @IBOutlet weak var switchSmileEffect: UISwitch!
    @IBOutlet weak var switchFaceIdentification: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let smileEffectSetting = defaults.boolForKey("smileEffectEnabled") as Bool? {
            switchSmileEffect.on = smileEffectSetting
        } else { switchSmileEffect.on = true }
        
        if let faceIdentificationSetting = defaults.boolForKey("faceIdentificationEnabled") as Bool? {
            switchFaceIdentification.on = faceIdentificationSetting
        } else { switchFaceIdentification.on = true }
        
        if let winkActionSetting = defaults.boolForKey("winkActionEnabled") as Bool? {
            switchWinkAction.on = winkActionSetting
        } else { switchWinkAction.on = true }
        
        if let blinkActionSetting = defaults.boolForKey("blinkActionEnabled") as Bool? {
            switchBlinkAction.on = blinkActionSetting
        } else { switchBlinkAction.on = true }

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UpdateSettings" {
            // Potentially do stuff
        }
    }
    
    @IBAction func winkActionToggled(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(switchWinkAction.on, forKey: "winkActionEnabled")
        
        NSLog("wink UI: %d | setting: %d", Int(switchWinkAction.on), Int(defaults.boolForKey("winkActionEnabled")))
        
    }
    
    @IBAction func blinkActionToggled(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(switchBlinkAction.on, forKey: "blinkActionEnabled")
        
        NSLog("blink UI: %d | setting: %d", Int(switchBlinkAction.on), Int(defaults.boolForKey("blinkActionEnabled")))
        
    }
    
    @IBAction func smileEffectToggled(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(switchSmileEffect.on, forKey: "smileEffectEnabled")
        
        NSLog("smile UI: %d | setting: %d", Int(switchSmileEffect.on), Int(defaults.boolForKey("smileEffectEnabled")))
        
    }
    
    @IBAction func faceIdentificationToggled(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(switchFaceIdentification.on, forKey: "faceIdentificationEnabled")
        
        NSLog("face UI: %d | setting: %d", Int(switchFaceIdentification.on), Int(defaults.boolForKey("faceIdentificationEnabled")))
        
    }

}
