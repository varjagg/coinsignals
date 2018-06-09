//
//  Ledger.swift
//  CoinTip
//
//  Created by Eugene Zaikonnikov on 09/06/2018.
//  Copyright © 2018 Eugene Zaikonnikov. All rights reserved.
//

import Foundation

struct LedgerEntry {
    let datetime: String
    let salep: Bool
    let amount: Float
    let pricePoint: Float
}

struct Ledger {
    let profitQuantifier: Float
    let entries:[LedgerEntry]
}
