//
//  AlamoRequest.swift
//  Tabbed Location Sender
//
//  Created by Eli Johnston on 2020-07-13.
//  Copyright © 2020 Eli Johnston. All rights reserved.
//

import Foundation

class HttpRequest {
    
    func postRequest(json: [String: Any], completionHandler: @escaping ([String: Any]) -> Void) {
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "https://mapping-project.azurewebsites.net/api/path")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if ((error) != nil) { print("PERROR") }
            guard let data = data else {
                print("DERROR")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("RES",responseJSON)
                completionHandler(responseJSON)
            }
        }
        task.resume()
    }
}
