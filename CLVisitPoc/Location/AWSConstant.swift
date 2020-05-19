//
//  AWSConstant.swift
//  CLVisitPoc
//
//  Created by GeoSpark Mac 15 on 22/04/20.
//  Copyright © 2020 GeoSpark. All rights reserved.
//

import Foundation
import AWSCore

//WARNING: To run this sample correctly, you must set the following constants.

let CertificateSigningRequestCommonName = "MotionPOC"
let CertificateSigningRequestCountryName = "India"
let CertificateSigningRequestOrganizationName = "GeoSpark"
let CertificateSigningRequestOrganizationalUnitName = "Inc"
let PolicyName = "motionpociotpolicy"
let toTopicSubscribe = "locations"
// This is the endpoint in your AWS IoT console. eg: https://xxxxxxxxxx.iot.<region>.amazonaws.com
let AWSRegion = AWSRegionType.EUCentral1 // e.g. AWSRegionType.USEast1
let IOT_ENDPOINT = "https://az91jf6dri5ey-ats.iot.eu-central-1.amazonaws.com/"
let ASWIoTDataManager = "MyIotDataManager"

