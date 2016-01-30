# FlickFinder
Browse through the flickerAPI's photos using text search or latitude and longitude search.

Used:
1. Networking: NSURLSessions
2. JSON: NSJSONSerialization
3. StackViews for storyboard
4. Guard variables in Swift

Code Snippets:

Get the NSURLSessions singleton:
let session = NSURLSession.sharedSession()

Create and run a NSURLSessionDataTask:
let url = NSURL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=d72c5a85006014ea74022c115e4ebd5b&text=test&format=json&nojsoncallback=1&auth_token=72157650613647678-32c4dc1af8b80f31&api_sig=0353bdf97603872c2c2338390da3793d")!

let request = NSURLRequest(URL: url)

let task = session.dataTaskWithRequest(request) { data, response, downloadError in
    // do something here...
}
task.resume()

Parse raw JSON data into NSDictionary (if response is a dictionary):
var parsingError: NSError? = nil
let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as NSDictionary

References:

NSURL Hierarchy:
https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i

NSURLSession:
https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/
NSURLRequest:
https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSURLRequest_Class/
NSURLSessionDataTask:
https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSessionDataTask_class/index.html#//apple_ref/swift/cl/NSURLSessionDataTask

Grand Central Dispatch:
https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/
