//
//  AppDelegate.swift
//  Comm
//
//  Created by Gelei Chen on 15/6/2.
//  Copyright (c) 2015年 Transnew LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,SINClientDelegate,SINCallClientDelegate,SINManagedPushDelegate {

    var window: UIWindow?
    var client: SINClient?
    var push:SINManagedPush?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        self.push = Sinch.managedPushWithAPSEnvironment(SINAPSEnvironment.Development)
        self.push?.delegate = self
        self.push?.setDesiredPushTypeAutomatically()
        
        
        
        if let localNotification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            println("1")
            self.handleLocationNotification(localNotification)
        }
        self.requestUserNotificationPermission()

        
        NSNotificationCenter.defaultCenter().addObserverForName("UserDidLoginNotification", object: nil, queue: nil) { (note: NSNotification?) in
            //self.variable?.myMethod()
            let userID = note!.userInfo!["userID"] as! String
            NSUserDefaults.standardUserDefaults().setObject(userID, forKey: "userID")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.push?.registerUserNotificationSettings()
            self.initClient(userID)
            return
        }
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        self.handleLocationNotification(notification)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.push?.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        self.push?.application(application, didReceiveRemoteNotification: userInfo)
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("error: \(error.description)")
    }
    
    func requestUserNotificationPermission(){
        let types = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)

    }
    // MARK: Required Stuff
    func initClient(userID:String){
        self.client = Sinch.clientWithApplicationKey("6a4e9dd3-4248-4f6f-8764-7168f9990b83", applicationSecret: "srTBK5Z4jECQ919ej2k4CA==", environmentHost: "sandbox.sinch.com", userId: userID)
        client!.delegate = self
        client!.setSupportCalling(true)
        client!.setSupportActiveConnectionInBackground(true)
        client!.start()
        client!.startListeningOnActiveConnection()
    }
    
    func handleLocationNotification(notification:UILocalNotification){
        let result = self.client?.relayLocalNotification(notification)
        if (result?.isCall() == true) {
            if (result?.callResult().isTimedOut == true) {
                let alert = UIAlertView(title: "Missed Call", message: "Missed Call from \(result?.callResult().remoteUserId)", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
                alert.show()
            }
        }
    }
    
    func handleRemoteNotification(userInfo:NSDictionary){
        if client == nil {
            if let userID: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("userID") {
                self.initClient(userID as! String)
            }
            
        }
        self.client?.relayRemotePushNotification(userInfo as [NSObject : AnyObject])
    }
    
    
    // MARK: SINClientDelegate
    
    func clientDidStart(client: SINClient!) {
        println("Sinch client started successfully\(Sinch.version())")
    }
    
    func clientDidFail(client: SINClient!, error: NSError!) {
        println("Sinch client error : \(error.localizedDescription)")
    }
    
    func client(client: SINClient!, logMessage message: String!, area: String!, severity: SINLogSeverity, timestamp: NSDate!) {
        if severity == SINLogSeverity.Critical {
            println(message)
        }
    }
    
    // MARK: SINManagedPushDelegate
    func managedPush(managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [NSObject : AnyObject]!, forType pushType: String!) {
        self.handleRemoteNotification(payload)
    }
    
    // MARK: SINCallClientDelegate
    func client(client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        var top = self.window?.rootViewController
        while (top?.presentedViewController != nil) {
            top = top?.presentedViewController
        }
        top?.performSegueWithIdentifier("toCall", sender: call)
    }
    
    func client(client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        let noti = SINLocalNotification()
        noti.alertAction = "Answer"
        noti.alertBody = "Incoming call from \(call.remoteUserId)"
        return noti
    }
    

}

