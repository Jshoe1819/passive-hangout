//
//  MutableCollection+Shuffle.swift
//  passive-hangout
//
//  Created by Jacob Shoemaker on 11/3/17.
//  Copyright © 2017 Jacob Shoemaker. All rights reserved.
//

import Foundation

extension MutableCollection {
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}
