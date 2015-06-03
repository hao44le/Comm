//
//  ViewController.swift
//  Comm
//
//  Created by Gelei Chen on 15/6/2.
//  Copyright (c) 2015年 Transnew LLC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var nameText: UITextField!

    @IBAction func locationPressed(sender: UIButton) {
        if self.nameText.text == "" {
            return
        }
        NSNotificationCenter.defaultCenter().postNotificationName("UserDidLoginNotification", object: nil, userInfo: ["userID":self.nameText.text])
        self.performSegueWithIdentifier("toMain", sender: nil)
    }
    
    @IBAction func tapped(sender: AnyObject) {
        self.nameText.resignFirstResponder()
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.nameText.becomeFirstResponder()
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toCall" {
            let vc = segue.destinationViewController as! CallViewController
            vc.call = sender as? SINCall
        }
    }


}

