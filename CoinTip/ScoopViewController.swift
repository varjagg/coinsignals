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
    let rate: Float
    let price: Float
    let trend: String?
    let signal: String?
    let detail: String
    let dts: Int
}

class ScoopViewController: UIViewController {
    
    //MARK: properties
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var trend: UILabel!
    @IBOutlet weak var advice: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    
    var scoopArray = [String] ()
    let gradient = Gradient()
    
    lazy var refresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(self.didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundLayer = gradient.gl
        backgroundLayer?.frame = view.frame
        view.layer.insertSublayer(backgroundLayer!, at: 0)
        
        scrollView.refreshControl = refresh
    }

    @objc func didPullToRefresh() {
        loadScoop()
        refresh.endRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadScoop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: private
    private func loadScoop() {
        guard let url = URL(string: "https://farca-pioneer.funcall.org/scoop.json") else { return }
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        URLSession.shared.dataTask(with: request) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let scoopData = try decoder.decode(ScoopData.self, from: data)

                DispatchQueue.main.sync {
                    
                    let rate = scoopData.rate
                    let usdFormatter = NumberFormatter()
                    usdFormatter.usesGroupingSeparator = true
                    usdFormatter.numberStyle = .currency
                    usdFormatter.locale = Locale(identifier: "en_US")
                        
                    guard let formattedRate = usdFormatter.string(from: NSNumber(value: rate)) else {
                        fatalError("Could not format the rate")
                    }
                        
                    self.rate.text = "1.0 ₿ : " + formattedRate
                    
                    if let trend = scoopData.trend {
                        self.trend.text = trend
                    }
                    
                    guard let formattedPrice = usdFormatter.string(from: NSNumber(value: scoopData.price)) else {
                        fatalError("Could not format price")
                    }
                    
                    if let signal = scoopData.signal {
                        self.advice.text = signal
                        switch signal {
                        case "BUY", "SELL":
                            self.detail.text = scoopData.detail + formattedPrice
                            self.view.backgroundColor = UIColor(red: 170.0 / 255.0, green: 26.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0)
                            self.gradient.setColors(from: UIColor(red: 170.0 / 255.0, green: 26.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0), to: UIColor(red: 255.0 / 255.0, green: 26.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0))
                        case "NEAR":
                            self.detail.text = scoopData.detail
                            self.view.backgroundColor = UIColor(red: 255.0 / 255.0, green: 119.0 / 255.0, blue: 119.0 / 255.0, alpha: 1.0)
                            self.gradient.setColors(from: UIColor(red: 255.0 / 255.0, green: 119.0 / 255.0, blue: 119.0 / 255.0, alpha: 1.0), to: UIColor(red: 255.0 / 255.0, green: 170.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0))
                         default:
                            self.detail.text = scoopData.detail
                            self.view.backgroundColor = UIColor(red: 109.0 / 255.0, green: 219.0 / 255.0, blue: 133.0 / 255.0, alpha: 1.0)
                            self.gradient.setColors(from: UIColor(red: 109.0 / 255.0, green: 219.0 / 255.0, blue: 133.0 / 255.0, alpha: 1.0), to: UIColor(red: 196.0 / 255.0, green: 255.0 / 255.0, blue: 209.0 / 255.0, alpha: 1.0))
                         }
                    }
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy-MM-dd HH:mm"
                    self.dateTime.text = formatter.string(from: Date.init(timeIntervalSince1970: TimeInterval(scoopData.dts)))
                }
            } catch _ {
                let alert = UIAlertController(title: "Network Error", message: "Could not connect to trading service", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {(alert: UIAlertAction!) in print("Network failure")}))
                self.present(alert, animated: true, completion: nil)
                os_log("Could not parse scoop",  log: OSLog.default, type: .error)
            }
        }.resume()
    }
}
