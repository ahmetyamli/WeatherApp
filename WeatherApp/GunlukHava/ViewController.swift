//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ahmet on 3.07.2023.
//

import UIKit
import CoreLocation   


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var ruzgarHızıLabel: UILabel!
    @IBOutlet weak var saatLabel: UILabel!
    @IBOutlet weak var sehirIsmiLabel: UILabel!
    @IBOutlet weak var havaDurumuLabel: UILabel!
    @IBOutlet weak var dereceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    //Konum atamaları
    
    let locationManager = CLLocationManager()
    var konum = CLLocationCoordinate2D()
    var konumLatitude = ""
    var konumLongitude = ""
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        updateWeatherData()
    }
    
    
    
    //KONUM FONKSİYONLARI
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first{
            konum = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
            konumLatitude = String(format: "%.6f", konum.latitude)
            konumLongitude = String(format: "%.6f", konum.longitude)
            test()
        }
    }
    
    
    
    
    
    //İNTERNETTEN VERİ ÇEKME
    var weatherData: Empty?
    
    
    
    func test() {
        
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(konumLatitude)&lon=\(konumLongitude)&appid=6578caad0d61fb9907e3dbec68a0f41b"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let weatherData = try decoder.decode(Empty.self, from: data)
                        DispatchQueue.main.async {
                            self?.weatherData = weatherData // Değişiklik burada
                            self?.updateWeatherData() // updateWeatherData() fonksiyonunu çağırın
                            
                        }
                    } catch {
                        print("JSON Decode Error: \(error.localizedDescription)")
                    }
                } else if let error = error {
                    print("HTTP Request Failed: \(error)")
                }
            }
            task.resume()
        }
    }
    
    
    
    //ÇEKİLEN VERİLERİ GÖSTER
    
    
    
    func updateWeatherData() {
        guard let currentData = weatherData else {
            return
        }
        
        if let firstListItem = currentData.list.first {
            
            var weatherId: Int = 0
            let celciusTemp = Int(firstListItem.main.temp - 273)
            
            dereceLabel.text = "\(celciusTemp) C°"
            saatLabel.text = "Rakım:" + "\(firstListItem.main.seaLevel)"
            ruzgarHızıLabel.text = "Rüzgar Hızı: \(currentData.list[1].wind.speed)"
            sehirIsmiLabel.text = currentData.city.name
            
            
            if let weatherDescription = firstListItem.weather.first?.id{
                weatherId = weatherDescription
            }
            
            
            if weatherId >= 801 && 804 >= weatherId{
                imageView.image = UIImage(named: "cloud")
                havaDurumuLabel.text = "Hava Bulutlu"
            }else if weatherId == 800 {
                imageView.image = UIImage(named: "sun")
                havaDurumuLabel.text = "Hava Güneşli"
            }else if weatherId >= 600 && 622 >= weatherId{
                imageView.image = UIImage(named: "cloud")
                havaDurumuLabel.text = "Hava Karlıı"
            }else if weatherId >= 200 && 531 >= weatherId{
                imageView.image = UIImage(named: "rain")
                havaDurumuLabel.text = "Hava Yağmurlu"
            }else if weatherId >= 701 && 781 >= weatherId{
                imageView.image = UIImage(named: "cloud")
                havaDurumuLabel.text = "Hava Bozuk"
                
            }
        }
    }
    
    
    
    
}
