//  Created by Filip Kjamilov on 30.10.22.

import Foundation

extension UserDefaults {

    enum Keys: String, CaseIterable {
        
        case endReached
        case start
        case freshStart
        case showPromoCode
        case coupon

    }

    func reset() {
        Keys.allCases.forEach { removeObject(forKey: $0.rawValue) }
    }

}
