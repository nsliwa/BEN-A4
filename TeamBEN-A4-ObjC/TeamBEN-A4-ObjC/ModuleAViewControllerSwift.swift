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
    
    let filter :CIFilter = CIFilter(name: "CIBumpDistortion")
    let leftEyeFilter :CIFilter = CIFilter(name: "CIRadialGradient")
    let rightEyeFilter :CIFilter = CIFilter(name: "CIRadialGradient")
    let mouthFilter :CIFilter = CIFilter(name: "CIRadialGradient")
    let blendFilter :CIFilter = CIFilter(name: "CIOverlayBlendMode")
    let gloomFilter :CIFilter = CIFilter(name: "CIGloom")//"CIPinchDistortion")
    let bloomFilter :CIFilter = CIFilter(name: "CIBloom")
    
    var smileEffectEnabled :Bool!
    var faceIdentificationEnabled :Bool!
    var featureIdentificationEnabled :Bool!
    var winkActionEnabled :Bool!
    var blinkActionEnabled :Bool!
    
    var filterRadius :Float = 0.5
    
    var flashToggled = false
    var pictureTaken = false
    var eyesClosedCounter = 0
    
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
        
        var defaultDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("UserDefaults", ofType: "plist") {
            defaultDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = defaultDict {
            NSUserDefaults.standardUserDefaults().registerDefaults(dict)
        }
        
        leftEyeFilter.setValue(CIColor(CGColor: UIColor.clearColor().CGColor), forKey: "inputColor1")
        rightEyeFilter.setValue(CIColor(CGColor: UIColor.clearColor().CGColor), forKey: "inputColor1")
        mouthFilter.setValue(CIColor(CGColor: UIColor.clearColor().CGColor), forKey: "inputColor1")
        
        leftEyeFilter.setValue(5, forKey: "inputRadius0")
        rightEyeFilter.setValue(5, forKey: "inputRadius0")
        mouthFilter.setValue(5, forKey: "inputRadius0")
        
        leftEyeFilter.setValue(CIColor(CGColor: UIColor.redColor().CGColor), forKey: "inputColor0")
        rightEyeFilter.setValue(CIColor(CGColor: UIColor.blueColor().CGColor), forKey: "inputColor0")
        mouthFilter.setValue(CIColor(CGColor: UIColor.greenColor().CGColor), forKey: "inputColor0")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Pull initial User Defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        if let smileEffectSetting = defaults.boolForKey("smileEffectEnabled") as Bool? {
            smileEffectEnabled = smileEffectSetting
        } else { smileEffectEnabled = true }
        
        if let faceIdentificationSetting = defaults.boolForKey("faceIdentificationEnabled") as Bool? {
            faceIdentificationEnabled = faceIdentificationSetting
        } else { faceIdentificationEnabled = true }
        
        if let featureIdentificationSetting = defaults.boolForKey("featureIdentificationEnabled") as Bool? {
            featureIdentificationEnabled = featureIdentificationSetting
        } else { featureIdentificationEnabled = true }
        
        if let winkActionSetting = defaults.boolForKey("winkActionEnabled") as Bool? {
            winkActionEnabled = winkActionSetting
        } else { winkActionEnabled = true }
        
        if let blinkActionSetting = defaults.boolForKey("blinkActionEnabled") as Bool? {
            blinkActionEnabled = blinkActionSetting
        } else { blinkActionEnabled = true }
        
        // Feature detector settings
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow, CIDetectorTracking:true]
        
        let detector = CIDetector(ofType: CIDetectorTypeFace,
            context: self.videoManager.getCIContext(),
            options: optsDetector)
        
        self.videoManager.setProcessingBlock( { (imageInput) -> (CIImage) in
            var optsFace = [CIDetectorImageOrientation:self.videoManager.getImageOrientationFromUIOrientation(UIApplication.sharedApplication().statusBarOrientation),
                CIDetectorSmile:true, CIDetectorEyeBlink:true]
            
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
            
            var leftBlinkIds = [Int: Bool]()
            var rightBlinkIds = [Int: Bool]()
            
            for f in features as [CIFaceFeature]{
                numFeatures++
                
                var eyeStatus = "None"
                
                var hasSmile = f.hasSmile ? true : false
                var hasLeftEye = f.hasLeftEyePosition ? true : false
                var hasRightEye = f.hasRightEyePosition ? true : false
                var hasLeftEyeBlink = f.leftEyeClosed ? true : false
                var hasRightEyeBlink = f.rightEyeClosed ? true : false
                
                if(hasLeftEyeBlink && hasRightEyeBlink && hasRightEye && hasLeftEye) {
                    eyeStatus = "Closed"
                    eyesClosed = true
                }
                else if( hasRightEye && hasLeftEye && !hasLeftEyeBlink && !hasRightEyeBlink ){
                    eyeStatus = "Open"
                }
                
                if(hasRightEyeBlink && !hasLeftEyeBlink){
                    rightBlinked = true
                }
                
                if(hasSmile){
                    numSmiles++
                }
//
//                if(hasLeftEyeBlink && !hasRightEyeBlink){
//                    if(leftBlinkIds[Int(f.trackingID)] == nil || leftBlinkIds[Int(f.trackingID)] == false) {
//                        leftBlinkIds[Int(f.trackingID)] = true
//                        leftBlinked = true
//                    }
//                }
//                else {
//                    leftBlinkIds[Int(f.trackingID)] = false
//                }
//
//                if(hasRightEyeBlink && !hasLeftEyeBlink){
//                    if(rightBlinkIds[Int(f.trackingID)] == nil || rightBlinkIds[Int(f.trackingID)] == false) {
//                        rightBlinkIds[Int(f.trackingID)] = true
//                        rightBlinked = true
//                    }
//                }
//                else {
//                    rightBlinkIds[Int(f.trackingID)] = false
//                }
//
//
//                NSLog("%d", f.hasSmile)
                
                if(self.faceIdentificationEnabled!) {
                    NSLog("ID: %d, Smile: %@, Eyes: %@",f.trackingID, hasSmile, eyeStatus)
                    swappedPoint.x = f.bounds.midX
                    swappedPoint.y = f.bounds.midY
                    
//                    point1.x = f.bounds.maxX
//                    point1.y = f.bounds.maxY
                    var radius = Float(f.bounds.width) * self.filterRadius
                    
                    self.filter.setValue(CIVector(CGPoint: swappedPoint), forKey: "inputCenter")
                    self.filter.setValue(radius, forKey: "inputRadius")
                    
                }
                
                if(self.featureIdentificationEnabled!) {
            
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
                     NSLog("left: %d | right: %d | missing: %d", Int(hasLeftEyeBlink), Int(hasRightEyeBlink), Int(!hasLeftEye | !hasRightEye) )
                    
                }
                
                if(self.faceIdentificationEnabled!) {
                    self.filter.setValue(img, forKey: kCIInputImageKey)
                    img = self.filter.outputImage
                    
                }
               
//                NSLog("mouth: %@ | left: %@ | right: %@", NSStringFromCGPoint(mouthPoint), NSStringFromCGPoint(leftEyePoint), NSStringFromCGPoint(rightEyePoint))
//                NSLog("mouth: %s, %s | left: %s, %s | right: %s, %s", mouthPoint.x, mouthPoint.y, leftEyePoint.x, leftEyePoint.y, rightEyePoint.x, rightEyePoint.y)
                
            }
            
            NSLog("next image, smiles: %d", numSmiles)
            
            if( self.smileEffectEnabled! && numFeatures > 0 ) {
                if(Double(numSmiles) >= (Double(numFeatures)/2.0)){
                    self.bloomFilter.setValue(img, forKey: kCIInputImageKey)
                    img = self.bloomFilter.outputImage
                }else{
                    self.gloomFilter.setValue(img, forKey: kCIInputImageKey)
                    img = self.gloomFilter.outputImage
                }
            }
            
            if( self.winkActionEnabled! ) {
                if(rightBlinked  && !self.pictureTaken){
                    //Take screenshot
                    var viewImage = self.screenshot()
                    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil)
                    self.pictureTaken = true
                }else if(!rightBlinked  && self.pictureTaken){
                    self.pictureTaken = false
                }
            } else { self.pictureTaken = false }
            
            if( self.blinkActionEnabled! ) {
                if(eyesClosed && !self.flashToggled){
                    //Toggle flash
                    self.eyesClosedCounter++
                    if(self.eyesClosedCounter > 4){
                        if(self.videoManager.toggleFlash()){
                            self.videoManager.turnOnFlashwithLevel(0.1)
                        }
                        self.flashToggled = true
                        
                        NSLog("flash toggled")
                    }
                }
                else if(!eyesClosed)
                {
                    self.flashToggled = false
                    self.eyesClosedCounter = 0
                }
            } else {
                    self.flashToggled = false
                    self.eyesClosedCounter = 0
            }
            
            // self.filter.setValue(img, forKey: kCIInputImageKey)
            // return self.filter.outputImage
            return img
        })
        
        
        
        self.videoManager.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.videoManager.stop()
    }
    
//    func takePhoto(){
//        var picker = UIImagePickerController.self
//        picker.delegate = self
//        picker.allowsEditing = YES
//        picker.sourceType = UIImagePickerControllerSourceTypeCamera
//    
//    }

    
    
    func screenshot() -> UIImage
    {
        
        //CGRect rect;
        let rect = CGRectMake(0, 0, 320, 480);
        UIGraphicsBeginImageContext(rect.size);
        
        //CGContextRef context=UIGraphicsGetCurrentContext();
        let context = UIGraphicsGetCurrentContext()
        
        self.view.layer.renderInContext(context)
        
        //[self.view.layer renderInContext:context];
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        //UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    @IBAction func onSliderChanged(sender: UISlider) {
        
        filterRadius = Float(sender.value)
    }
    
    @IBAction func onClickToggleOrientation(sender: AnyObject) {
        
        self.videoManager.toggleCameraPosition()
    }
    
    @IBAction func updateSettings(segue:UIStoryboardSegue) {
        
    }
    
}