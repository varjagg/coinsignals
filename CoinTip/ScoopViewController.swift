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
    let price: Float?
    let trend: String?
    let signal: String?
}

class ScoopViewController: UIViewController {
    
    //MARK: properties
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var trend: UILabel!
    @IBOutlet weak var advice: UILabel!
    
    var scoopArray = [String] ()
    
    lazy var refresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(self.didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                    
                    if let price = scoopData.price {
                        self.rate.text = "Rate: \(price)"
                    }
                    
                    if let trend = scoopData.trend {
                        self.trend.text = trend
                    }
                    
                    if let signal = scoopData.signal {
                        self.advice.text = signal
                        switch signal {
                        case "SELL":
                            self.view.backgroundColor = .red
                        case "BUY":
                            self.view.backgroundColor = .red
                        case "NEARING":
                            self.view.backgroundColor = .yellow
                        default:
                            self.view.backgroundColor = .blue
                        }
                    }
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
