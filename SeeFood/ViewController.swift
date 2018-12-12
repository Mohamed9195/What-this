
//
//  ViewController.swift
//  SeeFood
//
//  Created by mohamed hashem on 11/6/18.
//  Copyright © 2018 mohamed hashem. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD


class ViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    //MARK: - setup data to IBM
    let apiKey = "X1gX8iebxZFrEfxHgKiOkkpYarGmoyaT1UmiejGKhzFx"
    
    let version = "2018-11-06"
    
    
    //MARK: - setup data to Camera
    @IBOutlet weak var camerButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textData: UITextView!
    @IBOutlet weak var cancellshow: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
    // array of classification
    var classificationResults: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imagePicker.delegate = self
        
    }
    
    //MARK: - delegate when camera finish tack photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        textData.text = " "
        self.navigationItem.title = " "
        
        camerButton.isEnabled = false
        cancellshow.isEnabled = false
        
        SVProgressHUD.show()
        
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = image
            
            
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            
            // save photo in local and convert to Data (Binary data)
            let imageData = image.jpegData(compressionQuality: 0.01)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("TempImage.jpg")
            try? imageData?.write(to: fileURL, options: [])
            
            // use IBM Model Go To path and run for fiunding photo
            visualRecognition.classify(imagesFile: fileURL , success: { (ClassifiedImages) in
                
                let classes = ClassifiedImages.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for index in 1..<classes.count {
                    self.classificationResults.append(classes[index].className)
                    
                    DispatchQueue.main.async {
                        self.textData.text += self.classificationResults[index - 1] + " , "
                    }
                    
                    
                }
                // finish search data
                DispatchQueue.main.async {
                    
                    self.camerButton.isEnabled = true
                    self.cancellshow.isEnabled = true
                    self.navigationItem.title = "Result Of Search"
                    SVProgressHUD.dismiss()
                }
                
               
            })
            
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - run camera to tack photo
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        SVProgressHUD.dismiss()
        imageView.image = UIImage(named: "")
        navigationItem.title = ""
        textData.text = ""
    }
    
    
    
    
}

