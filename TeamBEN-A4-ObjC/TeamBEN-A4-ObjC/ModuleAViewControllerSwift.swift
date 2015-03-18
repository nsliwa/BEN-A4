//
//  ModuleAViewControllerSwift.swift
//  TeamBEN-A4-ObjC
//
//  Created by ch484-mac5 on 3/17/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

import UIKit
import AVFoundation

class ModuleAViewControllerSwift: UIViewController {
    
    var videoManager : VideoAnalgesic! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        
        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(AVCaptureDevicePosition.Back)
        
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow]
        
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: self.videoManager.getCIContext(), options: optsDetector)
        
        var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]

        self.videoManager.start()
    }
    
    
    
}