//
//  Youtube.swift
//  Sound
//
//  Created by Michel Balamou on 2016-11-03.
//  Copyright © 2016 mm. All rights reserved.
//

import UIKit

class Youtube: UIViewController, NSURLSessionDelegate, UITableViewDelegate
{
    @IBOutlet weak var YoutubeLink: UITextField!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressCount: UILabel!
    @IBOutlet weak var bytesDownloaded: UILabel!
    @IBOutlet var tmpView: UIView!
    
    var urlString: String?
    var song_title: String?
    var duration: String?
    
    var Data:Database=Database()
    var download=false
    var updateSongs:()->(Void)={() in }
    
    
    /* Download */
    var task : NSURLSessionTask!
    
    var percentageWritten:Float = 0.0
    var taskTotalBytesWritten = 0
    var taskTotalBytesExpectedToWrite = 0
    
    /* Error Closure */
    var errorDisplay:(String)->Void={_ in}
    
    /**
     
     NOT SURE WHAT THIS DOES
     
     */
    lazy var session : NSURLSession = {
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        config.allowsCellularAccess = false
        let session = NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        return session
    }()
  
    
   
    override func viewDidLoad()
    {
        super.viewDidLoad()

        progressBar.setProgress(0.0, animated: true)  //set progressBar to 0 at start
        YoutubeLink.keyboardAppearance = UIKeyboardAppearance.Dark
        
        let Liked_Videos = LikedVideos(nibName: "LikedVideos", bundle: nil)
        
        tmpView.addSubview(Liked_Videos.view)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Generates a random **alpha-numeric** string with a given length
     
     - Parameter len: length of the generated string
     
     - Returns: randomly generated String
     */
    func randomStringWithLength(len : Int) -> NSString
    {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++)
        {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    
    /**
     Removes all white spaces in the strings from the list 'arr'.
     
     - Parameter arr: array with strings to be trimmed
     */
    func trim_array(arr:Array<String>)->Array<String>
    {
        var result=[String]()
        
        for i in 0...(arr.count-1)
        {
            result.insert(arr[i].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()),atIndex:i)
        }
        
        return result
    }
    
    
    /**
     Receives response from server, in the form of a JSON, and reads it
     
     - Parameters:
            - data:
            - response:
            - error:
     */
    func retreive_response(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void
    {
        if (error == nil)
        {
            if let resp = response as? NSHTTPURLResponse, let new_data=data where resp.statusCode == 200
            {
                /*
                Error Block
                */
                do
                {
                    let responseJSON =  try  NSJSONSerialization.JSONObjectWithData(new_data, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary;
                        
                    self.urlString = responseJSON["link"] as? String
                    self.song_title = responseJSON["title"] as? String
                    self.duration = responseJSON["length"] as? String
                                
                    print("MP3 link received. Start downloading it. \n")
                                
                    if let str=self.urlString
                    {
                        self.download_song(str)
                    }
                }
                catch let JSONError as NSError
                {
                    print("\t\t ~ \(JSONError)")
                    errorDisplay(JSONError.localizedDescription)
                }
                catch
                {
                    print("\t\t ~ Unknown error in JSON Parsing")
                    errorDisplay("Unknown error in JSON Parsing")
                }
             
                /*
                Error Block
                */
                
            }
        }
        else
        {
            print("\t\t ~ Failure: \(error!.localizedDescription)")
            errorDisplay(error!.localizedDescription)
        }
    }
    
    
     /**
     Gets the link to the *mp3 file* from a **Youtube** video and locally saves it.
     
     - Parameter videoURL: link to the **Youtube** video
     */
    func get_mp3_link(videoURL: String)
    {
        let url = NSURL(string: "http://www.youtubeinmp3.com/fetch/?format=JSON&video=\(videoURL)")
        let local_session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        
        
        let local_task = local_session.dataTaskWithRequest(request, completionHandler: retreive_response)
        local_task.resume()
    }
    
    
    /**
    
    */
    func download_song(link: String)
    {
        progressCount.text = "0%"
        
        // if task not nil, dont proceed to beyond this point
        if let _=self.task
        {
            return
        }
        
        let url = NSURL(string:link)!
        let req = NSMutableURLRequest(URL:url)
        let task = self.session.downloadTaskWithRequest(req)
        self.task = task
        task.resume()
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten writ: Int64, totalBytesExpectedToWrite exp: Int64)
    {
        download=true
        taskTotalBytesWritten = Int(writ)
        taskTotalBytesExpectedToWrite = Int(exp)
        percentageWritten = Float(taskTotalBytesWritten) / Float(taskTotalBytesExpectedToWrite)
        
        let a=String(format: "%.02f", Float(taskTotalBytesWritten)/(1024*1024))
        let b=String(format: "%.02f", Float(taskTotalBytesExpectedToWrite)/(1024*1024))
        
        bytesDownloaded.text="\(a) / \(b) Mb"
        progressBar.progress = percentageWritten
        progressCount.text = String(format: "%.01f", percentageWritten*100) + "%"
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?)
    {
        print("\n********************************")
        print("Completed: \(error)")
        print("********************************\n")
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL)
    {
        let documentsDirectoryURL =  NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let random_name=(self.randomStringWithLength(8) as String)
        let destinationUrl = documentsDirectoryURL.URLByAppendingPathComponent(random_name+".mp3")
        
        print("Finished downloading!")
        download=false
        
        // Hide all elements
        progressCount.hidden=true
        progressBar.hidden=true
        bytesDownloaded.hidden=true
        
        progressCount.text = "0%"
        bytesDownloaded.text = "Memory"
        progressBar.progress = 0.0
        
        task=nil
        
        if taskTotalBytesWritten==taskTotalBytesExpectedToWrite
        {
            do {
                // after downloading your file you need to move it to your destination url
                try NSFileManager().moveItemAtURL(location, toURL: destinationUrl)
                print("File moved to documents folder")
            
                var extrapolate=(self.song_title ?? "").characters.split{$0 == "-"}.map(String.init)
                extrapolate=self.trim_array(extrapolate) // remove all white spaces
            
                self.Data.add_song(extrapolate[0], extrapolate.count>1 ? extrapolate[1] : extrapolate[0], random_name, duration ?? "")
                self.updateSongs()
            }
            catch let error as NSError
            {
                print("\t\t ~ \(error.localizedDescription)")
                errorDisplay(error.localizedDescription)
            }
        }
        else
        {
            print("\t\t ~ Error: File only partially downloaded!")
            errorDisplay("Error: File only partially downloaded!")
        }
    }
    
    
   
    /*
    
    ACTIONS
    
    */
    
    @IBAction func ClearData(sender: UIButton)
    {
        Data.clear_data("Test")
        updateSongs()
    }
    
    @IBAction func download(sender: UIButton)
    {
        if download==false
        {
            print("Download clicked!")
            progressCount.text = "Converting video into mp3"
            get_mp3_link(YoutubeLink.text!)
            
            // Show all elements
            progressCount.hidden=false
            progressBar.hidden=false
            bytesDownloaded.hidden=false
        }
    }
    
    @IBAction func field_selected(sender: UITextField)
    {
        let pb: UIPasteboard = UIPasteboard.generalPasteboard()
        sender.text = pb.string
    }

}
