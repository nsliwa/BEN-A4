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
        self.videoManager.setCameraPosition(AVCaptureDevicePosition.Front)
        
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow]
        
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: self.videoManager.getCIContext(), options: optsDetector)
        
        var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]
        
        /*
        self.videoManager.setProcessingBlock({(imageInput) -> (CIImage) in
        
        var features = detector.featuresInImage(imageInput, options: optsFace)
        var swappedPoint = CGPoint()
        for f in features as [CIFaceFeature]{
        swappedPoint.x = f.bounds
        }
        
        }
        */
        
        self.videoManager.start()
    }
    
    
    
}