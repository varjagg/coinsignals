//
//  SimulationViewController.swift
//  CoinTip
//
//  Created by Eugene Zaikonnikov on 05/06/2018.
//  Copyright © 2018 Eugene Zaikonnikov. All rights reserved.
//

import UIKit
import os.log

struct SignalsResponse: Decodable {
    let timestamp: Int
    let entries: [SignalsData]
}

struct SignalsData: Decodable {
    let dts: Int
    let type: String
    let price: Float
}

class SimulationViewController: UIViewController, UITextFieldDelegate {
    //MARK: properties
    @IBOutlet weak var periodStart: UIDatePicker!
    @IBOutlet weak var periodEnd: UIDatePicker!
    @IBOutlet weak var startAmount: UITextField!
    
    var preparedLedger: Ledger?
    
    //MARK: actions
    @IBAction func runSimulation(_ sender: UIButton) {
        // Create the Activity Indicator
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
        loadSignals()
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    startAmount.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let tradeController = segue.destination as? SimulationTableViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let sendButton = sender as? UIButton else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard preparedLedger != nil else {
            fatalError("Missing ledger data")
        }
        tradeController.ledger = preparedLedger!
        
    }
    
    //MARK: UITextField

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
    
    //MARK: private
    
    private var simulationData: SimulationData = SimulationData()
    
    private func saveSimulationData() {
        simulationData.amount = 0
    }
    
    private func loadSignals() {
        guard let url = URL(string: "https://farca-pioneer.funcall.org/ledger.json") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let ledgerResponse = try decoder.decode(SignalsResponse.self, from: data)
                
                DispatchQueue.main.sync {
      /*
                    if let price = ledgerData.price {
                        self.rate.text = price
                    }
        */
                }
            } catch _ {
                let alert = UIAlertController(title: "Network Error", message: "Could not connect to trading service", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {(alert: UIAlertAction!) in print("Network failure")}))
                self.present(alert, animated: true, completion: nil)
                
                os_log("Could not parse ledger",  log: OSLog.default, type: .error)
            }
            }.resume()
        
    }
}

