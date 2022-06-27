//
//  ViewController.swift
//  Disposable Camera
//
//  Created by Daniel Feler

import UIKit
import CoreImage
import AVFoundation
import MediaPlayer
import Twinkle
import SafariServices

class ViewController: UIViewController {
    
    var outputVolumeObserve: NSKeyValueObservation?
    let audioSession = AVAudioSession.sharedInstance()
    let imageSave = SaveImages()
    let userDefaults = UserDefaults.standard

    @IBOutlet weak var butterflyButton: UIButton!
    
    @IBOutlet fileprivate var capturePreviewView: UIView!
    @IBOutlet fileprivate var toggleCameraButton: UIButton!
       @IBOutlet weak var outerToggleFlashButton: UIButton!

    @IBAction func butterflyButtonAction(_ sender: UIButton) {
                let passvalue = "key"
                guard let url = URL(string: "https://almastudios.co/camera/"),
                    let value = passvalue.addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed)
                    else { return }
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = "value=\(value)".data(using: .utf8)
                URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data else { return }
                    do {
                        let myData = try JSONDecoder().decode(CheckStruct.self, from:data)
                        DispatchQueue.main.async {
                        if  myData.error == false {
                            let profileValue = myData.profile
                            let appURL = URL(string: "instagram://user?username=\(profileValue)")!
                            print("\(profileValue)")
                            let application = UIApplication.shared
                            if application.canOpenURL(appURL)
                            {
                                application.open(appURL)
                            }
                            else
                            {
                                //No Link
                            }
                        }
                        else {
                            print("No Link")
                        }
                    }
                    }
                    catch {
                        print(error)
                    }
                    }.resume()
                    
    }
    
    
    let cameraController = CameraController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setFlash()
        self.addVolumeButtonToTakePictureFunctionality()
        self.createImageFolder()
        

        }

    
    
    
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft

    }
    override var prefersStatusBarHidden: Bool
       {
               return true
       }
    
    override func viewWillAppear(_ animated: Bool) {
        
        func setCamera()
            {
                self.configureCameraController(orientation: .landscapeRight)
            }
        #if targetEnvironment(simulator)
            self.showMessage(message: "Camera Not Available")
        #else
            setCamera()
        #endif


        NotificationCenter.default.addObserver(self, selector: #selector(volumeDidChange(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)

        
        NotificationCenter.default.addObserver(self, selector: #selector(foreGround), name: Notification.Name("Foreground"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(backGround), name: Notification.Name("Background"), object: nil)
            
    }
    
    @objc func backGround()
    {
        
      NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)

    }
    @objc func foreGround()
    {
        self.addVolumeButtonToTakePictureFunctionality()

    
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            NotificationCenter.default.addObserver(self, selector: #selector(self.volumeDidChange(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        }
       
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
        
        self.cameraController.captureSession?.removeInput(self.cameraController.rearCameraInput!)

    }
    

    
    
    
   
    
    func rotateView()
    {
        self.view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 3/2))
        self.view.bounds = CGRect(x:0,y:0, width:self.view.frame.size.height, height:self.view.frame.size.width)
    }
    
    func addVolumeButtonToTakePictureFunctionality()
    {
        let volumeView = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
              
               
               volumeView.isHidden = false
               volumeView.alpha = 0.01
                volumeView.showsRouteButton = false
                volumeView.showsVolumeSlider = false
        
               
               view.addSubview(volumeView)
               
               
    }
    func showMessage(message: String)
      {
          let alert = UIAlertController(title: "Success", message: message, preferredStyle: UIAlertController.Style.alert)
          alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            //self.present(alert, animated: true, completion: nil)
      }
    func createImageFolder()
    {
         imageSave.createFolderWithName(name: "Images")
    }
    
    func setFlash()
    {
        let flash = userDefaults.object(forKey: "flash")
        if flash == nil
        {
            userDefaults.set(true, forKey: "flash")
        }
        
        if (userDefaults.object(forKey: "flash") as! Bool)
              {
                  outerToggleFlashButton.setImage(UIImage(named: "Flash_On"), for: .normal)
                  cameraController.flashMode = .on
              }
              else
              {
                  outerToggleFlashButton.setImage(UIImage(named: "Flash_Off"), for: .normal)
                  cameraController.flashMode = .off
              }
    }



    func configureCameraController(orientation: AVCaptureVideoOrientation) {
            
                   cameraController.prepare {(error) in
                       if let error = error {
                           print(error)
                       }
                    try? self.cameraController.displayPreview(on: self.capturePreviewView)//, orientation:orientation)
                       if !(self.cameraController.photoOutput?.supportedFlashModes.contains(.on))!
                       {
                           self.outerToggleFlashButton.isHidden = true
                           self.cameraController.flashMode = .off
                       }
                   }

               }
    
    
 
    
  
    @objc func volumeDidChange(notification: NSNotification) {
          let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
        print(notification.userInfo?.debugDescription)

        self.captureImage()

    }
    
    @IBAction func captureBtn(_ sender: UIButton) {
        self.captureImage()
    
    }
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            outerToggleFlashButton.setImage(UIImage(named:"Flash_Off"), for: .normal)
            userDefaults.set(false, forKey: "flash")
        }
        else {
            cameraController.flashMode = .on
            outerToggleFlashButton.setImage(UIImage(named:"Flash_On"), for: .normal)
            userDefaults.set(true, forKey: "flash")
        }
    }
    
    func captureImage()
    {
        cameraController.captureImage {(image, error) in
        guard let image = image else {
                   print(error ?? "Image capture error")
                   return
               }
            
            let ciiimage =  CIImage(cgImage: (image.cgImage!))
            let im  = self.oldPhoto(img: ciiimage, withAmount: FilterValues.filterIntensity)
            
            var newImage = UIImage()
             newImage = UIImage(cgImage: self.convert(cmage: im).cgImage!, scale: self.convert(cmage: im).scale, orientation: .down)
            

            
            
            self.imageSave.createImagesInFolderWithName(name: "\(Date().tickss).jpg", image: newImage)
            
            self.showMessage(message: "Image Processed Successfully")
    }
    

}
    
    @IBAction func showGallery(_ sender: UIButton) {
        self.performSegue(withIdentifier: "show_gallery", sender: nil)
    }
    
    func convert(cmage:CIImage) -> UIImage
       {
           let context:CIContext = CIContext.init(options: nil)
           let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
           let image:UIImage = UIImage.init(cgImage: cgImage)
           return image
       }
    
    
    func oldPhoto(img: CIImage, withAmount intensity: Float) -> CIImage {
        
        
          let lighten = CIFilter(name:"CIColorControls")
                lighten?.setValue(img, forKey:kCIInputImageKey)
                lighten?.setValue(intensity, forKey:"inputSaturation")
                lighten?.setValue(intensity , forKey: "inputContrast")
          
        
              
            let green = CIFilter(name: "CIColorPolynomial")
            green?.setValue(lighten?.outputImage, forKey: kCIInputImageKey)
        green?.setValue(CIVector(x: FilterValues.redX, y: FilterValues.redY, z: FilterValues.redZ, w: FilterValues.redW), forKey: "inputRedCoefficients")
        green?.setValue(CIVector(x: FilterValues.greenX, y: FilterValues.greenY, z: FilterValues.greenZ, w: FilterValues.greenW), forKey: "inputGreenCoefficients")
        green?.setValue(CIVector(x: FilterValues.blueX, y: FilterValues.blueY, z: FilterValues.blueZ, w: FilterValues.blueW), forKey: "inputBlueCoefficients")
            green?.setValue(CIVector(x: FilterValues.alphaX, y: FilterValues.alphaY, z: FilterValues.alphaZ, w: FilterValues.alphaW), forKey: "inputAlphaCoefficients")
              

       
          

    
            let vignette = CIFilter(name:"CIVignette")
              vignette?.setValue(green?.outputImage, forKey:kCIInputImageKey)
           vignette?.setValue(intensity / 2, forKey:"inputIntensity")
            vignette?.setValue(intensity * 3, forKey:"inputRadius")
    
        
       
              
             

           
              return (vignette?.outputImage)!
          }
    
//    func volumeDidChange(notification: NSNotification) {
//      let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
//
//      // Volume at your service
//    }

        
    
}

struct CheckStruct: Codable {
    let error: Bool?
    let profile: String
}

