//
//  SimulationTableViewController.swift
//  CoinTip
//
//  Created by Eugene Zaikonnikov on 06/06/2018.
//  Copyright © 2018 Eugene Zaikonnikov. All rights reserved.
//

import UIKit

class SimulationTableViewController: UITableViewController {

    var ledger: Ledger?
    var profit:Float = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ledger != nil {
            return ledger!.entries.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "TradesTableViewCell"
     
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TradesTableViewCell  else {
        fatalError("The dequeued cell is not an instance of TradesTableViewCell.")
        }
     
        // Fetches the appropriate meal for the data source layout.
        let trade = ledger!.entries[indexPath.row]
        
        cell.dateTime.text = trade.datetime
        
        let btcFormatter = NumberFormatter()
        btcFormatter.usesGroupingSeparator = true
        btcFormatter.numberStyle = .decimal
        btcFormatter.minimumFractionDigits = 3
        btcFormatter.maximumFractionDigits = 8
        
        cell.amountBTC.text = btcFormatter.string(from: NSNumber(value: trade.amountBTC))
        
        let usdFormatter = NumberFormatter()
        usdFormatter.usesGroupingSeparator = true
        usdFormatter.numberStyle = .currency
        usdFormatter.locale = Locale(identifier: "en_US")
        
        cell.amountUSD.text = usdFormatter.string(from: NSNumber(value: trade.amountUSD))

        cell.rate.text = String(trade.pricePoint)
        cell.backgroundColor = trade.salep ? UIColor(red: 255.0 / 255.0, green: 26.0 / 255.0, blue: 50.0 / 255.0, alpha: 1.0) : UIColor(red: 9.0 / 255.0, green: 148.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
        cell.transactionDirection.text = trade.salep ? "⇲" : "⇱"
        cell.transactionText.text = trade.salep ? "Sell" : "Buy"
        //cell.transactionImage.image = UIImage(imageLiteralResourceName: trade.salep ? "saleArrow" : "buyArrow")

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let textLabel = UILabel()
 /*
        var headerView: SectionHeaderTableViewCell? = tableView.dequeueReusableCellWithIdentifier("SectionHeader")
        if (headerView == nil) {
            headerView = SectionHeaderTableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"SectionHeader")
        }
        headerView!.textLabel!.text = ""
 */
        textLabel.textAlignment = .center
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.backgroundColor = .white
        
        let pctFormatter = NumberFormatter()
        pctFormatter.usesGroupingSeparator = true
        pctFormatter.numberStyle = .percent
        
        textLabel.text = "Final coin worth is at " + pctFormatter.string(from: NSNumber(value: profit))! + " of start value"

        return textLabel;
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
     @IBAction func dismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
     }
     
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
