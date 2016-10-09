//
//  ValueMappingForValue.swift
//  GlueKit
//
//  Created by Károly Lőrentey on 2016-10-09.
//  Copyright © 2016. Károly Lőrentey. All rights reserved.
//

import Foundation

// MARK: Map

public extension ObservableValueType {
    /// Returns an observable that calculates `transform` on all current and future values of this observable.
    public func map<Output>(_ transform: @escaping (Value) -> Output) -> Observable<Output> {
        return ValueMappingForValue<Self, Output>(parent: self, transform: transform).observable
    }
}

private final class ValueMappingForValue<Parent: ObservableValueType, Value>: ObservableBoxBase<Value> {
    let parent: Parent
    let transform: (Parent.Value) -> Value

    init(parent: Parent, transform: @escaping (Parent.Value) -> Value) {
        self.parent = parent
        self.transform = transform
    }

    override var value: Value {
        return transform(parent.value)
    }

    override var changes: Source<SimpleChange<Value>> {
        return parent.changes.map { $0.map(self.transform) }
    }
}

extension UpdatableType {
    public func map<Output>(_ transform: @escaping (Value) -> Output, inverse: @escaping (Output) -> Value) -> Updatable<Output> {
        return ValueMappingForUpdatableValue<Self, Output>(parent: self, transform: transform, inverse: inverse).updatable
    }
}

private final class ValueMappingForUpdatableValue<Parent: UpdatableType, Value>: UpdatableBoxBase<Value> {
    let parent: Parent
    let transform: (Parent.Value) -> Value
    let inverse: (Value) -> Parent.Value

    init(parent: Parent, transform: @escaping (Parent.Value) -> Value, inverse: @escaping (Value) -> Parent.Value) {
        self.parent = parent
        self.transform = transform
        self.inverse = inverse
    }

    override var value: Value {
        get { return transform(parent.value) }
        set { parent.value = inverse(newValue) }
    }
    override var changes: Source<SimpleChange<Value>> {
        return parent.changes.map { $0.map(self.transform) }
    }
}