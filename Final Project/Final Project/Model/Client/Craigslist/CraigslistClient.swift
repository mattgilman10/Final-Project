//
//  CraigslistClient.swift
//  Final Project
//
//  Created by Matthew Gilman on 5/2/19.
//  Copyright © 2019 Matt Gilman. All rights reserved.
//

import Foundation
//import Alamofire
//import SwiftyXMLParser
//import Alamofire_SwiftyXMLParser

class CraigslistClient: NSObject {
    
    // MARK: Configure UI
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    
    
    func taskForGETMethod(region: String, search: String, completionHandlerForGET: @escaping (_ success: Bool, _ result: [[String:AnyObject]]?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        // create url and request
        
        
        //let urlString = "https://\(region).craigslist.org/search/sss?format=rss&query=\(search)"
        print("HERE IS MY SEARCH -- \(search)")
        let urlString = "https://stlouis.craigslist.org/search/sss?format=rss&query=\(search)"
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
                completionHandlerForGET(false, [[:]], error)
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
            print("DATA")
            print(data)
            let stringResponse = String(data: data, encoding: .utf8)
            print("Response \(stringResponse!)")
            
            
            // parse the data
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//                } catch {
//                    displayError("Could not parse the data as JSON: '\(data)'")
//                    return
//                }
//            print(parsedResult)
            
            //            /* GUARD: Did Flickr return an error (stat != ok)? */
            //            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
            //                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
            //                return
            //            }
            //
            //            /* GUARD: Are the "photos" and "photo" keys in our result? */
            //            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
            //                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
            //                return
            //            }
            //
            let test: [[String:AnyObject]]
            test = []
            completionHandlerForGET(true, test, nil)
            
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

