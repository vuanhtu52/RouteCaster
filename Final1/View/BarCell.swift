//
//  BarCell.swift
//  BarChartLiveStream
//
//  Created by Brian Voong on 3/19/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

class BarCell: UICollectionViewCell {
    
    let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var barHeightConstraint: NSLayoutConstraint?
    
    override var isHighlighted: Bool {
        didSet {
            barView.backgroundColor = isHighlighted ? .black : .red
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(barView)
        
        //        barView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        barHeightConstraint = barView.heightAnchor.constraint(equalToConstant: 300)
        barHeightConstraint?.isActive = true
        
        barHeightConstraint?.constant = 100
        
        //        barView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        barView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        barView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        barView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
