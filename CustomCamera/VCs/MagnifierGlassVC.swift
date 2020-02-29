//
//  MagnifierGlassVC.swift
//  Busy Shift
//
//  Created by Dushan Saputhanthri on 10/20/16.
//  Copyright © 2016 Dushan Saputhanthri. All rights reserved.
//

import UIKit
import AVFoundation

class MagnifierGlassVC: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var magnifierScrollView: UIScrollView!
    @IBOutlet weak var magnifierView: UIView!
    @IBOutlet weak var controlPanelView: UIView!
    @IBOutlet weak var flashOnOffButton: UIButton!
    @IBOutlet weak var zoomController: UISlider!
    
    let device = AVCaptureDevice.default(for: AVMediaType.video)
    
    let offImage = #imageLiteral(resourceName: "flash")
    let onImage = #imageLiteral(resourceName: "flash_active")
    
    var captureSession = AVCaptureSession()
    var sessionOutput = AVCapturePhotoOutput()
    var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        magnifierScrollView.delegate = self
        
        setZoomScale()
        setupGestureRecognizer()
        
        zoomController.value = Float(magnifierScrollView.zoomScale)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInDualCamera, AVCaptureDevice.DeviceType.builtInTelephotoCamera,AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        for device in (deviceDiscoverySession.devices) {
            
            if(device.position == AVCaptureDevice.Position.back) {
                
                do{
                    let input = try AVCaptureDeviceInput(device: device)
                    if(captureSession.canAddInput(input)){
                        captureSession.addInput(input)
                        
                        if(captureSession.canAddOutput(sessionOutput)){
                            captureSession.addOutput(sessionOutput)
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                            magnifierView.layer.addSublayer(previewLayer)
                            
                            captureSession.startRunning()
                        }
                    }
                }
                catch {
                    flashOnOffButton.isEnabled = false
                    zoomController.isEnabled = false
                    AlertProvider(vc: self).showAlert(title: "Alert", message: "No camera permission", action: AlertAction(title: "Dismiss"))
                }
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = magnifierView.bounds
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return magnifierView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let cameraViewSize = magnifierView.frame.size
        let scrollViewSize = magnifierScrollView.bounds.size
        
        let verticalPadding = cameraViewSize.height < scrollViewSize.height ? (scrollViewSize.height - cameraViewSize.height) / 2 : 0
        let horizontalPadding = cameraViewSize.width < scrollViewSize.width ? (scrollViewSize.width - cameraViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        
        zoomController.value = Float(magnifierScrollView.zoomScale)
    }

    //MARK: Set zooming scale
    func setZoomScale() {
        
        let magnifierViewSize = magnifierView.bounds.size
        let magnifierScrollViewSize = magnifierScrollView.bounds.size
        let widthScale = magnifierScrollViewSize.width / magnifierViewSize.width
        let heightScale = magnifierScrollViewSize.height / magnifierViewSize.height
        
        magnifierScrollView.minimumZoomScale = min(widthScale, heightScale)
        magnifierScrollView.zoomScale = 3.0
        magnifierScrollView.maximumZoomScale = 5.0
    }
    
    //MARK: Setup gestures on scrollView
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        magnifierScrollView.addGestureRecognizer(doubleTap)
    }
    
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        
        if (magnifierScrollView.zoomScale > magnifierScrollView.minimumZoomScale) {
            magnifierScrollView.setZoomScale(magnifierScrollView.minimumZoomScale, animated: true)
        } else {
            magnifierScrollView.setZoomScale(magnifierScrollView.maximumZoomScale, animated: true)
        }
    }
    
    //MARK: Control zooming
    @IBAction func controlZooming(_ sender: UISlider) {
        
        magnifierScrollView.zoomScale = CGFloat(zoomController.value)
    }
    
    //MARK: Use this to handle mangnifier fucntions, features when app goes background
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        
        closeMagnifier()
    }
    
    @IBAction func flashOnOff(_ sender: AnyObject) {
        
        flashLightOnOff()
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        
        closeMagnifier()

        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Turn on/off flash light
    func flashLightOnOff() {
        
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == .on) {
                    
                    device?.torchMode = .off
                    flashOnOffButton.setImage(offImage, for: UIControl.State())
                    
                } else {
                    try device?.setTorchModeOn(level: 1.0)
                    flashOnOffButton.setImage(onImage, for: UIControl.State())
                }
                
                device?.unlockForConfiguration()
                
            } catch {
                print(error)
            }
        } else {
            AlertProvider(vc: self).showAlert(title: "Alert", message: "No flash light", action: AlertAction(title: "Dismiss"))
        }
    }
    
    //MARK: Close magnifier
    func closeMagnifier() {
        
        flashOnOffButton.setImage(offImage, for: UIControl.State())
        
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                
                if (device?.torchMode == .on) {
                    
                    device?.torchMode = .off
                }
                
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        } else {
            print("Flash already off")
        }
    }
    
}
