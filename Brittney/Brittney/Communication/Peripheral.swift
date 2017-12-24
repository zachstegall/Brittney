//
//  Peripheral.swift
//  Brittney
//
//  Created by Zachary Stegall on 4/30/17.
//  Copyright © 2017 Zachary Stegall. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol PeripheralDelegate: NSObjectProtocol {
    func didSucceed()
    func didError()
}

class Peripheral: NSObject, CBPeripheralManagerDelegate {
    
    weak open var delegate: PeripheralDelegate?
    fileprivate var mManager: CBPeripheralManager?
    fileprivate var mCharacteristic: CBMutableCharacteristic?
    fileprivate static let mCharacteristicUUID = CBUUID(string: "2DE8E7DD-273D-40B7-ACB7-BB2FCD3D8429")
    fileprivate var mService: CBMutableService?
    fileprivate static let mServiceUUID = CBUUID(string: "6D8FE6C4-9557-445A-846C-BA502F8997CF")
    
    
    public init(delegate: PeripheralDelegate? = nil) {
        self.delegate = delegate
    }
    
    open func createManager() {
        guard mManager == nil else {
            return
        }
        
        mManager = CBPeripheralManager(delegate: self,
                                       queue: nil,
                                       options: nil)
        
        let properties: CBCharacteristicProperties = [.read, .notify]
        let permissions: CBAttributePermissions = [.readable]
        mCharacteristic = CBMutableCharacteristic(type: Peripheral.mCharacteristicUUID,
                                                  properties: properties,
                                                  value: nil,
                                                  permissions: permissions)
        mService = CBMutableService(type: Peripheral.mServiceUUID, primary: true)
        mService?.characteristics = [mCharacteristic!]
    }
    
    open func publishServices() {
        // will go to didAdd service delegate method
        mManager?.add(mService!)
    }
    
    open func advertiseServices() {
        // will go to didStartAdvertising delegate method
        let data = [CBAdvertisementDataServiceUUIDsKey : [mService?.uuid]]
        mManager?.startAdvertising(data)
    }
    
    
    // MARK: - Manager Delegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("Manager did update state to: \(peripheral.state)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           willRestoreState dict: [String : Any]) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didAdd service: CBService,
                           error: Error?) {
        if let error = error {
            print("Error adding service: \(error)")
            delegate?.didError()
            return
        }
        
        print("Did add service")
        delegate?.didSucceed()
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager,
                                              error: Error?) {
        if let error = error {
            print("Error starting advertising: \(error)")
            delegate?.didError()
            return
        }
        
        print("Did start advertising")
        delegate?.didSucceed()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didSubscribeTo characteristic: CBCharacteristic) {
        print("Central subscribed to characteristic: \(characteristic)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didUnsubscribeFrom characteristic: CBCharacteristic) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveRead request: CBATTRequest) {
        guard request.characteristic.uuid == mCharacteristic?.uuid else {
            print("Requesting for unknown characteristic UUID")
            mManager?.respond(to: request, withResult: .invalidHandle)
            return
        }
        
        guard let value = mCharacteristic?.value else {
            print("No value associated with the characteristic")
            mManager?.respond(to: request, withResult: .readNotPermitted)
            return
        }
        
        guard request.offset > value.count else {
            print("The read request is attempting to read outside the proper bounds")
            mManager?.respond(to: request, withResult: .invalidOffset)
            return
        }
        
        let start = value.index(value.startIndex, offsetBy: request.offset)
        let end = value.endIndex
        let range = Range(uncheckedBounds: (lower: start, upper: end))
        request.value = value.subdata(in: range)
        
        print("Success retrieving value for request")
        mManager?.respond(to: request, withResult: .success)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,
                           didReceiveWrite requests: [CBATTRequest]) {
        
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        
    }
    
    
}
