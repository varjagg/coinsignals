//
//  ScoopViewController.swift
//  CoinTip
//
//  Created by Eugene Zaikonnikov on 05/06/2018.
//  Copyright © 2018 Eugene Zaikonnikov. All rights reserved.
//

import UIKit
import os.log

struct ScoopData: Codable {
    let price: String?
    let trend: String?
    let signal: String?
}

class ScoopViewController: UIViewController {
    
    //MARK: properties
    var scoopArray = [String] ()

    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var trend: UILabel!
    @IBOutlet weak var advice: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadScoop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: private
    private func loadScoop() {
        guard let url = URL(string: "https://farca-pioneer.funcall.org/scoop.json") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let scoopData = try decoder.decode(ScoopData.self, from: data)

                DispatchQueue.main.sync {
                    
                    if let price = scoopData.price {
                        self.rate.text = price
                    }
                    
                    if let trend = scoopData.trend {
                        self.trend.text = trend
                    }
                    
                    if let signal = scoopData.signal {
                        self.advice.text = signal
                    }
                    

                }
                
            } catch let _ {
                os_log("Could not proceed",  log: OSLog.default, type: .error)
            }
        }.resume()
        
    }
}
