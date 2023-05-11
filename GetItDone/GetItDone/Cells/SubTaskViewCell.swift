//
//  SubTaskViewCell.swift
//  GetItDone
//
//  Created by David Barko on 8/28/20.
//  Copyright © 2020 David Barko. All rights reserved.
//

import UIKit
// Protocol used in SubDetailVC for status indicator
protocol SubStatusDelegate: class {
    func subStatusClicked(cell: SubTaskViewCell)
}
class SubTaskViewCell: UITableViewCell {
    @IBOutlet weak var taskBackView: UIView!
    @IBOutlet weak var taskLabel: UILabel!
    
    @IBOutlet weak var subStatusbtn: UIButton!
    // send self to detailsvc when status btn clicked
    
    
    @IBAction func subStatusPressed(_ sender: Any) {
        delegate?.subStatusClicked(cell: self)
    }
    @IBAction func subStatus(_ sender: Any) {
        //delegate?.subStatusClicked(cell: self)
    }
    weak var delegate: SubStatusDelegate?
    static let identifier = "SubTaskViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "SubTaskViewCell", bundle: nil)
    }
    // Configures status indicator based on stat passed
    public func configure(with title: String, stat: Int16, enabled: Bool) {
        taskLabel.text = title
        if (enabled){
            subStatusbtn.isHidden = true
        }
        else{
            subStatusbtn.isHidden = false
        }
        subStatusbtn.layer.borderColor = UIColor.systemGray.cgColor
        if stat == 0 {
            subStatusbtn.layer.backgroundColor = taskBackView.layer.backgroundColor
            subStatusbtn.layer.borderWidth = 0.5
        } else if stat == 1 {
            subStatusbtn.layer.backgroundColor = UIColor.systemYellow.cgColor
            subStatusbtn.layer.borderWidth = 0.0
        } else {
            subStatusbtn.layer.backgroundColor = UIColor.systemGreen.cgColor
            subStatusbtn.layer.borderWidth = 0.0
        }
        updateColors()
    }
    func updateColors(){
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        let statColor = subStatusbtn.layer.backgroundColor
        if userInterfaceStyle == .dark {
            taskBackView.backgroundColor = UIColor.systemGray6
            if statColor == UIColor.quaternarySystemFill.cgColor {
                subStatusbtn.layer.backgroundColor = UIColor.systemGray6.cgColor
            }
        } else {
            taskBackView.backgroundColor = UIColor.quaternarySystemFill
            if statColor == UIColor.systemGray6.cgColor {
                subStatusbtn.layer.backgroundColor = UIColor.quaternarySystemFill.cgColor
            }
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateColors()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set appearance
        subStatusbtn.layer.cornerRadius = 8
        taskBackView.layer.cornerRadius = taskBackView.frame.height / 4
        selectionStyle = UITableViewCell.SelectionStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
