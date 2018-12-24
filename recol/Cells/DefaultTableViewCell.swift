//
//  DefaultTableViewCell.swift
//  recol
//
//  Created by Brian on 9/25/18.
//  Copyright © 2018 Farhad Saadatpei. All rights reserved.
//

import UIKit

class DefaultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var expires: UILabel!
    @IBOutlet weak var remaining: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var noteAvailibility: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.container.layer.masksToBounds = false
        self.container.layer.shadowColor = UIColor.black.cgColor
        self.container.layer.shadowOpacity = 0.09
        self.container.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        self.container.layer.shadowRadius = 7
        self.container.layer.cornerRadius = 5
        
        //Amount
        self.amount.layer.masksToBounds = true
        self.amount.layer.borderColor = UIColor.lightGray.cgColor
        self.amount.layer.borderWidth = 0.8
        self.amount.layer.cornerRadius = 3

        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
