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
    let rate: Float
}

class SimulationViewController: UIViewController, UITextFieldDelegate {
    //MARK: properties
    @IBOutlet weak var periodStart: UIDatePicker!
    @IBOutlet weak var periodEnd: UIDatePicker!
    @IBOutlet weak var startAmount: UITextField! {
        didSet { startAmount?.addDoneToolbar() }
    }
    @IBOutlet weak var runButton: UIButton!
    
    var preparedLedger: Ledger?
    var signalsResponse: SignalsResponse?
    
    var loadTimestamp:Int = 0
    var profit:Float = 1.0
    
    let btcFormatter = NumberFormatter()

    //MARK: actions
    @IBAction func runSimulation(_ sender: UIButton) {
        // Create the Activity Indicator
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
        prepareLedger()
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startAmount.delegate = self
        
//        btcFormatter.usesGroupingSeparator = true
        btcFormatter.numberStyle = .decimal
        btcFormatter.minimumFractionDigits = 3
        btcFormatter.maximumFractionDigits = 8
        //btcFormatter.currencySymbol = "₿"
        btcFormatter.usesGroupingSeparator = false
        
        startAmount.text = btcFormatter.string(from: NSNumber(value: 0.1))
        //startAmount.value = Decimal(floatLiteral: 0.1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let newTimestamp = Int(NSDate().timeIntervalSince1970)
        
        if  newTimestamp - loadTimestamp > 600 {
            loadSignals()
            loadTimestamp = newTimestamp
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        prepareLedger()
        
        guard let tradeController = segue.destination as? SimulationTableViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let sendButton = sender as? UIButton else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard preparedLedger != nil else {
            fatalError("Missing ledger data")
        }
        tradeController.ledger = preparedLedger
        tradeController.profit = profit
        
    }
    
    //MARK: UITextField

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let textValue = textField.text!
        
        switch textValue {
        case "":
            return false
        default:
            
            guard let val = btcFormatter.number(from: textValue)?.doubleValue else {
                fatalError("Could not parse the numeric value")
            }
            
            if val <= 0.0 {
                return false
            }
            textField.resignFirstResponder()
            return true
            
        }
    }
  
    /*
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = btcFormatter.string(from: NSNumber(value:Double(textField.text!.replacingOccurrences(of: "₿", with: ""))!))
    }
    */
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return false to not change text
        // max 8 fractional digits allowed
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let regex = try! NSRegularExpression(pattern: "\\..{8,}", options: [])
        let matches = regex.matches(in: newText, options:[], range:NSMakeRange(0, newText.count))
        guard matches.count == 0 else { return false }
        
       /* if newText.count == 1 && newText.first == "₿" {
            return false
        }
        */
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            return true
        case ".", ",":
            let array = textField.text?.map { String($0) }
            var decimalCount = 0
            for character in array! {
                if character == "." || character == "," {
                    decimalCount += 1
                }
            }
            if decimalCount == 1 {
                return false
            } else {
                return true
            }
         default:
            let array = string.map { String($0) }
            if array.count == 0 {
                return true
            }
            return false
        }
    }
    
    //MARK: private
    
    private var simulationData: SimulationData = SimulationData()
    
    private func saveSimulationData() {
        simulationData.amount = 0
    }
    
    private func prepareLedger() {
        guard self.startAmount.text != nil else {
            fatalError("No start amount specified.")
        }
        
        guard let startAmount = btcFormatter.number(from: self.startAmount.text!)?.floatValue else {
            fatalError("Could not parse the amount")
        }
        
        let startTime = periodStart.date.timeIntervalSince1970
        let endTime = periodEnd.date.timeIntervalSince1970
        var btcAmount = startAmount
        var usdAmount:Float = 0.0
        
        self.preparedLedger = Ledger(profitQuantifier: 1, entries: [LedgerEntry]())
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd HH:mm"
        
        guard let signalsResponse  = signalsResponse else {
            return
        }
        
        if signalsResponse.entries.count == 0 {
            return
        }
        
        guard let lastRate = signalsResponse.entries.first?.rate else {
            return
        }
        
        let tradingFee:Float = 0.0025
        
        for entry in signalsResponse.entries.reversed() {
            if entry.dts >= Int(startTime) && entry.dts <= Int(endTime) {
                let dts = Date.init(timeIntervalSince1970: TimeInterval(entry.dts))
                
                //Sell BTC
                if entry.type == "SELL" && btcAmount >= 0.001 {
                    usdAmount = usdAmount + (btcAmount - btcAmount * tradingFee) * entry.price
                    self.preparedLedger!.entries.append(LedgerEntry(datetime: formatter.string(from: dts),
                                                                    salep: true, amountBTC: btcAmount, amountUSD: usdAmount, pricePoint: entry.price))
                    btcAmount = 0.0
                }
                
                //Buy USD
                if entry.type == "BUY" && usdAmount >= 5.0 {
                    btcAmount = (usdAmount - usdAmount * tradingFee) / entry.price
                    self.preparedLedger!.entries.append(LedgerEntry(datetime: formatter.string(from: dts),
                                                                    salep: false, amountBTC: btcAmount, amountUSD: usdAmount, pricePoint: entry.price))
                    usdAmount = 0.0
                }
            }
        }
        
        profit = (btcAmount + (usdAmount / lastRate)) / startAmount
    }
    
    private func loadSignals() {
        guard let url = URL(string: "https://farca-pioneer.funcall.org/signals.json") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let signalsResponse = try decoder.decode(SignalsResponse.self, from: data)
                
                DispatchQueue.main.sync {
                    self.signalsResponse = signalsResponse
                    self.runButton.isEnabled = true

              }
            } catch _ {
                let alert = UIAlertController(title: "Network Error", message: "Could not connect to trading service", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {(alert: UIAlertAction!) in print("Network failure")}))
                self.present(alert, animated: true, completion: nil)
                self.runButton.isEnabled = false
                os_log("Could not load signals",  log: OSLog.default, type: .error)
            }
            }.resume()
        
    }
}

