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
let BOUNDING_BOX_HALF_WIDTH = 1.0
let BOUNDING_BOX_HALF_HEIGHT = 1.0
let LAT_MIN = -90.0
let LAT_MAX = 90.0
let LON_MIN = -180.0
let LON_MAX = 180.0


class ViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var searchStringTextField: UITextField!
    @IBOutlet weak var latitude: UITextField!
    @IBOutlet weak var longitude: UITextField!
    @IBOutlet weak var imageTitle: UILabel!
    
    var methodArguments = [
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
        
        var methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        var searchText = searchStringTextField.text!
        searchText = searchText.stringByReplacingOccurrencesOfString(" ", withString: "+", options: .LiteralSearch, range: nil)
        methodArguments["text"] = searchText
        print("methodArguments: ",methodArguments)
        getImageFromFlickrBySearch(methodArguments)
    }
    
    @IBAction func latLongSearchButton(sender: UIButton) {
        var methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        methodArguments["bbox"] = createBoundingBoxString()
        print("methodArguments: ",methodArguments)
        getImageFromFlickrBySearch(methodArguments)
    }
    
    func randomValue(noOfElements: Int) -> Int {
        return Int(arc4random_uniform(UInt32(noOfElements)))
    }
    
    func getImageFromFlickrBySearch(methodArguments: [String : AnyObject]) {
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else {
                print("Cannot find keys 'photos' in \(parsedResult)")
                return
            }
            
            guard let photoCount = photosDictionary["photo"]?.count else {
                print("There are no photos")
                return
            }
            print(photoCount)
            if photoCount > 0 {
                let arrayIndex = self.randomValue(photoCount)
                print("\narrayIndex: ", arrayIndex)
                
                guard let photos = photosDictionary["photo"] else {
                    print("There are no photos")
                    return
                }
                print("RandomPhoto: ", photos[arrayIndex])
                
                guard let imageUrlString = photos[arrayIndex]["url_m"] as? String,
                    let photoTitle = photos[arrayIndex]["title"] as? String else {
                        print("There is no url for the image")
                        return
                }
                print("URL: ", imageUrlString)
                
                let imageURL = NSURL(string: imageUrlString)
                
                /* 6 - Update the UI on the main thread */
                if let imageData = NSData(contentsOfURL: imageURL!) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.imageTitle.text = photoTitle
                        self.photoImageView.image = UIImage(data: imageData)
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("No Photos Found. Search Again.")
                    self.imageTitle.text = "No Photos Found. Search Again."
                })
            }
        }
        task.resume()
    }
    
    func createBoundingBoxString() -> String {
        
        let latitude = (self.latitude.text! as NSString).doubleValue
        let longitude = (self.longitude.text! as NSString).doubleValue
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
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


