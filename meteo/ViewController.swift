//
//  ViewController.swift
//  meteo
//
//  Created by Anais Asmar on 10/05/2016.
//  Copyright © 2016 Anais Asmar. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var CityNameTextField: UITextField!
    @IBOutlet weak var CityNameLabel: UILabel!
    @IBOutlet weak var CityTempLabel: UILabel!
    @IBOutlet weak var CityWeatherImg: UIImageView!
    
    var cityNameLocalisation: String = ("" as String?)!
    
    let LocationManager = CLLocationManager()
    
    @IBAction func GetDataButtun(sender: AnyObject) {
        
        
        if (endsWithEdu(CityNameTextField.text!) == true) {
            
            
            let params:NSString = CityNameTextField.text!
            
                let newParams = params.stringByReplacingOccurrencesOfString(" ", withString: "-")
            
                let url:NSURL = NSURL(string:"http://api.openweathermap.org/data/2.5/weather?q=\(newParams)&APPID=a74b07463901e2cc9c3ea58f5b55ba3e")!
                let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)

            
            
            
            request.HTTPMethod = "GET"
            var response: NSURLResponse?
            
            var urlData: NSData?
            
            do {
                
                urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
                
            } catch let reponseError as NSError {
                
                print("Erreur : \(reponseError)")
                
                urlData = nil
                
            } catch {
                
                fatalError()
                
            }
            
            if (CityNameTextField.text != "") {
                
                
                if (urlData != nil) {
                    
                    let res = response as! NSHTTPURLResponse!
                    
                    NSLog("Response code: %ld", res.statusCode)
                    
                    
                    if (res.statusCode >= 200 && res.statusCode < 300) {
                        
                        let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        var jsonData:NSDictionary = NSDictionary()
                        
                        do {
                            
                            jsonData = try NSJSONSerialization.JSONObjectWithData(urlData!,options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            
                        } catch let error as NSError {
                            
                            print("Erreur : \(error)")
                            
                        }
                        
                        let cod = jsonData.valueForKey("cod") as? NSString
                        
                        if (cod != "404") {
                            
                            let nameCity:NSString = jsonData.valueForKey("name") as! NSString
                            
                            CityNameLabel.text = nameCity as String
                            
                            if let mainTemp = jsonData.valueForKey("main") as? [String: AnyObject] {
                                if let TempCity = mainTemp["temp"] as? Int {
                                    print("\(TempCity)")
                                    
                                    let tempCelsius:Int = TempCity - 273
                                    
                                    let tempCelsiusString = String(tempCelsius)
                                    CityTempLabel.text = tempCelsiusString as String
                                    
                                    let tokenDict: NSArray = jsonData["weather"] as! NSArray
                                    let finalData:NSObject = tokenDict[0] as! NSObject
                                    
                                    let iconWeather:String = finalData.valueForKey("icon") as! String
                                    print(iconWeather)
                                    
                                    let ShowedImg = UIImage(named: iconWeather)! as UIImage;
                                    
                                    CityWeatherImg.image = ShowedImg

                                }
                            }
                            
                        } else {
                            afficheMessageAlerte("Nom introuvable", messageAlert: "Veuillez rentrer un nom de ville correct", boutonAlert: "OK")
                        }
                        
                    } else {
                        
                        afficheMessageAlerte("Erreur Http", messageAlert: "La connection au serveur à échoué", boutonAlert: "OK")
                    }
                    
                } else {
                    
                    afficheMessageAlerte("Erreur API", messageAlert: "La connection de à l'API à échoué", boutonAlert: "OK")
                    
                }
            } else{
                afficheMessageAlerte("Champs vide", messageAlert: "Veulliez entrer un nom de ville", boutonAlert: "OK")
            }
            
            
            
        } else {
            CityNameTextField.text = cityNameLocalisation
            afficheMessageAlerte("Caractere incorrect", messageAlert: "Veulliez ne pas entrer de chiffre", boutonAlert: "OK")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.LocationManager.delegate = self
        self.LocationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.LocationManager.requestWhenInUseAuthorization()
        self.LocationManager.startUpdatingLocation()
        
        CityNameLabel.text = ""
        CityTempLabel.text = ""
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {
            (placemarks, error) -> Void in
            
            if error != nil {
                print("Error")
            }
            
            if let pm = placemarks?.first {
                self.displayLocationInfo(pm)
            } else {
                print("Error data")
            }
        })
    }
    
    func displayLocationInfo (placemark: CLPlacemark){
        self.LocationManager.stopUpdatingLocation()
        NSLog(placemark.locality!)
        
        cityNameLocalisation = placemark.locality!
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error:" + error.localizedDescription)
    }
    
    func afficheMessageAlerte(titleAlert: String, messageAlert: String, boutonAlert: String) {
        
        let monAlert = UIAlertController(title: titleAlert, message: messageAlert, preferredStyle: .Alert)
        
        let monAction = UIAlertAction(title: boutonAlert, style: .Default, handler: nil)
        
        monAlert.addAction(monAction)
        
        self.presentViewController(monAlert, animated: true, completion: nil)

    }
    
    func endsWithEdu(str : String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "[A-Z]", options: [.CaseInsensitive])
        return regex.numberOfMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count)) > 0
    }
    
}