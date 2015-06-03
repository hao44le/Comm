//
//  MainViewController.swift
//  Comm
//
//  Created by Gelei Chen on 15/6/2.
//  Copyright (c) 2015年 Transnew LLC. All rights reserved.
//

import UIKit

class MainViewController: UIViewController,SINCallClientDelegate {
    @IBAction func tapped(sender: AnyObject) {
        self.receriptText.resignFirstResponder()
    }

    @IBOutlet weak var receriptText: UITextField!
    
    @IBAction func callPressed(sender: AnyObject) {
        if receriptText.text != "" {
            if self.client?.isStarted() != nil{
                let call = self.client?.callClient().callUserWithId(self.receriptText.text)
                self.performSegueWithIdentifier("toCall", sender: call)
            }
        }
    }
    
    let client = (UIApplication.sharedApplication().delegate as! AppDelegate).client
    override func viewDidLoad() {
        super.viewDidLoad()
        self.client?.callClient().delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK : SINCallClientDelegate
    func client(client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        println("receive")
        self.performSegueWithIdentifier("toCall", sender: call)
    }

    func client(client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        let noti = SINLocalNotification()
        noti.alertAction = "Answer"
        noti.alertBody = "Incoming call from \(call.remoteUserId)"
        return noti
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! CallViewController
        vc.call = sender as? SINCall
    }
    

}
