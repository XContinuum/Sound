//
//  LocalPlaylist.swift
//  Sound
//
//  Created by Michel Balamou on 2016-10-29.
//  Copyright © 2016 mm. All rights reserved.
//

import UIKit

class LocalPlaylist: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var PlayList: UITableView!
    
    var Data=Database()
    var items:Array<Dictionary<String,String>> = []
    var play_song:((Dictionary<String, String>) -> Void)?
    
    var selected_cell:UIColor = UIColor.init(red: (44)/255.0, green: (44)/255.0, blue: (44)/255.0, alpha: 1.0)
    var non_selected_cell:UIColor = UIColor.init(red: (49)/255.0, green: (49)/255.0, blue: (49)/255.0, alpha: 1.0)
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        PlayList.dataSource=self
        PlayList.delegate=self
        
       // Data.clean_up()
        Data.output()
        items=Data.get_songs_reversed()
        
        ///Register cell
        let nibName = UINib(nibName: "PlayListCell", bundle:nil)
        self.PlayList.register(nibName, forCellReuseIdentifier: "PlayListUID")
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    

    /**
     
     TABLE ~~~~~~~~~~~~~~~~~~~~~~~
     
     **/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayListUID", for: indexPath) as! PlayListCell
        cell.Song?.text=items[indexPath.row]["name"]
        cell.Artist?.text=items[indexPath.row]["artist"]
        
        if let path=items[indexPath.row]["path"]
        {
            cell.Img?.image=Data.getImage(path)
        }
        
        if cell.isSelected
        {
            cell.backgroundColor = selected_cell
        }
        else
        {
            cell.backgroundColor = non_selected_cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        play_song?(items[indexPath.row])
    }
    
    func reloadList()
    {
        items=Data.get_songs_reversed()
        PlayList.reloadData()
    }
}
