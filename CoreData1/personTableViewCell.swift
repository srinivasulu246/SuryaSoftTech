//
//  personTableViewCell.swift
//  CoreData1
//
//  Created by Srinivas on 13/12/18.
//  Copyright © 2018 impelsys. All rights reserved.
//

import UIKit

class personTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var fnameLbl: UILabel!
    
    @IBOutlet weak var lNameLbl: UILabel!
    
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var profileImgView: UIImageView!
    
     let imageCache = NSCache<NSString, UIImage>()
    let urlString:String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    func retriveImagesFromDocDir(imgName:String) -> UIImage   {
        let emptyImgObj = UIImage()
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(imgName).png").path
        print(filePath)
        if FileManager.default.fileExists(atPath: filePath) {
            if let img =  UIImage(contentsOfFile: filePath) {
                return img
            }
        }
        return emptyImgObj
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
