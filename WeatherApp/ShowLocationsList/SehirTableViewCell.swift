//
//  SehirTableViewCell.swift
//  WeatherApp
//
//  Created by Ahmet on 14.07.2023.
//

import UIKit

class SehirTableViewCell: UITableViewCell {

    

    @IBOutlet weak var konumLabel: UILabel!
    @IBOutlet weak var dereceLabel: UILabel!
    @IBOutlet weak var sehirAdıLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
