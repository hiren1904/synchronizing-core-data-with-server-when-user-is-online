//
//  ViewController.swift
//  cropping
//
//  Created by Purvesh tejani on 11/12/19.
//  Copyright © 2019 Purvesh tejani. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var imgview: UIImageView!
    
    @IBOutlet weak var scrView: UIScrollView!
    
    @IBOutlet weak var imgheight: NSLayoutConstraint!
    
    @IBOutlet weak var imgwidth: NSLayoutConstraint!

    @IBOutlet weak var EnterName: UITextField!
    
    @IBOutlet weak var img2: UIImageView!
    
    
    let flag = String(1);
    let flag1 = 1;
    
    var finalarr : [School] = [];
    
    var imgarr : [Any] = [];
    
    var base64 : [String] = [];
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        internetConnection()
        imggTapp();
        rotate();
    }
    
    func imggTapp()  {
        
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
    
    func rotate()  {
        
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(self.rotImg))
        
        imgview.addGestureRecognizer(rotation)
        imgview.isUserInteractionEnabled = true
    }
    
    @objc func rotImg(sender:UIRotationGestureRecognizer){
        
        imgview.transform = CGAffineTransform(rotationAngle: sender.rotation);
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imgview;
    }
    
    
    @IBAction func uploadBtn(_ sender: UIButton) {
        
        uploadDataToLocal();
        
        let alert = UIAlertController(title: "Upload Successful", message: "You uploading of data is completed", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { (ok) in
            
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil);
    }
    
    
    func uploadDataToLocal()  {
        
        var imgName = "";
        
        if EnterName.text != nil
        {
            imgName = EnterName.text! + ".jpeg"
        }
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "School", into: context)
        entity.setValue(imgName, forKey: "profile");
        entity.setValue(flag1, forKey: "updateflag")
        
        do
        {
            try context.save()
            SaveImgToDocumentDirectory(imgname: imgName, imgdata: imgview.image!)
        }
        catch
        {
            
        }
    }
    
    func SaveImgToDocumentDirectory(imgname:String,imgdata:UIImage) {
        
        let filemanager = FileManager.default
        
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgname)
        print(path)
        let imgdata = imgdata.jpegData(compressionQuality: 2.0)
        filemanager.createFile(atPath: path, contents: imgdata, attributes: nil);
    }
    
    func getData()  {
        
        var temparr = [School]();
        
        let requedst = NSFetchRequest<NSFetchRequestResult>(entityName: "School")
        
        do
        {
            temparr = try context.fetch(requedst) as! [School]
            finalarr = temparr
        }
        catch
        {
            
        }
        
    }
    
    func getimage(imgname:String) -> UIImage  {
        
        let filemanager = FileManager.default
        
        let imagepath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgname)
        
        
        if filemanager.fileExists(atPath: imagepath)
        {
            return UIImage(contentsOfFile: imagepath)!
        }
        else
        {
            return UIImage(named: "person.circle")!;
        }
        
    }
    
    func internetConnection()  {
        
        if Connectivity.isConnectedToInternet {
            
            getData();
    
            for i in 0..<finalarr.count
            {
                if finalarr[i].updateflag == 1
                {
                    imgarr.append(getimage(imgname: finalarr[i].profile!))
                
                }
                
            }
            
            print(imgarr.count);
            
            for p in 0..<imgarr.count
            {
                print(p)
                let ff = imgarr[p] as! UIImage
                let data1 = ff.jpegData(compressionQuality: 2.0)
                base64.append(data1!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters))
                updateFlageOfLocalDataBase(k: p);
                RecordToServer(j: p);
            }
        }
        
        else
        {
            print("You are not connected to internet")
        }
    }
    
    
    func RecordToServer(j: Int) {
        
        print(j)
        let url = URL(string: "http://localhost/proff/addevent.php")
        
        let strbody = "profile=\(base64[j])"
        var request = URLRequest(url: url!)
        request.addValue(String(strbody.count), forHTTPHeaderField: "Content-Length")
        request.httpBody = strbody.data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        let session = URLSession.shared
        let datatask = session.dataTask(with: request) { (data1, resp, error) in
            
            let resp = String(data: data1!, encoding: String.Encoding.utf8)
            
            print(resp!)
        }
        
        datatask.resume();
        
    }
    
    func updateFlageOfLocalDataBase(k:Int) {
        
        print(k);
        var temparr = [School]();
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "School")
        
        let predi = NSPredicate(format: "updateflag == %@", flag)
        
        request.predicate = predi
        
        do
        {
            temparr = try context.fetch(request) as! [School]
            
            print(temparr.count)
            
                temparr[0].updateflag = 0
                
                do
                {
                    try context.save()
                }
                catch
                {
                    
                }
                
            
        }
        catch
        {
            
        }
        
    }
}


class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
