//
//  Hub.swift
//  weatherapp
//
//  Created by Enchappolis on 8/2/20.
//  Copyright © 2020 Enchappolis. All rights reserved.
//  https://github.com/Enchappolis
/*
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 distribute, sublicense, create a derivative work, and/or sell copies of the
 Software in any work that is designed, intended, or marketed for pedagogical or
 instructional purposes related to programming, coding, application development,
 or information technology.  Permission for such use, copying, modification,
 merger, publication, distribution, sublicensing, creation of derivative works,
 or sale is expressly withheld.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
*/

import UIKit

class Hud {
    
    private static var hud: UIView?
    
    static func show(onTopOf view: UIView, color: UIColor? = ColorTheme.hudTextColor) {
    
        hud = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        hud?.tag = 1000
        
        guard let hud = hud else { return }
        
        hud.backgroundColor = ColorTheme.hudBackgroundColor
        hud.extRounded(radius: 10)
        hud.center = view.center

        var activityIndicator = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = color
        activityIndicator.center = CGPoint(x: hud.frame.width/2,
                                           y: hud.frame.height/2 - 20)
        activityIndicator.hidesWhenStopped = true
        //        activityIndicator.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        activityIndicator.startAnimating()

        var label = UILabel()
        label = UILabel(frame: CGRect(x: 0,
                                      y: activityIndicator.frame.maxY,
                                      width: hud.bounds.width,
                                      height: 50))
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.text = "Loading..."
        label.textColor = ColorTheme.hudTextColor
        label.textAlignment = .center
        
        hud.addSubview(activityIndicator)
        hud.addSubview(label)

        view.addSubview(hud)
    }
    
    static func hide(from view: UIView) {
        
        if let view = view.viewWithTag(1000) {
            view.removeFromSuperview()
        }
        hud?.removeFromSuperview()
        hud = nil
    }
}
