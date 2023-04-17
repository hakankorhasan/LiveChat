//
//  Bindable.swift
//  LiveChat
//
//  Created by Hakan Körhasan on 25.12.2022.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?)->())?
    
    func bind(observer: @escaping (T?) ->()) {
        self.observer = observer
    }
    
}
