//
//  CollectionViewCell.swift
//  WeatherApp
//
//  Created by Ahmet on 10.07.2023.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dereceLabel2: UILabel!
    @IBOutlet weak var dereLabel1: UILabel!

    var dailyWeatherData2: [DailyWeather] = []
    var weatherData: Empty?
    var günler = 0
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
   
}



extension CollectionViewCell: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        

        return dailyWeatherData2[günler].hourlyWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        let dailyWeather = dailyWeatherData2[günler]
        let hourlyWeather = dailyWeather.hourlyWeather[indexPath.row]
            
        let time = hourlyWeather.time.suffix(8)
        let temperature = String(format: "%.1f", hourlyWeather.temperature - 273)
            
            tableCell.cellLabel.text = "\(time) = \(temperature)°"
            
        return tableCell
    }
    
    
 

}
