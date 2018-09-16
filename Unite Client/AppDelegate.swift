//
//  AppDelegate.swift
//  Unite Client
//
//  Created by Daniel Royer on 8/10/18.
//  Copyright © 2018 Union Interpretation Team (UnITe). All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var window: UIWindow?
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch (status)
        {
        case .restricted, .denied:
            disableMyAlwaysFeatures()
            break
        case .authorizedAlways:
            enableMyAlwaysFeatures()
            break;
        case .authorizedWhenInUse:
            disableMyAlwaysFeatures()
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        doPost(isJoining: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        doPost(isJoining: false)
    }
    
    func doPost(isJoining: Bool) {
        let url = URL(string: "https://uniteserver.herokuapp.com")
        var json = [String:Any]()
        
        json["join"] = isJoining
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.httpBody = data
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        } catch {
            
        }
    }
    
    func enableLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted, .denied:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedAlways:
            enableMyAlwaysFeatures()
            break
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func enableMyAlwaysFeatures()
    {
        let geofenceRegionCenter = CLLocationCoordinate2DMake(36.065134, -95.869640)
        
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: 50, identifier: "Buttle")
        
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        locationManager.startMonitoring(for: geofenceRegion)
    }
    
    func disableMyAlwaysFeatures()
    {
        locationManager.stopMonitoring(for: locationManager.monitoredRegions.first!)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        enableLocationServices()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

