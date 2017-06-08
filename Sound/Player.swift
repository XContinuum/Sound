//
//  Player.swift
//  Sound
//
//  Created by Michel Balamou on 2016-10-31.
//  Copyright © 2016 mm. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer



class Player: UIViewController, AVAudioPlayerDelegate
{
    @IBOutlet var Slider: UISlider!
    @IBOutlet var RepeatBtn: UIButton!
    @IBOutlet var PlayBtn: UIButton!
    
    @IBOutlet var DurationLb: UILabel!
    @IBOutlet var CurrentLb: UILabel!
    @IBOutlet var TitleLb: UILabel!
    @IBOutlet var ArtistLb: UILabel!
    
    @IBOutlet var artWork: UIImageView!
    @IBOutlet var toolBar: UIView!
    
    @IBOutlet var startField: UITextField!
    @IBOutlet var endField: UITextField!
    
    var current_path: String?
    
    var endSequence: Double=0.0
    var startSequence: Double=0.0
    
    
    var player:AVAudioPlayer = AVAudioPlayer()
    var timer:NSTimer?
    
    var errorDisplay:(String)->Void = {_ in}
    var loop = false
    
    var too_large = false
    var new_dur:Float=0
    
    var show_art_work = false
    
    var moving_slider = false
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let thumb = UIImage(named: "thumb")
        Slider.setThumbImage(thumb, forState: .Normal)
        
        if show_art_work==false
        {
            var newFrame=toolBar.frame
            newFrame.origin.y=66
            
            toolBar.frame=newFrame
            artWork.hidden=true
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    

    /**
    Plays the song if the data is in order and no exceptions have been thrown.
    
    Parameters:
           - soundData:
           - documentPath:
           - musicData: dictionary with keys "Title", "Artist" and "Duration", "start", "end"
    */
    func setup_play_scene(soundData: NSData, _ documentPath: NSURL, _ musicData: Dictionary<String, String>) throws
    {
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try AVAudioSession.sharedInstance().setActive(true)
        
        player = try AVAudioPlayer(data: soundData)
        player.delegate = self
        player.prepareToPlay()
        player.play()
        
        
        // SET VISUALS
        Slider.maximumValue=Float(player.duration)
        Slider.value=0.0
        
        PlayBtn.setImage(UIImage(named: "pause"), forState: .Normal)
        TitleLb.text = musicData["name"]
        ArtistLb.text = musicData["artist"]
        DurationLb.text = seconds2minutes((Float(player.duration)))
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "update", userInfo: nil, repeats: true)
        
        
        startSequence = musicData["start"] != nil ? min2sec(musicData["start"]!) : 0
        endSequence = musicData["end"] != nil ? min2sec(musicData["end"]!) : player.duration
        player.currentTime = startSequence
        Slider.value = Float(startSequence)
        
        //print("\(musicData["start"])  \(musicData["end"])")
        
        startField.text = musicData["start"] ?? "00:00"
        endField.text = musicData["end"] ?? seconds2minutes((Float(player.duration)))
        
        
        
        
        // The file is probably corrupted
        if let dur=Float(musicData["duration"]!) where abs(dur-Float(player.duration))>10
        {
            print("Alert: Difference between the expected duration and the file duration is too large!")
            DurationLb.text="~\(seconds2minutes(dur))"
            Slider.maximumValue=dur
            too_large=true
            new_dur=dur
            
            DurationLb.textColor=UIColor.redColor()
        }
        // The file is OK
        else
        {
            too_large=false
            DurationLb.textColor=UIColor.whiteColor()
        }
        
        if loop==true
        {
            player.numberOfLoops = -1
        }
        
        // Set info that will be displayed once screen is in sleep-mode
        set_offScreen_data(documentPath)
    }
    
    
    /**
     Plays song from the documents at path.
     
     - Parameters:
            - path: path to the mp3 file
            - musicInfo: dictionary with keys "Title", "Artist" and "Duration"
     */
    func play_song(music_info: Dictionary<String, String>)
    {
        guard let path=music_info["path"] else
        {
            errorDisplay("Music data doesn't have a paht.")
            return
        }
        
        current_path=path
        
        let fileManager = NSFileManager.defaultManager()
        let URL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        if let documentDirectoryURL = URL.first
        {
            let documentPath = documentDirectoryURL.URLByAppendingPathComponent(path+".mp3") // get path to song
            
            guard let soundData = NSData(contentsOfURL: documentPath) else
            {
                print("\t\t ~ Music file doesn't exist.")
                errorDisplay("Music file doesn't exist.")
                return
            }
            
            
            do
            {
                try setup_play_scene(soundData, documentPath, music_info)
            }
            catch let error as NSError
            {
                print("\t\t ~ \(error) \n")
            
                errorDisplay(error.localizedDescription)
            }
        }
    }
    
    
    /**
     Converts seconds into minutes:seconds
     
     - Parameter seconds: seconds to be converted into minutes:seconds
     */
    func seconds2minutes(seconds: Float) -> String
    {
        let mm = Int(seconds/60)
        let m = mm>9 ? "\(mm)" : "0\(mm)"
        
        let ss = Int(seconds % 60)
        let s = ss>9 ? "\(ss)" : "0\(ss)"
        
        return m + ":" + s
    }
    
