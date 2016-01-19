//
//  ViewController.swift
//  FlickFinder
//
//  Created by Rahath cherukuri on 1/13/16.
//  Copyright © 2016 Rahath cherukuri. All rights reserved.
//

import UIKit

let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.photos.search"
let API_KEY = "f7789d295e6e0e090c774d52d32e8741"
let EXTRAS = "url_m"
let SAFE_SEARCH = "1"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"


class ViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var searchStringTextField: UITextField!
    @IBOutlet weak var latitude: UITextField!
    @IBOutlet weak var longitude: UITextField!
    @IBOutlet weak var imageTitle: UILabel!
    
    let methodArguments = [
        "method": METHOD_NAME,
        "api_key": API_KEY,
        "text": "baby+asian+elephant",
        "safe_search": SAFE_SEARCH,
        "extras": EXTRAS,
        "format": DATA_FORMAT,
        "nojsoncallback": NO_JSON_CALLBACK
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func textSearchButton(sender: UIButton) {
        print("In textSearchButton")
        
        let session = NSURLSession.sharedSession()
        
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        print("request: ", request)
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                print("error: ", error)
                print("Could not complete the download")
            } else {
                print("data: ", data)
                print("\nresponse: ", response)
            }
        }
        task.resume()
    }
    
    @IBAction func latLongSearchButton(sender: UIButton) {
        print("latLongSearchButton")
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}

