//
//  Created by iWw on 2020/12/21.
//

import UIKit

public protocol TabProvider {
    
    var tabIdentifier: String { get }
    
    var tabName: String { get }
    var tabImageName: String { get }
    
    var controller: UIViewController { get }
}
