//
//  Extension.swift
//  CoreData1
//
//  Created by Srinivas on 13/12/18.
//  Copyright © 2018 impelsys. All rights reserved.
//
import Foundation
import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func roundedCorners()  {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
    func loadImageUsingCacheWithURLString(_ URLString: String ,imgname:String) {
        
        self.image = nil
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            return
        }
        
        if let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                
                //print("RESPONSE FROM API: \(response)")
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(String(describing: error))")
                    DispatchQueue.main.async {
                     //   self.image = placeHolder
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            saveImageAtDocumentDirectory(imgName: imgname, img: downloadedImage)
                            imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                            self.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
    }
}
    
extension UIColor {
        class var separatorColor: UIColor {
            return UIColor(red: 244.0/255.0, green: 167.0/255.0, blue: 210.0/255.0, alpha: 1.0)}
}

func saveImageAtDocumentDirectory(imgName:String , img:UIImage){
     if let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last{
      //  print(docUrl.absoluteString)
        let docPath = docUrl.path
     //   let filePath = docUrl.appendingPathComponent("\(imgStr).png")
          let filePath = docUrl.appendingPathComponent("\(imgName).png")
     //   print(filePath)

        if let pngImageData = img.pngData(){
            do{
              try pngImageData.write(to: filePath, options: .atomic)
            }catch let error  {
                print(error.localizedDescription)
            }
        }
    }
}




