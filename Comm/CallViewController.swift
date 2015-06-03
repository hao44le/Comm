//
//  CallViewController.swift
//  Comm
//
//  Created by Gelei Chen on 15/6/2.
//  Copyright (c) 2015年 Transnew LLC. All rights reserved.
//

import UIKit

class CallViewController: UIViewController,SINCallDelegate {

    @IBOutlet weak var remoteUserName: UILabel!
    
    @IBOutlet weak var status: UILabel!
    
    @IBOutlet weak var hangupButton: UIButton!
    @IBOutlet weak var anserButton: UIButton!
    
    @IBOutlet weak var declineButton: UIButton!
    
    @IBAction func anser(sender: UIButton) {
        self.audioController?.stopPlayingSoundFile()
        self.call?.answer()
    }
    
    @IBAction func decliene(sender: UIButton) {
        self.call?.hangup()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func hangup(sender: AnyObject) {
        self.call?.hangup()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    var call:SINCall?
    var durationTimer:NSTimer?
    let audioController = (UIApplication.sharedApplication().delegate as! AppDelegate).client?.audioController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        call?.delegate = self
        if self.call?.direction == SINCallDirection.Incoming{
            self.setCallStatusText("")
            self.showButtons("AnswerOrDecline")
            self.audioController?.startPlayingSoundFile(self.pathForSond("incoming.wav"), loop: true)
        } else {
            self.setCallStatusText("calling")
            self.showButtons("hangup")
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.remoteUserName.text = self.call?.remoteUserId
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCallStatusText(text:String){
        self.status.text = text
    }
    /*
    func setDuration(seconds:NSInteger){
        let result = Int(seconds / 60).description + ":" + Int(seconds%60).description
        self.setCallStatusText(result)
    }
    func startCallDurationTimerWithSelector(){
        self.durationTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "test", userInfo: nil, repeats: true)
    }

    func stopCallDurationTimer(){
        self.durationTimer?.invalidate()
        self.durationTimer = nil
    }*/
    
    func showButtons(type:String){
        if type == "AnswerOrDecline" {
            self.anserButton.hidden = false
            self.declineButton.hidden = false
            self.hangupButton.hidden = true
        } else if type == "hangup"{
            self.hangupButton.hidden = false
            self.anserButton.hidden = true
            self.declineButton.hidden = true
        }
    }
    
    
    // MARK: SINCallDelegate
    func callDidProgress(call: SINCall!) {
        self.status.text = "ringing"
        self.audioController?.startPlayingSoundFile(self.pathForSond("ringback.wav"), loop: true)
    }
    func callDidEstablish(call: SINCall!) {
        let dur = NSDate().timeIntervalSinceDate((self.call?.details.establishedTime)!)
        let duration = NSInteger(dur)
        self.status.text = "speaking now"
        //self.setDuration(duration)
        //self.startCallDurationTimerWithSelector()
        self.showButtons("hangup")
        self.audioController?.stopPlayingSoundFile()
    }
    func callDidEnd(call: SINCall!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.audioController?.stopPlayingSoundFile()
        //self.stopCallDurationTimer()
    }
    
    // MARK: Sounds
    func pathForSond(soundName:String)->String{
        return (NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(soundName))!
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
