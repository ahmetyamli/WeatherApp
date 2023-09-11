//
//  mainViewController.swift
//  WeatherApp
//
//  Created by Ahmet on 4.07.2023.
//

import UIKit

class mainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    
    @IBAction func gunlukTiklandi(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func haftalikTiklandi(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "haftalikViewController") as! haftalikViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
