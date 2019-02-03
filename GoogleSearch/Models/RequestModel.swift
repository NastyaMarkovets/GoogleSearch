//
//  RequestModel.swift
//  GoogleSearch
//
//  Created by Anastasia Markovets on 25.01.2019.
//  Copyright © 2019 Lonely Tree Std. All rights reserved.
//

import Foundation

class RequestModel: NSObject {
    var task = URLSessionTask()
    
    
    func getData(searchText: String, success: @escaping ([Result]) -> (), canceled: @escaping () -> (), failure: @escaping (String) -> ()) {
        let url = "https://www.googleapis.com/customsearch/v1?q=\(searchText)&key=AIzaSyA048rnebqUIFBkKN9DLS1TF2cesvEaZ7o&cx=000403557364974418831:oyzoaglxv9q"
        let dataURL = URL(string: url)
        let request = URLRequest(url: dataURL!)
        
        let parseQueue = DispatchQueue.global(qos: .utility)

        self.task = URLSession.shared.dataTask(with: request) { data, response, error in
            parseQueue.async {
                if error != nil {
                    DispatchQueue.main.async {
                        let code = (error! as NSError).code
                        if code == -999 {
                            canceled()
                        } else {
                            failure("Connection error: \(String(describing: code))")
                        }
                    }
                    return
                }
                
                guard let data = data else { return }
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                        
                        if let items = jsonResult["items"] as? Array<Dictionary<String, Any>> {
                            var arrayItems = [Result]()
                            for item in 0..<items.count - 1 {
                                let resultItem = Result()
                                if let title = items[item]["title"] as? String {
                                    resultItem.title = title
                                }
                                if let link = items[item]["link"] as? String {
                                    resultItem.link = link
                                }
                                if let snippet = items[item]["snippet"] as? String {
                                    resultItem.snippet = String(snippet.filter { !"\n".contains($0) })
                                }
                                arrayItems.append(resultItem)
                            }
                            if arrayItems.count == 0 {
                                DispatchQueue.main.async {
                                    failure("No results")
                                }
                                return
                            }
                            
                            DispatchQueue.main.async {
                                success(arrayItems)
                            }
                            return
                        }
                    }
                    DispatchQueue.main.async {
                        failure("No results")
                    }
                    return
                }
                catch let error as NSError {
                    DispatchQueue.main.async {
                        failure(error.localizedDescription)
                    }
                }
            }
            
    }
        self.task.resume()
    }
    
    func stopTask() {
        self.task.cancel()
    }
}
