//
//  AdCell.swift
//  Final Project
//
//  Created by Matthew Gilman on 6/5/19.
//  Copyright © 2019 Matt Gilman. All rights reserved.
//

import Foundation
import UIKit

internal final class itemCell: UITableViewCell, Cell {
    // Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet var cellImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        bioLabel.text = nil
        cellImage.image = nil
    }
}
