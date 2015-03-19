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
        let leftEyeFilter :CIFilter = CIFilter(name: "CIRadialGradient")
        let rightEyeFilter :CIFilter = CIFilter(name: "CIRadialGradient")
        let mouthFilter :CIFilter = CIFilter(name: "CIRadialGradient")
        let blendFilter :CIFilter = CIFilter(name: "CIOverlayBlendMode")
        var flashToggled = false
        var pictureTaken = false
    
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
    
            filter.setValue(5.0, forKey: "inputRadius")
            
            leftEyeFilter.setValue(CIColor(CGColor: UIColor.clearColor().CGColor), forKey: "inputColor1")
            rightEyeFilter.setValue(CIColor(CGColor: UIColor.clearColor().CGColor), forKey: "inputColor1")
            mouthFilter.setValue(CIColor(CGColor: UIColor.clearColor().CGColor), forKey: "inputColor1")
            
            leftEyeFilter.setValue(5, forKey: "inputRadius0")
            rightEyeFilter.setValue(5, forKey: "inputRadius0")
            mouthFilter.setValue(5, forKey: "inputRadius0")
            
            leftEyeFilter.setValue(CIColor(CGColor: UIColor.redColor().CGColor), forKey: "inputColor0")
            rightEyeFilter.setValue(CIColor(CGColor: UIColor.blueColor().CGColor), forKey: "inputColor0")
            mouthFilter.setValue(CIColor(CGColor: UIColor.greenColor().CGColor), forKey: "inputColor0")
    
            let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
    
            let detector = CIDetector(ofType: CIDetectorTypeFace,
                context: self.videoManager.getCIContext(),
                options: optsDetector)
    
            var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation), CIDetectorSmile:true, CIDetectorEyeBlink:true]
    
            self.videoManager.setProcessingBlock( { (imageInput) -> (CIImage) in
    
                var features = detector.featuresInImage(imageInput, options: optsFace)
                var img = imageInput
                
                var swappedPoint = CGPoint()
                
                var leftEyePoint = CGPoint()
                var rightEyePoint = CGPoint()
                var mouthPoint = CGPoint()
                
                var numSmiles = 0
                var numFeatures = 0
                var eyesClosed = false
                var rightBlinked = false
                var leftBlinked = false
                
                for f in features as [CIFaceFeature]{
                    var hasSmile = f.hasSmile ? true : false
                    var eyeStatus = "None"
                    
                    numFeatures++

                    var hasLeftEye = f.hasLeftEyePosition ? true : false
                    var hasRightEye = f.hasRightEyePosition ? true : false
                    var hasLeftEyeBlink = f.leftEyeClosed ? true : false
                    var hasRightEyeBlink = f.rightEyeClosed ? true : false
                    
                    
                    if((hasLeftEye && !hasLeftEyeBlink && hasRightEyeBlink) || (hasRightEye && !hasRightEyeBlink && hasLeftEyeBlink)) {
                        eyeStatus = "Wink"
                    }
                    else if( hasLeftEyeBlink && hasRightEyeBlink ) {
                        eyeStatus = "Closed"
                        eyesClosed = true
                    }
                    else if( hasRightEye && hasLeftEye ){
                        eyeStatus = "Open"
                    }

                    if(hasSmile){
                        numSmiles++
                    }
                    
                    if(hasLeftEyeBlink && !hasRightEyeBlink){
                        leftBlinked = true
                    }

                    if(hasRightEyeBlink && !hasLeftEyeBlink){
                        rightBlinked = true
                    }
                    
//                    NSLog("%d", f.hasSmile)
                    NSLog("Smile: %@, Eyes: %@",hasSmile, eyeStatus)
                    swappedPoint.x = f.bounds.midX
                    swappedPoint.y = f.bounds.midY
                    
//                    point1.x = f.bounds.maxX
//                    point1.y = f.bounds.maxY
                    
                    self.filter.setValue(CIVector(CGPoint: swappedPoint), forKey: "inputCenter")
                    self.filter.setValue(f.bounds.width / 2, forKey: "inputRadius")


                    if(f.hasLeftEyePosition) {
                        leftEyePoint.x = f.leftEyePosition.x
                        leftEyePoint.y = f.leftEyePosition.y
                        self.leftEyeFilter.setValue(CIVector(CGPoint: leftEyePoint), forKey: "inputCenter")
                        self.leftEyeFilter.setValue(10, forKey: "inputRadius1")
                        
                        var backgroundImg :CIImage = self.leftEyeFilter.outputImage
                        
                        self.blendFilter.setValue(img, forKey: kCIInputImageKey)
                        self.blendFilter.setValue(backgroundImg, forKey: kCIInputBackgroundImageKey)
                        img = self.blendFilter.outputImage
                    }
                    
                    if(f.hasRightEyePosition) {
                        rightEyePoint.x = f.rightEyePosition.x
                        rightEyePoint.y = f.rightEyePosition.y
                        self.rightEyeFilter.setValue(CIVector(CGPoint: rightEyePoint), forKey: "inputCenter")
                        self.rightEyeFilter.setValue(10, forKey: "inputRadius1")
//                        self.rightEyeFilter.setValue(UIColor.blueColor().CIColor, forKey: "inputColor1")
                        
                        var backgroundImg :CIImage = self.rightEyeFilter.outputImage
                        
                        self.blendFilter.setValue(img, forKey: kCIInputImageKey)
                        self.blendFilter.setValue(backgroundImg, forKey: kCIInputBackgroundImageKey)
                        img = self.blendFilter.outputImage
                    }
                    
                    if(f.hasMouthPosition) {
                        mouthPoint.x = f.mouthPosition.x
                        mouthPoint.y = f.mouthPosition.y
                        self.mouthFilter.setValue(CIVector(CGPoint: mouthPoint), forKey: "inputCenter")
                        self.mouthFilter.setValue(10, forKey: "inputRadius1")
//                        self.mouthFilter.setValue(UIColor.greenColor().CIColor, forKey: "inputColor1")
                        
                        var backgroundImg :CIImage = self.mouthFilter.outputImage
                        
                        self.blendFilter.setValue(img, forKey: kCIInputImageKey)
                        self.blendFilter.setValue(backgroundImg , forKey: kCIInputBackgroundImageKey)
                        img = self.blendFilter.outputImage
                    }

                    NSLog("mouth: %@ | left: %@ | right: %@", NSStringFromCGPoint(mouthPoint), NSStringFromCGPoint(leftEyePoint), NSStringFromCGPoint(rightEyePoint))
//                    NSLog("mouth: %s, %s | left: %s, %s | right: %s, %s", mouthPoint.x, mouthPoint.y, leftEyePoint.x, leftEyePoint.y, rightEyePoint.x, rightEyePoint.y)
                    
                    
                    
                    self.filter.setValue(img, forKey: kCIInputImageKey)
                    img = self.filter.outputImage
                }
    
                NSLog("next image")
                
                if(numSmiles >= (numFeatures/2)){
                    //Set bloom filter
                }else{
                    //Set gloom filter
                }

                if(rightBlinked  && !self.pictureTaken){
                    //Take screenshot
                    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 1)
                    self.view.layer.renderInContext(UIGraphicsGetCurrentContext())
                    var viewImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext();
                    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil)
                    self.pictureTaken = true
                }else if(!rightBlinked  && self.pictureTaken){
                    self.pictureTaken = false
                }

                if(leftBlinked && !self.flashToggled){
                    //Toggle flash
                    self.videoManager.toggleFlash()
                    self.flashToggled = true
                }else if(!leftBlinked && self.flashToggled){
                    self.flashToggled = false
                }

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
