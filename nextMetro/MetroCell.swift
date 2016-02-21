//
//  MetroCell.swift
//  STIB-widget
//
//  Created by Alex Gaspar on 17/02/16.
//  Copyright © 2016 Alex Gaspar. All rights reserved.
//

import UIKit

class MetroCell: UITableViewCell {
  


    @IBOutlet weak var metroLine: UILabel!
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var minutesLeft: UILabel!


    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCellWithData(time: String, line: String, name: String, color: CGColor) -> MetroCell{
        self.minutesLeft?.text = time
        self.stationName?.text = name
        
        self.metroLine?.text = line
        self.metroLine?.layer.backgroundColor = color
        self.metroLine?.layer.cornerRadius = 5
        
        return self
    }
    
}