    /**
     
     */
    func min2sec(str: String) -> Double
    {
        var split=str.characters.split{$0 == ":"}.map(String.init)
        
        if split.count>0
        {
            guard let m=Double(split[0]), let s=Double(split[1]) else
            {
                return 0.0
            }
            return m*60+s
        }
        else
        {
            return 0.0
        }
    }
    
    
    /**
     This function executes every second after pressing play. Updates slide position and time label.
     */
    func update()
    {
        Slider.value=Float(player.currentTime)
        CurrentLb.text=seconds2minutes(Float(player.currentTime))
        
        
        //
        if (Int(player.currentTime)==Int(endSequence))
        {
            player.currentTime=startSequence
        }
        //
        
        if (player.currentTime==player.duration)
        {
            // Song ended
            if loop==false
            {
                PlayBtn.setImage(UIImage(named: "play"), forState: .Normal)
            }
        }
        
        // if the song is too large
        if too_large && Int(player.currentTime)==Int(new_dur)
        {
            player.currentTime=0.0
        }
    }
    
    
    /**
     Returns info fromt the mp3 file at path NSURL.
     
     Parameter path:
     */
    func return_mp3_info(path: NSURL) -> (title: String?, artist: String?, image: UIImage?)
    {
        var title : String?
        var artist : String?
        var img : UIImage?
        
        
        let playerItem = AVPlayerItem(URL: path)
        let metadataList = playerItem.asset.metadata
        
        for item in metadataList
        {
            guard let key = item.commonKey, let value = item.value else
            {
                continue
            }
            
            switch key
            {
            case "title":
                title = value as? String
            
            case "artist":
                artist = value as? String
            
            case "artwork" where value is NSData:
                img = UIImage(data: value as! NSData)
                
            default:
                continue
            }
        }
        
        return (title, artist, img)
    }
    
    /**
     Sets title, artist and art work from the background sound into the off screen view.
     */
    func set_offScreen_data(path: NSURL)
    {
        let info=return_mp3_info(path)
        
        var dict: [String: AnyObject] = [
            MPMediaItemPropertyTitle: info.title ?? "",
            MPMediaItemPropertyArtist: info.artist ?? "",
            MPNowPlayingInfoPropertyPlaybackRate: player.currentTime,
            MPMediaItemPropertyPlaybackDuration: player.duration
            //MPMediaItemPropertyAlbumTitle: "Album",
            //MPNowPlayingInfoPropertyElapsedPlaybackTime: player.currentPlaybackTime,
        ]
        
        var newFrame=toolBar.frame
        if let unwrapped_image=info.image where show_art_work==true
        {
            dict[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: unwrapped_image)
            artWork.image=unwrapped_image
            
            newFrame.origin.y=434
            artWork.hidden=false
        }
        else
        {
            newFrame.origin.y=66
            artWork.hidden=true
        }
        
        toolBar.frame=newFrame
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = dict
    }
    
    /*
    
    ACTIONS ~~~~~~~~~~~~~~~~~~
    
    */
    
    @IBAction func PlayPause(sender: UIButton)
    {
        if player.playing
        {
            // PAUSE THE SONG
            player.pause()
            sender.setImage(UIImage(named: "play"), forState: .Normal)
        }
        else
        {
            // PLAY THE SONG
            player.play()
            sender.setImage(UIImage(named: "pause"), forState: .Normal)
        }
    }
    
    @IBAction func RepeatShuffle(sender: UIButton)
    {
        if loop==true
        {
            // Stop loop
            sender.setImage(UIImage(named: "neutral"), forState: .Normal)
            player.numberOfLoops = 0
            loop=false
        }
        else
        {
            // Start loop
            sender.setImage(UIImage(named: "repeat"), forState: .Normal)
            
            player.numberOfLoops = -1
            loop=true
        }
    }
    
    @IBAction func ChangePlay(sender: UISlider)
    {
        moving_slider=true
        player.currentTime=Double(sender.value)
    }
    
    
    @IBAction func editDone(sender: UITextField)
    {
        endSequence=min2sec(endField.text!)
        startSequence=min2sec(startField.text!)
        
        print("\(startSequence):\(endSequence)")
    }
    
    @IBAction func saveInterval(sender: UIButton)
    {
        let t:Database=Database()
        
        if let path=current_path, let index=t.get_index_from_path(path)
        {
            print(index)
            t.change_interval_play(index, startField.text!, endField.text!)
            
            t.output()
        }
    }
}
