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
    
//        @IBOutlet weak var flashSlider: UISlider!
        var videoManager : VideoAnalgesic! = nil
        var filters = [CIFilter]()
        let filter :CIFilter = CIFilter(name: "CIBumpDistortion")
    
    
//        @IBAction func panRecognized(sender: AnyObject) {
//            let point = sender.translationInView(self.view)
//    
//            var swappedPoint = CGPoint()
//    
//            // convert coordinates from UIKit to core image
//            var transform = CGAffineTransformIdentity
//            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(CGFloat(M_PI_2)))
//            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(-1.0, 1.0))
//            transform = CGAffineTransformTranslate(transform, self.view.bounds.size.width/2,
//                self.view.bounds.size.height/2)
//    
//            swappedPoint = CGPointApplyAffineTransform(point, transform);
//    
//            filter.setValue(CIVector(CGPoint: swappedPoint), forKey: "inputCenter")
//    
//        }
    
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.
            //CIDetectorTracking:,CIDetectorMinFeatureSize:
    
            self.view.backgroundColor = nil
    
            self.videoManager = VideoAnalgesic.sharedInstance
            self.videoManager.setCameraPosition(AVCaptureDevicePosition.Back)
    
//            self.filter.setValue(-0.5, forKey: "inputScale")
            filter.setValue(5.0, forKey: "inputRadius")
//            filter.setValue(1.0, forKey: "inputIntensity")
    
            let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow]
    
            let detector = CIDetector(ofType: CIDetectorTypeFace,
                context: self.videoManager.getCIContext(),
                options: optsDetector)
    
            var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]
    
            self.videoManager.setProcessingBlock( { (imageInput) -> (CIImage) in
    
                var features = detector.featuresInImage(imageInput, options: optsFace)
                var swappedPoint = CGPoint()
                var img = imageInput
                var point0 = CGPoint()
                var point1 = CGPoint()
                
                for f in features as [CIFaceFeature]{
                    NSLog("%@",f)
                    swappedPoint.x = f.bounds.midX
                    swappedPoint.y = f.bounds.midY
                    
//                    point1.x = f.bounds.maxX
//                    point1.y = f.bounds.maxY
                    
                    self.filter.setValue(CIVector(CGPoint: swappedPoint), forKey: "inputCenter")
//                    self.filter.setValue(CIVector(CGPoint: point1), forKey: "inputPoint1")
                    self.filter.setValue(f.bounds.width / 2, forKey: "inputRadius")
//                    self.filter.setValue(0, forKey: "inputRadius")
                    self.filter.setValue(img, forKey: kCIInputImageKey)
                    img = self.filter.outputImage
                }
    
                NSLog("next image")
                
                self.filter.setValue(img, forKey: kCIInputImageKey)
                return self.filter.outputImage
            })

    
    
            self.videoManager.start()
        }
    
    func addFaceFilter(var center:CGPoint, width:CGFloat, image:CIImage) -> CIImage {
        let filter2 :CIFilter = CIFilter(name: "CIBumpDistortion")
        filter2.setValue(-0.5, forKey: "inputScale")
        filter2.setValue(75, forKey: "inputRadius")
        
        filter2.setValue(CIVector(CGPoint: center), forKey: "inputCenter")
//        filter2.setValue(image, forKey: kCIInputImageKey)
        
        return filter2.outputImage
    }
    
//    func addRectangleFromCGRect(var rect: CGRect, view: UIView, color: UIColor) {
////        let translatedRect = CGRectApplyAffineTransform(rect, self.transformToUIKit);
//    
//        let newView = [[UIView alloc] initWithFrame:translatedRect];
//        newView.layer.cornerRadius = 10;
//        newView.alpha = 0.3;
//        newView.backgroundColor = color;
//        [view addSubview:newView];
//    }
//    
//        @IBAction func flash(sender: AnyObject) {
//            if(self.videoManager.toggleFlash()){
//                self.flashSlider.value = 1.0
//            }
//            else{
//                self.flashSlider.value = 0.0
//            }
//        }
//    
//        @IBAction func switchCamera(sender: AnyObject) {
//            self.videoManager.toggleCameraPosition()
//        }
//        
//        @IBAction func setFlashLevel(sender: UISlider) {
//            if(sender.value>0.0){
//                self.videoManager.turnOnFlashwithLevel(sender.value)
//            }
//            else if(sender.value==0.0){
//                self.videoManager.turnOffFlash()
//            }
//        }

    
    
}


//
//  ViewController.swift
//  LookinLive
//
//  Created by Eric Larson on 2/26/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.


//import UIKit
//import AVFoundation
//
//class ViewController: UIViewController {
//    
//    @IBOutlet weak var flashSlider: UISlider!
//    var videoManager : VideoAnalgesic! = nil
//    let filter :CIFilter = CIFilter(name: "CIBumpDistortion")
//    
//    @IBAction func panRecognized(sender: AnyObject) {
//        let point = sender.translationInView(self.view)
//        
//        var swappedPoint = CGPoint()
//        
//        // convert coordinates from UIKit to core image
//        var transform = CGAffineTransformIdentity
//        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(CGFloat(M_PI_2)))
//        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(-1.0, 1.0))
//        transform = CGAffineTransformTranslate(transform, self.view.bounds.size.width/2,
//            self.view.bounds.size.height/2)
//        
//        swappedPoint = CGPointApplyAffineTransform(point, transform);
//        
//        filter.setValue(CIVector(CGPoint: swappedPoint), forKey: "inputCenter")
//        
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        //CIDetectorTracking:,CIDetectorMinFeatureSize:
//        
//        self.view.backgroundColor = nil
//        
//        self.videoManager = VideoAnalgesic.sharedInstance
//        self.videoManager.setCameraPosition(AVCaptureDevicePosition.Back)
//        
//        self.filter.setValue(-0.5, forKey: "inputScale")
//        filter.setValue(75, forKey: "inputRadius")
//        
//        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow]
//        
//        let detector = CIDetector(ofType: CIDetectorTypeFace,
//            context: self.videoManager.getCIContext(),
//            options: optsDetector)
//        
//        var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation)]
//        
//        self.videoManager.setProcessingBlock( { (imageInput) -> (CIImage) in
//            
//            var features = detector.featuresInImage(imageInput, options: optsFace)
//            var swappedPoint = CGPoint()
//            for f in features as [CIFaceFeature]{
//                //NSLog("%@",f)
//                swappedPoint.x = f.bounds.midX
//                swappedPoint.y = f.bounds.midY
//                self.filter.setValue(CIVector(CGPoint: swappedPoint), forKey: "inputCenter")
//            }
//            
//            
//            self.filter.setValue(imageInput, forKey: kCIInputImageKey)
//            return self.filter.outputImage
//        })
//        
//        self.videoManager.start()
//    }
//    
//    @IBAction func flash(sender: AnyObject) {
//        if(self.videoManager.toggleFlash()){
//            self.flashSlider.value = 1.0
//        }
//        else{
//            self.flashSlider.value = 0.0
//        }
//    }
//    
//    @IBAction func switchCamera(sender: AnyObject) {
//        self.videoManager.toggleCameraPosition()
//    }
//    
//    @IBAction func setFlashLevel(sender: UISlider) {
//        if(sender.value>0.0){
//            self.videoManager.turnOnFlashwithLevel(sender.value)
//        }
//        else if(sender.value==0.0){
//            self.videoManager.turnOffFlash()
//        }
//    }
//}
//
