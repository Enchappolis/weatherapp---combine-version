//
//  SettingsViewController.swift
//  weatherapp
//
//  Created by Enchappolis on 7/30/20.
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

class SettingsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var celsiusSwitch: UISwitch!
    @IBOutlet weak var farenheitSwitch: UISwitch!
    
    // MARK: - Actions
    @IBAction func celsiusSwitch(_ sender: UISwitch) {

        farenheitSwitch.isOn = !farenheitSwitch.isOn
        saveToUserDefaults()
    }
    
    @IBAction func farenheitSwitch(_ sender: UISwitch) {

        celsiusSwitch.isOn = !celsiusSwitch.isOn
        saveToUserDefaults()
    }
    
    @IBAction func closeBarButtonitemTapped(_ sender: UIBarButtonItem) {
    
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func saveToUserDefaults() {
        
        let temperatureUnit = celsiusSwitch.isOn ? SettingsViewModel.TemperatureUnit.celsius : SettingsViewModel.TemperatureUnit.fahrenheit
        
        SettingsViewModel.selectedTemperatureUnit = temperatureUnit
    }
    
    private func loadUserDefaults() {
        
        if SettingsViewModel.selectedTemperatureUnit == .celsius {
            celsiusSwitch.isOn = true
        }
        else {
            farenheitSwitch.isOn = true
        }
    }
    
    // MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserDefaults()
    }
}
