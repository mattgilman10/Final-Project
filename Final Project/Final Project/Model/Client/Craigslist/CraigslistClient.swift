//
//  CraigslistClient.swift
//  Final Project
//
//  Created by Matthew Gilman on 5/2/19.
//  Copyright © 2019 Matt Gilman. All rights reserved.
//

import Foundation
import SwiftyXMLParser

class CraigslistClient: NSObject {
    
    // MARK: Configure UI
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    
    //MARK: Task for grabbing the XML data and making API call
    func taskForGETMethod(region: String, search: String, completionHandlerForGET: @escaping (_ success: Bool, _ result: XML.Accessor, _ error: String?) -> Void) -> URLSessionDataTask {
        
        // create url and request
        
        
        //let urlString = "https://\(region).craigslist.org/search/sss?format=rss&query=\(search)"
        print("HERE IS MY SEARCH -- \(search)")
        let newSearch = search.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

        let urlString = "https://stlouis.craigslist.org/search/sss?format=rss&query=\(newSearch!)"
        //        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
        print("THIS IS MY URL: \(urlString)")
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                let blank = try! XML.parse("")
                completionHandlerForGET(false, blank, error)
                performUIUpdatesOnMain {
                    //self.setUIEnabled(true)
                    
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            let stringResponse = String(data: data, encoding: .utf8)
            // parse xml document
            let xml = try! XML.parse(stringResponse!)
            
            // access xml element
            let path = ["rdf:RDF", "item"]
            let elements = xml[path]
//            print("Response \(elements)")
            completionHandlerForGET(true, elements, nil)
            
//            if let title = elements[1]["title"].text{
//                print("Title \(title)")
//            }
            
  
        }
        
        // start the task!
        task.resume()
        return task
    }
    
    class func sharedInstance() -> CraigslistClient {
        struct Singleton {
            static var sharedInstance = CraigslistClient()
        }
        return Singleton.sharedInstance
    }

}

// MARK: Shared Instance

