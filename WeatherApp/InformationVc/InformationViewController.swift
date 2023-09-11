//
//  InformationViewController.swift
//  WeatherApp
//
//  Created by Ahmet on 6.07.2023.
//

import UIKit
import CoreData


class InformationViewController: UIViewController {
    
    
    @IBOutlet weak var sectionHeaderLabel: CollectionReusableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ruzgarHızıLabel: UILabel!
    @IBOutlet weak var rakımLabel: UILabel!
    @IBOutlet weak var havaDurumuLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var sehirIsmiLabel: UILabel!
    @IBOutlet weak var dereceLabel: UILabel!
    
    var secilenYerIsmi = ""
    var secilenYerId: UUID?
    var latitudeString = ""
    var longitudeString = ""
    
    var cityModule : CityModule?
    
    var dailyWeatherData: [DailyWeather] = []
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

        sehirIsmiLabel.text = secilenYerIsmi
        
        test()
        veriAl()
        updateWeatherData()
        collectionView.reloadData()
    }
    
    
    
    // CORE DATADAN VERİ ÇEKİMİ
    
    func veriAl() {
        let group = DispatchGroup()
        group.enter()

        if let uuidString = secilenYerId?.uuidString {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
            fetchRequest.predicate = NSPredicate(format: "id == %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false

            do {
                let sonuclar = try context.fetch(fetchRequest)

                if let sonuc = sonuclar.first as? NSManagedObject {
                    if let latitude = sonuc.value(forKey: "latitude") as? Double {
                       latitudeString = String(latitude)
                    }

                    if let longitude = sonuc.value(forKey: "longitude") as? Double {
                        longitudeString = String(longitude)
                    }
                }
            } catch {
                print("Hata: \(error.localizedDescription)")
            }
        }

        group.leave()

        group.notify(queue: .main) { [weak self] in
            self?.test()
        }
    }

    
    
    
    
    // İNTERNETTEN VERİ ÇEKME
    
    var weatherData: Empty?
    
    func test() {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(cityModule!.latitude!)&lon=\(cityModule!.longitude!)&appid=6578caad0d61fb9907e3dbec68a0f41b"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("HTTP İstek Hatası: \(error)")
                    return
                }

                guard let data = data else {
                    print("Hata: Veri alınamadı")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let weatherData = try decoder.decode(Empty.self, from: data)
                    self?.weatherData = weatherData
                    self?.splitWeatherData()
                    self?.updateWeatherData()

                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                } catch let error {
                    print("JSON Decode Hatası: \(error)")
                }
            }
            task.resume()
        } else {
            print("Geçersiz URL")
        }
    }


    
    func splitWeatherData() {
        guard let currentData = weatherData else {
            return
        }

        var currentDate: String?
        var dailyWeather: DailyWeather?

        for item in currentData.list {
            let date = item.dtTxt.components(separatedBy: " ").first ?? ""
            if date != currentDate {
                if let daily = dailyWeather {
                    dailyWeatherData.append(daily)
                }
                dailyWeather = DailyWeather(date: date, hourlyWeather: [])
                currentDate = date
            }

            let hourlyWeather = HourlyWeather(time: item.dtTxt, temperature: item.main.temp, weatherId: item.weather.first?.id ?? 0)
            dailyWeather?.hourlyWeather.append(hourlyWeather)
        }

        if let daily = dailyWeather {
            dailyWeatherData.append(daily)
        }
    }

       

    
    
    
    //ÇEKİLEN VERİLERİ GÖSTER
    
    
    
    var weatherId: Int = 0
    
    func updateWeatherData() {
        guard let currentData = weatherData else {
            return
        }
        

        if let firstListItem = currentData.list.first {
            
            
            DispatchQueue.main.async {
                let temperature = firstListItem.main.temp
                let celciusTemp = Int(temperature - 273)
                self.dereceLabel.text = "\(celciusTemp)°"
                self.rakımLabel.text = "Rakım:" + "\(firstListItem.main.seaLevel)"
                self.ruzgarHızıLabel.text = "Rüzgar Hızı: \(currentData.list[1].wind.speed)"
                self.sehirIsmiLabel.text = currentData.city.name
                    
                
                    
                if let weatherDescription = firstListItem.weather.first?.id{
                    self.weatherId = weatherDescription
                }

                if self.weatherId >= 801 && 804 >= self.weatherId{
                    self.iconImage.image = UIImage(named: "cloud")
                    self.havaDurumuLabel.text = "Hava Bulutlu"
                }else if self.weatherId == 800 {
                    self.iconImage.image = UIImage(named: "sun")
                    self.havaDurumuLabel.text = "Hava Güneşli"
                }else if self.weatherId >= 600 && 622 >= self.weatherId{
                    self.iconImage.image = UIImage(named: "cloud")
                    self.havaDurumuLabel.text = "Hava Karlı"
                }else if self.weatherId >= 200 && 531 >= self.weatherId{
                    self.iconImage.image = UIImage(named: "rain")
                    self.havaDurumuLabel.text = "Hava Yağmurlu"
                }else if self.weatherId >= 701 && 781 >= self.weatherId{
                    self.iconImage.image = UIImage(named: "cloud")
                    self.havaDurumuLabel.text = "Hava Bozuk"
                }else{
                    self.iconImage.image = UIImage(named: "sun")
                }
                
            }
            
//            let temperature = firstListItem.main.temp
//            let celciusTemp = Int(temperature - 273)
//            dereceLabel.text = "\(celciusTemp)°"
//            rakımLabel.text = "Rakım:" + "\(firstListItem.main.seaLevel)"
//            ruzgarHızıLabel.text = "Rüzgar Hızı: \(currentData.list[1].wind.speed)"
//            sehirIsmiLabel.text = currentData.city.name
//
//
//
//            if let weatherDescription = firstListItem.weather.first?.id{
//                weatherId = weatherDescription
//            }
//
//            if weatherId >= 801 && 804 >= weatherId{
//                iconImage.image = UIImage(named: "cloud")
//                havaDurumuLabel.text = "Hava Bulutlu"
//            }else if weatherId == 800 {
//                iconImage.image = UIImage(named: "sun")
//                havaDurumuLabel.text = "Hava Güneşli"
//            }else if weatherId >= 600 && 622 >= weatherId{
//                iconImage.image = UIImage(named: "cloud")
//                havaDurumuLabel.text = "Hava Karlı"
//            }else if weatherId >= 200 && 531 >= weatherId{
//                iconImage.image = UIImage(named: "rain")
//                havaDurumuLabel.text = "Hava Yağmurlu"
//            }else if weatherId >= 701 && 781 >= weatherId{
//                iconImage.image = UIImage(named: "cloud")
//                havaDurumuLabel.text = "Hava Bozuk"
//            }else{
//                iconImage.image = UIImage(named: "sun")
//            }
        }
    }
    
    
   
}


