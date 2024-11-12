//
//  CustomViewCellTableViewCell.swift
//  HomeControl+
//
//  Created by Boleslav Glavatki on 30.09.24.
//

import UIKit

class CustomViewCellTableViewCell: UITableViewCell {
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var serverNameLabel: UILabel!
    @IBOutlet weak var checkmarkUIImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
