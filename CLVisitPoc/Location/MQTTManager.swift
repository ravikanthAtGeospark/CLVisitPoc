//
//  MQTTManager.swift
//  CocoaMQTTExample
//
//  Created by GeoSpark Mac 15 on 12/12/19.
//  Copyright © 2019 GeoSpark Mac. All rights reserved.
//

import Foundation
import AWSIoT
import AWSMobileClient


class MQTTManager: NSObject {
    
    static let sharedInstance = MQTTManager()
    @objc var iotDataManager: AWSIoTDataManager!;
    @objc var iotManager: AWSIoTManager!;
    @objc var iot: AWSIoT!
    
    @objc var connected = false;
    
    override init() {
        super.init()
        
        // Initialize AWSMobileClient for authorization
        AWSMobileClient.default().initialize { (userState, error) in
            guard error == nil else {
                print("Failed to initialize AWSMobileClient. Error: \(error!.localizedDescription)")
                return
            }
            print("AWSMobileClient initialized.")
        }
        
        // Init IOT
        let iotEndPoint = AWSEndpoint(urlString: IOT_ENDPOINT)
        
        // Configuration for AWSIoT control plane APIs
        let iotConfiguration = AWSServiceConfiguration(region: AWSRegion, credentialsProvider: AWSMobileClient.default())
        
        // Configuration for AWSIoT data plane APIs
        let iotDataConfiguration = AWSServiceConfiguration(region: AWSRegion,
                                                           endpoint: iotEndPoint,
                                                           credentialsProvider: AWSMobileClient.default())
        AWSServiceManager.default().defaultServiceConfiguration = iotConfiguration
        
        iotManager = AWSIoTManager.default()
        iot = AWSIoT.default()
        
        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: ASWIoTDataManager)
        iotDataManager = AWSIoTDataManager(forKey: ASWIoTDataManager)
        
    }
    
    func connect(){
        
        func mqttEventCallback( _ status: AWSIoTMQTTStatus )
        {
            DispatchQueue.main.async {
                switch(status)
                {
                case .connected:
                    print("Connected....:\(status.rawValue)")
                    self.connected = true
                    let uuid = UUID().uuidString;
                    let defaults = UserDefaults.standard
                    let certificateId = defaults.string( forKey: "certificateId")
                    print("Using certificate:\n\(certificateId!)\n\n\nClient ID:\n\(uuid)")
                case .disconnected:
                    print("Disconnected....:\(status.rawValue)")
                    self.connect()
                default:
                    print("Unknown State  :\(status.rawValue)")
                }
                print("connection status = \(status.rawValue)")
            }
        }
        
        if (connected == false)
        {
            let defaults = UserDefaults.standard
            var certificateId = defaults.string( forKey: "certificateId")
            
            if (certificateId == nil)
            {
                DispatchQueue.main.async {
                    print("No identity available, searching bundle...")
                }
                
                // No certificate ID has been stored in the user defaults; check to see if any .p12 files
                // exist in the bundle.
                let myBundle = Bundle.main
                let myImages = myBundle.paths(forResourcesOfType: "p12" as String, inDirectory:nil)
                let uuid = UUID().uuidString;
                
                if (myImages.count > 0) {
                    // At least one PKCS12 file exists in the bundle.  Attempt to load the first one
                    // into the keychain (the others are ignored), and set the certificate ID in the
                    // user defaults as the filename.  If the PKCS12 file requires a passphrase,
                    // you'll need to provide that here; this code is written to expect that the
                    // PKCS12 file will not have a passphrase.
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: myImages[0])) {
                        DispatchQueue.main.async {
                            print("found identity \(myImages[0]), importing...")
                        }
                        if AWSIoTManager.importIdentity( fromPKCS12Data: data, passPhrase:"", certificateId:myImages[0]) {
                            // Set the certificate ID and ARN values to indicate that we have imported
                            // our identity from the PKCS12 file in the bundle.
                            defaults.set(myImages[0], forKey:"certificateId")
                            defaults.set("from-bundle", forKey:"certificateArn")
                            DispatchQueue.main.async {
                                print("Using certificate: \(myImages[0]))")
                                self.iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:myImages[0], statusCallback: mqttEventCallback)
                            }
                        }
                    }
                }
                
                certificateId = defaults.string( forKey: "certificateId")
                if (certificateId == nil) {
                    DispatchQueue.main.async {
                        print("No identity found in bundle, creating one...")
                    }
                    
                    // Now create and store the certificate ID in NSUserDefaults
                    let csrDictionary = [ "commonName":CertificateSigningRequestCommonName, "countryName":CertificateSigningRequestCountryName, "organizationName":CertificateSigningRequestOrganizationName, "organizationalUnitName":CertificateSigningRequestOrganizationalUnitName ]
                    
                    self.iotManager.createKeysAndCertificate(fromCsr: csrDictionary, callback: {  (response ) -> Void in
                        if (response != nil)
                        {
                            defaults.set(response?.certificateId, forKey:"certificateId")
                            defaults.set(response?.certificateArn, forKey:"certificateArn")
                            certificateId = response?.certificateId
                            print("response: [\(String(describing: response))]")
                            
                            let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest()
                            attachPrincipalPolicyRequest?.policyName = PolicyName
                            attachPrincipalPolicyRequest?.principal = response?.certificateArn
                            
                            // Attach the policy to the certificate
                            self.iot.attachPrincipalPolicy(attachPrincipalPolicyRequest!).continueWith (block: { (task) -> AnyObject? in
                                if let error = task.error {
                                    print("failed: [\(error)]")
                                }
                                print("result: [\(String(describing: task.result))]")
                                
                                // Connect to the AWS IoT platform
                                if (task.error == nil)
                                {
                                    DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                                        print("Using certificate: \(certificateId!)")
                                        self.iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:certificateId!, statusCallback: mqttEventCallback)
                                        
                                    })
                                }
                                return nil
                            })
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                print("Unable to create keys and/or certificate, check values in Constants.swift")
                            }
                        }
                    } )
                }
            }
            else
            {
                let uuid = UUID().uuidString;
                
                // Connect to the AWS IoT service
                iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:certificateId!, statusCallback: mqttEventCallback)
            }
        }
        else
        {
            print("Disconnecting...")
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                self.iotDataManager.disconnect();
            }
        }
    }
    
    
    func subscribeTopic(){
        iotDataManager.subscribe(toTopic: toTopicSubscribe, qoS: .messageDeliveryAttemptedAtMostOnce) { (payload) in
            let stringValue = NSString(data: payload, encoding: String.Encoding.utf8.rawValue)!
            print("subscribe",stringValue)
        }
    }
    
    func unsubscribeTopic(){
        iotDataManager.unsubscribeTopic(toTopicSubscribe)
    }

    func publish(_ publishString:String){
        iotDataManager.publishString(publishString, onTopic:toTopicSubscribe, qoS:.messageDeliveryAttemptedAtMostOnce)
    }
    
}