extension InformationViewController:  UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell

//        cell.tableView.dataSource = cell
//        cell.tableView.delegate = cell

        
//        let dailyWeather = dailyWeatherData[indexPath.section]


//        cell.dereLabel1.text = dailyWeather.hourlyWeather[0].time.suffix(8) + ": " + String(format: "%.1f", dailyWeather.hourlyWeather[0].temperature - 273)  + "°"

//        cell.dereceLabel2.text = dailyWeather.hourlyWeather[1].time
        cell.dailyWeatherData2 = dailyWeatherData
        cell.günler = indexPath.section
        
        cell.tableView.reloadData()

//        print(dailyWeather.hourlyWeather.count)
        
        
        

            if dailyWeatherData[indexPath.section].hourlyWeather[indexPath.row].weatherId >= 801 && 804 >= dailyWeatherData[indexPath.section].hourlyWeather[indexPath.row].weatherId {
                cell.imageView.image = UIImage(named: "cloud")
            } else if dailyWeatherData[indexPath.section].hourlyWeather[indexPath.row].weatherId == 800 {
                cell.imageView.image = UIImage(named: "sun")
            } else if dailyWeatherData[indexPath.section].hourlyWeather[indexPath.row].weatherId >= 600 && 622 >= dailyWeatherData[indexPath.section].hourlyWeather[indexPath.row].weatherId {
                cell.imageView.image = UIImage(named: "cloud")
            } else if dailyWeatherData[indexPath.section].hourlyWeather[indexPath.row].weatherId >= 200 && 531 >= dailyWeatherData[indexPath.section].hourlyWeather[indexPath.row].weatherId {
                cell.imageView.image = UIImage(named: "rain")
            } else if dailyWeatherData[indexPath.section].hourlyWeather[indexPath.row].weatherId >= 701 && 781 >= dailyWeatherData[indexPath.section].hourlyWeather[indexPath.row].weatherId {
                cell.imageView.image = UIImage(named: "cloud")
            }
        return cell
    }

     
 
     func numberOfSections(in collectionView: UICollectionView) -> Int {
         return dailyWeatherData.count
     }
    
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return 0// Hücreler arasındaki yatay uzaklık değerini belirleyin
     }
    

     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 0 // Hücreler arasındaki dikey uzaklık değerini belirleyin
     }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? CollectionReusableView{
            sectionHeader.dateLabel.text = dailyWeatherData[indexPath.section].date
            return sectionHeader
        }
        return UICollectionReusableView()
    }
     
     
    
}









