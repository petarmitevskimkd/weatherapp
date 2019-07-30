//
//  NetworkState.swift
//  weather
//
//  Created by Telekom MK on 7/29/19.
//  Copyright © 2019 petar. All rights reserved.
//

import Foundation
import Alamofire
class NetworkState {
    class func isConnected() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
