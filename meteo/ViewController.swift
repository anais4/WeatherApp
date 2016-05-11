//
//  ViewController.swift
//  meteo
//
//  Created by Anais Asmar on 10/05/2016.
//  Copyright © 2016 Anais Asmar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var CityNameTextField: UITextField!    
    @IBOutlet weak var CityNameLabel: UILabel!
    @IBOutlet weak var CityTempLabel: UILabel!
    
    @IBAction func GetDataButtunClicked(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q=paris,FR")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getWeatherData(urlString: String){
        let url = NSURL(string: urlString)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.setLablels(data!)
            })
        }
        task.resume()
    }
    
    func setLablels(weatherData: NSData){
        
        //let json = try? NSJSONSerialization.JSONObjectWithData(weatherData, options: [], &jsonError) as NSDictionary
        
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(weatherData, options: []) as? NSDictionary {
                if let name = json["name"] as? String {
                    CityNameLabel.text = name
                }
                
                if let main = json["main"] as? NSDictionary{
                    if let temp = main["temp"] as? Double{
                        CityTempLabel.text = String(format: "%1.f", temp)
                    }
                }
                print(json)
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
}

