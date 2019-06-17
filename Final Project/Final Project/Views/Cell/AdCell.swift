//
//  AdCell.swift
//  Final Project
//
//  Created by Matthew Gilman on 6/5/19.
//  Copyright © 2019 Matt Gilman. All rights reserved.
//

import Foundation
import UIKit

internal final class adCell: UITableViewCell, Cell {
    // Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pageCountLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        pageCountLabel.text = nil
    }
}
