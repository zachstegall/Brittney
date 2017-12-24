//
//  PeripheralStateMachine.swift
//  Brittney
//
//  Created by Zachary Stegall on 4/30/17.
//  Copyright © 2017 Zachary Stegall. All rights reserved.
//

import Foundation

enum PeripheralState: Int {
    case None
    case Create
    case PublishService
    case Advertise
    case Complete
    
    func increment() -> PeripheralState? {
        return PeripheralState(rawValue: rawValue + 1)
    }
}

protocol StateMachineProtocol {
    func start()
}

class PeripheralStateMachine: NSObject, StateMachineProtocol, PeripheralDelegate {
    
    var mPeripheral: Peripheral!
    var mState: PeripheralState = .None
    
    func start() {
        if mPeripheral == nil {
            mPeripheral = Peripheral(delegate: self)
        }
        
        next()
    }
    
    func next() {
        guard let nextState = mState.increment() else {
            print("Reached the end of States")
            return
        }
        
        mState = nextState
        print("Transitioning to state: \(mState)")
        
        switch mState {
        case .None:
            print("Oops, shouldn't have landed here")
            
        case .Create:
            mPeripheral.createManager()
            
        case .PublishService:
            mPeripheral.publishServices()
            
        case .Advertise:
            mPeripheral.advertiseServices()
            
        case .Complete:
            print("Peripheral will begin waiting for requests from Centrals")
            break
            
        }
    }
    
    
    // MARK: - Peripheral Delegate
    
    func didSucceed() {
        next()
    }
    
    func didError() {
        print("Could not perform action for state: \(mState)")
    }
    
    
}
