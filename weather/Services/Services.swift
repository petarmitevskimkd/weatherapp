//
//  Services.swift
//  weather
//
//  Created by Telekom MK on 7/22/19.
//  Copyright © 2019 petar. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import AlamofireImage
public class Services: NSObject {
    
    static let shared = Services()
    var AFManager: SessionManager!
    var AFLoginManager: SessionManager!
    
    
    override init() {
        super.init()
        print("services init")
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        AFManager = Alamofire.SessionManager(configuration: configuration)

    }
    
    var onCompleteGetDetailsForWOEID: ((_ success: Bool?, _ error: Error?, _ result: Data?)->())?
    func getDetailsForWOEID(_ woeid: String!){

        let url = ApiConfig.apiURL + ApiConfig.dataByWOEID + woeid
        AFManager.request(url,method: .get, encoding: JSONEncoding.default).responseJSON(){
            response in
            switch response.result {
            case .success:
                self.onCompleteGetDetailsForWOEID?(true, nil, response.data)
                break
            case .failure(let error):
                self.onCompleteGetDetailsForWOEID?(false, error, nil)
                break
            }
        }
        
    }
    
    let imageCache = AutoPurgingImageCache(
        memoryCapacity: 100_000_000,
        preferredMemoryUsageAfterPurge: 60_000_000
    )
    
    
    
}
