//
//  Gradient.swift
//  CoinTip
//
//  Created by Eugene Zaikonnikov on 10/06/2018.
//  Copyright © 2018 Eugene Zaikonnikov. All rights reserved.
//

import UIKit

class Gradient {
    var gl:CAGradientLayer!
    
    init() {
        
        let colorTop:CGColor = UIColor(red: 26.0 / 255.0, green: 153.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom:CGColor = UIColor(red: 145.0 / 255.0, green: 247.0 / 255.0, blue: 167.0 / 255.0, alpha: 1.0).cgColor

        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
    
    func setColors(from: UIColor, to: UIColor) {
        self.gl.colors = [from.cgColor, to.cgColor]
    }
}
