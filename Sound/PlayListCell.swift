//
//  PlayListCell.swift
//  Sound
//
//  Created by Michel Balamou on 2016-10-30.
//  Copyright © 2016 mm. All rights reserved.
//

import UIKit

class PlayListCell: UITableViewCell
{
    
    @IBOutlet var Song: UILabel!
    @IBOutlet var Artist: UILabel!
    @IBOutlet var Img: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
