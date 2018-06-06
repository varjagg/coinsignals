//
//  SimulationViewController.swift
//  CoinTip
//
//  Created by Eugene Zaikonnikov on 05/06/2018.
//  Copyright © 2018 Eugene Zaikonnikov. All rights reserved.
//

import UIKit
import os.log

struct LedgerData: Codable {
    let dts: Int32?
    let type: String?
    let price: Float?
}

class SimulationViewController: UIViewController {
    //MARK: properties
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: actions
    @IBAction func runSimulation(_ sender: UIButton) {
        activityIndicator.startAnimating()
        loadLedger()
        activityIndicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: private
    
    private func loadLedger() {
        guard let url = URL(string: "https://farca-pioneer.funcall.org/ledger.json") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let ledgerData = try decoder.decode(LedgerData.self, from: data)
                
                DispatchQueue.main.sync {
      /*
                    if let price = ledgerData.price {
                        self.rate.text = price
                    }
        */
                    os_log("w00t",  log: OSLog.default, type: .debug)
                }
            } catch let _ {
                os_log("Could not proceed",  log: OSLog.default, type: .error)
            }
            }.resume()
        
    }
}

