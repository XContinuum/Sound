//
//  ViewController.swift
//  Sound
//
//  Created by Michel Balamou on 2016-10-28.
//  Copyright © 2016 mm. All rights reserved.
//

import UIKit


class ViewController: UIViewController
{
    
    @IBOutlet var Paging: UIScrollView!
    var A: LocalPlaylist!
    var B: Player!
    var C: Youtube!
    
    var download=false
    
    // Error box
    @IBOutlet var ErrorBox: UIView! // y=226 px
    @IBOutlet var ErrorMsg: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        
        A = LocalPlaylist(nibName: "LocalPlaylist", bundle: nil)
        B = Player(nibName: "Player", bundle: nil)
        C = Youtube(nibName: "Youtube", bundle: nil)
        
        
        self.addChildViewController(A)
        self.addChildViewController(B)
        self.addChildViewController(C)
        
        Paging.addSubview(A.view)
        Paging.addSubview(B.view)
        Paging.addSubview(C.view)
        
        
        var mainFrame=A.view.frame
        mainFrame.origin.x=mainFrame.size.width
        B.view.frame=mainFrame
        mainFrame.origin.x=mainFrame.size.width*2
        C.view.frame=mainFrame
        
        Paging.contentSize=CGSize(width: mainFrame.size.width*3, height: mainFrame.size.height)
        
        
        /// Initialize closures
        A.play_song={(music_data: Dictionary<String, String>) -> Void in
            self.B.play_song(music_data)
            self.Paging.setContentOffset(CGPoint(x: self.Paging.frame.width, y: 0), animated: true)
        }
        
        C.updateSongs={() in self.A.reloadList()}
        
        B.errorDisplay=display_error
        C.errorDisplay=display_error
        
        display_error("None")
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
    ///
    func display_error(_ msg: String)
    {
        ErrorMsg.text=msg
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations:
            { _ -> Void in
       
                var frame=self.ErrorBox.frame
                frame.origin.y=227
                
                self.ErrorBox.frame=CGRect(x: frame.origin.x,y: 227,width: frame.size.width,height: frame.size.height)
            }, completion: {_ in print("Done")})
        
        
    }
    
    @IBAction func hide_msg_box(_ sender: UIButton)
    {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations:
            { _ -> Void in
                
                var frame=self.ErrorBox.frame
                frame.origin.y=667
                
                self.ErrorBox.frame=frame//CGRectMake(frame.origin.x,227,frame.size.width,frame.size.height)
                
            }, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
