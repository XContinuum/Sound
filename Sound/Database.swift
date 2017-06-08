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
    func over_ten(_ n: Int) -> String
    {
        return n<10 ? "0\(n)" : "\(n)"
    }
    
    /**
     Gets current date
     
     - Returns: String with format hour:minute day-month-year
     */
    func get_date()->String
    {
        let date = Date()
        let calender = Calendar.current
        let components = (calender as NSCalendar).components([.year, .month, .day, .hour, .minute], from: date)
        
        let time=[over_ten(components.hour!),
                  over_ten(components.minute!),
            
                  over_ten(components.day!),
                  over_ten(components.month!),
                  over_ten(components.year!)]
        
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
    func add_song(_ artist:String, _ song_name: String, _ song_path: String, _ duration: String)
    {
        let defaults = UserDefaults.standard
        let piece=["artist":artist,
                   "name":song_name,
                   "path":song_path,
                   "repeats":"0",
                   "duration":duration,
                   "date":self.get_date()]
        
        let key=defaultsKeys.testKey
        
        if let data_music = defaults.array(forKey: key)
        {
            var new_data=data_music
            new_data.insert(piece, at: new_data.count)
            
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
    func clear_data(_ key:String)
    {
        let defaults = UserDefaults.standard
        defaults.setValue(nil, forKey: key)
    }
    
    /**
     Returns songs from the local database. If the songs are nil, it returns an empty array.
     */
    func get_songs() -> Array<Dictionary<String,String>>
    {
        let defaults = UserDefaults.standard
        let key=defaultsKeys.testKey
        
        return (defaults.array(forKey: key) as? Array<Dictionary<String,String>>) ?? []
    }
    
    /**
     Returns songs from the local database. If the songs are nil, it returns an empty array.
     */
    func get_songs_reversed() -> Array<Dictionary<String,String>>
    {
        let defaults = UserDefaults.standard
        let key=defaultsKeys.testKey
        let result=(defaults.array(forKey: key) as? Array<Dictionary<String,String>>) ?? []
        
        return result.reversed()
    }
    
    
    /**
     Deletes a rows from the database.
     
     - Parameter row: rows to delete, has to be always from greatest to lowest
     */
    func delete_rows(_ row:Array<Int>)
    {
        let defaults = UserDefaults.standard
        let key=defaultsKeys.testKey
       
        if var data_music = defaults.array(forKey: key)
        {
            for i in row
            {
                if i<data_music.count
                {
                   data_music.remove(at: i)
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
        let fileManager = FileManager.default
        
        let URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let documentDirectoryURL: Foundation.URL = URL.first
        {
            for i in 0...(table.count-1)
            {
                let documentPath = documentDirectoryURL.appendingPathComponent((table[i]["path"] ?? "") + ".mp3") // get path to song
                let soundData:Data? = try? Data(contentsOf: documentPath)
                
                if soundData==nil
                {
                    delete.append(i)
                }
            }
        }
        
        // Delete
        delete_rows(delete.sorted(by: >))
    }
    
    
    /**
     
     - Parameter str:
     - Parameter maximum:
     */
    func format(_ str:String?, _ maximum: Int = 10)->String
    {
        if let s=str
        {
            if s.characters.count>maximum
            {
                let index = s.characters.index(s.endIndex, offsetBy: maximum-s.characters.count)
                return s.substring(to: index)
            }
            else
            {
                return s+String(repeating: String((" " as Character)), count: maximum-s.characters.count)
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
        print(elements.joined(separator: space)+"\n")
        
        for row in table
        {
            let item: Array<String?>=[row["artist"],row["name"],row["path"],row["repeats"],row["duration"], row["start"], row["end"], row["date"]]
            
            let mapped: Array<String>=item.enumerated().map{$0 == item.count-1 ? format($1,20) : format($1)}
            
            print(mapped.joined(separator: space))
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
    func change_interval_play(_ index:Int, _ start: String, _  end: String)
    {
        let defaults = UserDefaults.standard
        let key=defaultsKeys.testKey
        
        if var data_music = defaults.array(forKey: key)
        {
            var tmp:Dictionary<String, String>=data_music[index] as! Dictionary<String, String>
            
            tmp["start"] = start
            tmp["end"] = end
            
            data_music[index]=tmp
            
            defaults.setValue(data_music, forKey: key)
        }
    }
    

    func get_index_from_path(_ path: String) -> Int?
    {
        let defaults = UserDefaults.standard
        let key=defaultsKeys.testKey
        
        if var data_music = defaults.array(forKey: key)
        {
            for i in 0..<data_music.count
            {
                if let pref = data_music[i] as? [String: Any]
                {
                    var prefToLoad = pref["path"] as! String
                    
                    if prefToLoad==path
                    {
                       return i
                    }
                }
            }
        }
        
        return nil
    }
    
    
    /*
    
    =============================
    
    */
    
    func return_mp3_info(_ path: URL) -> (title: String?, artist: String?, image: UIImage?)
    {
        var title : String?
        var artist : String?
        var img : UIImage?
        
        
        let playerItem = AVPlayerItem(url: path)
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
                
            case "artwork" where value is Data:
                img = UIImage(data: value as! Data)
                
            default:
                continue
            }
        }
        
        return (title, artist, img)
    }
    
    
    func getImage(_ path: String) -> UIImage?
    {
        let fileManager = FileManager.default
        let URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        if let documentDirectoryURL = URL.first
        {
            let documentPath = documentDirectoryURL.appendingPathComponent(path+".mp3") // get path to song
            
            return return_mp3_info(documentPath).image
        }
        return nil
    }
    
}
