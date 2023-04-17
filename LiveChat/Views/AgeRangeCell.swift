//
//  AgeRangeCell.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 4.04.2023.
//

import UIKit

class AgeRangeCell: UITableViewCell {

    let minSliderBar: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 30
        slider.minimumTrackTintColor = .black
        return slider
    }()
    
    let maxSliderBar: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 18
        slider.maximumValue = 60
        slider.minimumTrackTintColor = .black
        return slider
    }()
    
    let minLabel: UILabel = {
       let min = AgeRangeLabel()
        min.text = "Min 25"
        return min
    }()
    
    let maxLabel: UILabel = {
        let max = AgeRangeLabel()
        max.text = "Max 32"
        return max
    }()
    
    class AgeRangeLabel: UILabel {
        override var intrinsicContentSize: CGSize {
            return .init(width: 80, height: 0)
        }
    }
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        contentView.isUserInteractionEnabled = true
        
        let overallStackView = UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [minLabel, minSliderBar]),
            UIStackView(arrangedSubviews: [maxLabel, maxSliderBar])
        ])
        
        overallStackView.axis = .vertical
        overallStackView.spacing = 16
        addSubview(overallStackView)
        overallStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
