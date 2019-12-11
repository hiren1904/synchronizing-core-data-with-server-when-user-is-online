//
//  ViewController.swift
//  cropping
//
//  Created by Purvesh tejani on 11/12/19.
//  Copyright © 2019 Purvesh tejani. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var imgview: UIImageView!
    
    @IBOutlet weak var scrView: UIScrollView!
    
    @IBOutlet weak var imgheight: NSLayoutConstraint!
    
    @IBOutlet weak var imgwidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imgtap)))
        imgview.isUserInteractionEnabled = true
    }
    
    @objc func imgtap ()
    {
        let picker = UIImagePickerController();
        picker.delegate = self
        picker.sourceType = .photoLibrary
         picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage
        {
            imgview.image = image
        }
        
        else if let image = info[.originalImage] as? UIImage
        {
            imgview.image = image
        }
    
        self.dismiss(animated: true) {
            
            
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imgview;
    }
    
    
   
}

