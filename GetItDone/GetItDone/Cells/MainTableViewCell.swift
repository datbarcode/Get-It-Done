//
//  MainTableViewCell.swift
//  GetItDone
//
//  Created by David Barko on 7/22/20.
//  Copyright © 2020 David Barko. All rights reserved.
//

import UIKit
class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var taskBackView: UIView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    static let identifier = "MainTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "MainTableViewCell", bundle: nil)
    }
    // Configures label and progress bar
    public func configure(with title: String, subTotal: Int16, subDone: Int16) {
        taskLabel.text = title
        let progress = Progress(totalUnitCount: Int64(subTotal))
        progress.completedUnitCount = Int64(subDone)
        let progressFloat = Float(progress.fractionCompleted)
        self.progressView.setProgress(progressFloat, animated: true)
        self.progressView.clipsToBounds = true
        self.progressView.layer.cornerRadius = 8
        self.progressView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        if progressFloat == 1.0 {
            self.taskBackView.layer.borderWidth = 1.0
            self.taskBackView.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            self.taskBackView.layer.borderWidth = 0.0
        }
        updateColors()
    }
    func updateColors(){
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .dark {
            taskBackView.backgroundColor = UIColor.systemGray6
        } else {
            taskBackView.backgroundColor = UIColor.quaternarySystemFill
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set appearance
        taskBackView.layer.cornerRadius = taskBackView.frame.height / 8
        selectionStyle = UITableViewCell.SelectionStyle.none
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateColors()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
