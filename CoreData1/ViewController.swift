//
//  ViewController.swift
//  CoreData1
//
//  Created by Srinivas on 13/12/18.
//  Copyright © 2018 impelsys. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var usersTableView: UITableView!
    
    @IBOutlet weak var userEmailTxtField: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
  
    let cellID = "cellID"
    
    var userEmailID:String = ""
    
    var people:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    //   aTableview.register(personTableViewCell.self , forCellReuseIdentifier: cellID)
        submitBtn.layer.cornerRadius = 8.0
        self.usersTableView.estimatedRowHeight = 150.0
        self.usersTableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
   //     updateTableDate()
        print("count: \(people.count)")
    }
    
    @IBAction func submitBtnAction(_ sender: Any) {
        userEmailID = userEmailTxtField.text as! String
      let fieldCheck =   emptyFieldValidation(userEmail: userEmailID)
        if fieldCheck == true {
            callAPiAndFetchUSersDataFromCoredata(userEmailID: userEmailID)
        }
    }
    
    func emptyFieldValidation(userEmail:String) -> Bool{
        var isGoodToGo = false
        if (userEmail.count) == 0 {
                isGoodToGo = false;
        }else{
             isGoodToGo = true;
        }
        if isGoodToGo == false {
            DispatchQueue.main.async {
                self.showAlertWith(title: "Alert!", message: "Please Provide a EmailID")
            }
        }
        return isGoodToGo
    }
    
func callAPiAndFetchUSersDataFromCoredata(userEmailID:String) {
        let valid =  isValidEmail(email: userEmailID)
        if valid{
       
            if Reachability.isConnectedToNetwork(){
                print("Internet Connection Available!")
                apiCall(userEmailID: userEmailID)
            }else{
                print("Internet Connection not Available!")
                fetchDetails()
                self.usersTableView.reloadData()
            }
            
        }else{
            DispatchQueue.main.async {
                self.showAlertWith(title: "Invalid Email!", message: "Please Provide Valid Email")
            }
        }
    }
    
        // Validating email format
        func isValidEmail(email:String) -> Bool {
            let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
            return pred.evaluate(with: email)
        }
    
    func updateTableDate()  {
        fetchDetails()
       self.usersTableView.reloadData()
    }
    
    func apiCall (userEmailID:String)  {
        let urlString =  "http://surya-interview.appspot.com/list"
        let userEmail = userEmailID
        ApiClass.sharedInstance.getDataWith(urlString: urlString, userEmailID: userEmail) {[unowned self] result in
            switch result {
            case Result.Success(let jsonResponse):
                self.clearSavedData()
                self.parseResponseAndSaveInCoreData(responseArr: jsonResponse)
                self.fetchDetails()
                 print("count: \(self.people.count)")
                self.usersTableView.reloadData()
                return
            case .Error(let error):
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Error", message: error)
                }
            }
        }
    }
    
    func parseResponseAndSaveInCoreData(responseArr:[[String:Any]])  {
        guard let response = responseArr as? [[String:Any]] else{return}
        for responseDict in response {
            saveDetails(fname: responseDict["firstName"] as! String, lName: responseDict["lastName"] as! String, email: responseDict["emailId"] as! String, imgurl: responseDict["imageUrl"] as! String)
        }
    }
    
    func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: title, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    
    func saveDetails(fname:String,lName:String,email:String,imgurl:String)  {
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
//        guard let entityDes = NSEntityDescription.entity(forEntityName: "Person", in: context) else{return}
//        let person = NSManagedObject(entity: entityDes , insertInto: context)
        let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: context)
        person.setValue(lName, forKey: "lastName")
           person.setValue(fname, forKey: "firstName")
           person.setValue(email, forKey: "emailId")
        person.setValue(imgurl, forKey: "imageUrl")
        do {
            try context.save()
            print("saved")
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func fetchDetails ()  {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            people = try context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func clearSavedData()  {
        let contex = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")

        do {
             people =  try contex.fetch(fetchRequest)

            for person in people{
                contex.delete(person)
            }

        } catch let error  {
            print(error.localizedDescription)
        }
    }
}

extension ViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! personTableViewCell
        let person = people[indexPath.row]
        guard let fname = person.value(forKey: "firstName") as? String else { return cell  }
     
        cell.fnameLbl?.text = fname
        
        guard let lname = person.value(forKey: "lastName") as? String else { return cell  }
        cell.lNameLbl?.text = lname
        
        guard let email = person.value(forKey: "emailId") as? String else { return cell  }
        cell.emailLbl?.text = email

           guard let imgUrl = person.value(forKey: "imageUrl") as? String else { return cell  }
        
          cell.profileImgView.layer.cornerRadius = cell.profileImgView.frame.height/2
    //    cell.setProfileImages(urlStr: imgUrl, key: fname)
        
        cell.profileImgView.loadImageUsingCacheWithURLString(imgUrl, imgname: fname)
        cell.profileImgView.roundedCorners()
        
        cell.profileImgView.image = cell.retriveImagesFromDocDir(imgName: fname)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
  
}

