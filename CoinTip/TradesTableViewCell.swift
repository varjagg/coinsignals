//
//  TradesTableViewCell.swift
//  CoinTip
//
//  Created by Eugene Zaikonnikov on 05/06/2018.
//  Copyright © 2018 Eugene Zaikonnikov. All rights reserved.
//

import UIKit

class TradesTableViewCell: UITableViewCell {

    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var amountBTC: UILabel!
    @IBOutlet weak var amountUSD: UILabel!
    @IBOutlet weak var transactionImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
