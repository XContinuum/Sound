//
//  Database.swift
//  Sound
//
//  Created by Michel Balamou on 2016-10-30.
//  Copyright © 2016 mm. All rights reserved.
//

import Foundation
import MediaPlayer

class Database
{
    struct defaultsKeys
    {
        static let mainKey = "Music"
        static let testKey = "Test"
    }
    typealias supertable=Array<Dictionary<String,String>>
    
    
    /**
     Returns a zero in front of the integer if it is less than 10.
     
     - Parameter n: integer to be formatted
     */
    func over_ten(n: Int) -> String
    {
        return n<10 ? "0\(n)" : "\(n)"
    }
    
    /**
     Gets current date
     
     - Returns: String with format hour:minute day-month-year
     */
    func get_date()->String
    {
        let date = NSDate()
        let calender = NSCalendar.currentCalendar()
        let components = calender.components([.Year, .Month, .Day, .Hour, .Minute], fromDate: date)
        
        let time=[over_ten(components.hour),
                  over_ten(components.minute),
            
                  over_ten(components.day),
                  over_ten(components.month),
                  over_ten(components.year)]
        
        return "\(time[0]):\(time[1]) \(time[2])-\(time[3])-\(time[4])"
    }
    
    /**
     Adds song to the local data storage.
     
     - Parameters:
     - artist: name of the artist
     - song-name: name of the song
     - song-path: local path to the mp3 file
     - duration: duration of the song
     */
    func add_song(artist:String, _ song_name: String, _ song_path: String, _ duration: String)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let piece=["artist":artist,
                   "name":song_name,
                   "path":song_path,
                   "repeats":"0",
                   "duration":duration,
                   "date":self.get_date()]
        
        let key=defaultsKeys.testKey
        
        if let data_music = defaults.arrayForKey(key)
        {
            var new_data=data_music
            new_data.insert(piece, atIndex: new_data.count)
            
            defaults.setValue(new_data, forKey: key)
        }
        else
        {
            let data=[piece]
            
            defaults.setValue(data, forKey: key)
        }
        
        defaults.synchronize()
    }
    
    /**
     Clears data in the local storage with the key
     
     - Parameter key: the key to the data
     */
    func clear_data(key:String)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(nil, forKey: key)
    }
    
    /**
     Returns songs from the local database. If the songs are nil, it returns an empty array.
     */
    func get_songs() -> Array<Dictionary<String,String>>
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let key=defaultsKeys.testKey
        
        return (defaults.arrayForKey(key) as? Array<Dictionary<String,String>>) ?? []
    }
    
    /**
     Returns songs from the local database. If the songs are nil, it returns an empty array.
     */
    func get_songs_reversed() -> Array<Dictionary<String,String>>
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let key=defaultsKeys.testKey
        let result=(defaults.arrayForKey(key) as? Array<Dictionary<String,String>>) ?? []
        
        return result.reverse()
    }
    
    
    /**
     Deletes a rows from the database.
     
     - Parameter row: rows to delete, has to be always from greatest to lowest
     */
    func delete_rows(row:Array<Int>)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let key=defaultsKeys.testKey
       
        if var data_music = defaults.arrayForKey(key)
        {
            for i in row
            {
                if i<data_music.count
                {
                   data_music.removeAtIndex(i)
                }
            }
            
            defaults.setValue(data_music, forKey: key)
        }
    }
    
    
    /**
    Deletes all rows in the database that don't have music files.
    */
    func clean_up()
    {
        var table=get_songs()
        var delete=[Int]()
        let fileManager = NSFileManager.defaultManager()
        
        let URL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        if let documentDirectoryURL: NSURL = URL.first
        {
            for i in 0...(table.count-1)
            {
                let documentPath = documentDirectoryURL.URLByAppendingPathComponent((table[i]["path"] ?? "") + ".mp3") // get path to song
                let soundData:NSData? = NSData(contentsOfURL: documentPath)
                
                if soundData==nil
                {
                    delete.append(i)
                }
            }
        }
        
        // Delete
        delete_rows(delete.sort(>))
    }
    
    
    /**
     
     - Parameter str:
     - Parameter maximum:
     */
    func format(str:String?, _ maximum: Int = 10)->String
    {
        if let s=str
        {
            if s.characters.count>maximum
            {
                let index = s.endIndex.advancedBy(maximum-s.characters.count)
                return s.substringToIndex(index)
            }
            else
            {
                return s+String(count: maximum-s.characters.count, repeatedValue: (" " as Character))
            }
        }
        
        return "--------"
    }
    
    /**
     Outputs the table in a nice and clean format.
     */
    func output()
    {
        let table=get_songs()
        let space="\t\t"
        
        //artist name path repeats duration date
        var elements=["artist", "title", "path", "repeats", "duration", "start", "end", "date"]
        elements=elements.map{format($0)}
        print(elements.joinWithSeparator(space)+"\n")
        
        for row in table
        {
            let item: Array<String?>=[row["artist"],row["name"],row["path"],row["repeats"],row["duration"], row["start"], row["end"], row["date"]]
            
            let mapped: Array<String>=item.enumerate().map{$0 == item.count-1 ? format($1,20) : format($1)}
            
            print(mapped.joinWithSeparator(space))
        }
        print("\n\n")
    }
    
    
    
    /*
    Changes the start and end interval that the song plays.
    
    Parameters:
         - index:
         - start:
         - end:
    **/
    func change_interval_play(index:Int, _ start: String, _  end: String)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let key=defaultsKeys.testKey
        
        if var data_music = defaults.arrayForKey(key)
        {
            var tmp:Dictionary<String, String>=data_music[index] as! Dictionary<String, String>
            
            tmp["start"] = start
            tmp["end"] = end
            
            data_music[index]=tmp
            
            defaults.setValue(data_music, forKey: key)
        }
    }
    

    func get_index_from_path(path: String) -> Int?
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let key=defaultsKeys.testKey
        
        if var data_music = defaults.arrayForKey(key)
        {
            for i in 0..<data_music.count
            {
                if data_music[i]["path"] as! String==path
                {
                    return i
                }
            }
        }
        
        return nil
    }
    
    
    /*
    
    =============================
    
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
    
    
    func getImage(path: String) -> UIImage?
    {
        let fileManager = NSFileManager.defaultManager()
        let URL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        if let documentDirectoryURL = URL.first
        {
            let documentPath = documentDirectoryURL.URLByAppendingPathComponent(path+".mp3") // get path to song
            
            return return_mp3_info(documentPath).image
        }
        return nil
    }
    
}