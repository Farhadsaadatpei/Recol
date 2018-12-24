//
//  HeaderTableViewCell.swift
//  recol
//
//  Created by Brian on 10/18/18.
//  Copyright © 2018 Farhad Saadatpei. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var totalOfAccounts: CGFloat!
    var totalRecurringAmount: CGFloat!
    var presentationType: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    var shadowView: CAShapeLayer!
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCollectionViewCell", for: indexPath as IndexPath ) as! HeaderCollectionViewCell
        
        let statisticBackground = UIImageView(image: UIImage(named: "Static Background"))
        statisticBackground.frame = cell.container.frame
        statisticBackground.contentMode = .scaleAspectFit
        cell.container.addSubview(statisticBackground)
        cell.container.sendSubviewToBack(statisticBackground)
        
        
        //Animation Count
        cell.intCount.method = .easeOut
        
        //Types
        if indexPath.row == 0 {
            if totalOfAccounts != nil {
                cell.icon.image = UIImage(named: "folder box")
                cell.intCount.format = "%.0f"
                cell.intCount.countFrom(0, to: totalOfAccounts, withDuration: 2.0)
            }
            cell.presentationType.text = "Total of Accounts"
        } else {
            cell.icon.image = UIImage(named: "Money Circle")
            cell.intCount.format = "$%.2f"
            if totalRecurringAmount != nil {
                cell.intCount.countFrom(0, to: totalRecurringAmount, withDuration: 2.0)
            }
    
            cell.presentationType.text = "Monthly Recurrings"
        }
        
        //cell.container.layer.insertSublayer(shadowView, at: 0)
        
        return cell
    }

}
