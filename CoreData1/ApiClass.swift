//
//  ApiClass.swift
//  CoreData1
//
//  Created by Srinivas on 13/12/18.
//  Copyright © 2018 impelsys. All rights reserved.
//

import UIKit

class ApiClass: NSObject {

    static let sharedInstance = ApiClass()
    
    func getDataWith(urlString:String ,  userEmailID:String , completion: @escaping (Result<[[String: AnyObject]]>) -> Void)  {
        
        guard let url = URL(string: urlString) else { return }
        guard let userEmail = URL(string: userEmailID) else { return}
        let parameterDictionary = ["emailId":userEmailID]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error  {
              completion(Result.Error(error.localizedDescription))
            }
            
            if let response = response {
                
            }
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                        guard let itemsJsonArray = json["items"] as? [[String: AnyObject]] else {
                            return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
                        }
                        
                       // print(itemsJsonArray)
                        DispatchQueue.main.async {
                            completion(.Success(itemsJsonArray))
                        }
                    }
                }catch {
                    print(error)
                }
            }
            }.resume()
       
    }
}


enum Result<T> {
    case Success(T)
    case Error(String)
}

