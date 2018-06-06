//
//  BTDBEntity.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/6.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

public protocol BTDBEntityModel {
    static func newDefaultModel() -> Any
    static func onBuildBTDBEntity(entity: BTDBEntity.Builder)
}

public class BTDBEntity {
    var properties = [Property<Any, Any>]()
    var scheme: String
    
    init(scheme: String) {
        self.scheme = scheme
    }
}

extension BTDBEntity {
    var primaryKeys: [Property<Any, Any>] {
        return properties.filter { $0.primaryKey }
    }
    
    var notPrimaryKeys: [Property<Any, Any>] {
        return properties.filter { !$0.primaryKey }
    }
}

extension BTDBEntity {
    public class Builder {
        public init(scheme: String) {
            entity = BTDBEntity(scheme: scheme)
        }
        
        private var entity: BTDBEntity
        
        @discardableResult
        public func hasProperty<T, V>(_ name: String, setter: @escaping Property<T, V>.Setter) -> Property<T, V> {
            let defaultGetter: Property<T, V>.Getter = { model in
                let modelMirror = Mirror(reflecting: model)
                let modelP = modelMirror.children.first(where: { (label, _) -> Bool in
                    label! == name
                })!
                return modelP.value as? V
            }
            
            /* TODO: after swift upgrade reflecting features*/
            
            let defaultSetter: Property<T, V>.Setter = { model, value in
                setter(model, value)
            }
            return Property<T, V>(propertyName: name, getter: defaultGetter, setter: defaultSetter)
        }
        
        public func build<T>(_ type:T.Type) -> BTDBEntity where T:BTDBEntityModel {
            T.onBuildBTDBEntity(entity: self)
            return entity
        }
    }
    
    public class Property<T, V> {
        private(set) var length: Int = 0
        public typealias Setter = (_ model: T, _ value: V?) -> Void
        public typealias Getter = (_ model: T) -> V?
        private(set) var setter: Setter
        private(set) var getter: Getter
        private(set) var propertyName: String
        private(set) var columnName: String
        private(set) var primaryKey = false
        private(set) var isNotNull = false
        private(set) var isUnique = false
        private(set) var isAutoIncrement = false
        private(set) var defaultValue: Any?
        private(set) var checkString: String?
        
        internal init(propertyName: String, getter: @escaping Getter, setter: @escaping Setter) {
            self.propertyName = propertyName
            columnName = propertyName
            self.getter = getter
            self.setter = setter
        }
        
        @discardableResult
        public func hasPrimaryKey(value: Bool = true) -> Property<T, V> {
            primaryKey = value
            return self
        }
        
        @discardableResult
        public func notNull(value: Bool = true) -> Property<T, V> {
            isNotNull = value
            return self
        }
        
        @discardableResult
        public func autoIncrement(value: Bool = true) -> Property<T, V> {
            isAutoIncrement = value
            return self
        }
        
        @discardableResult
        public func hasDefaultValue(defaultValue: Any?) -> Property<T, V> {
            self.defaultValue = defaultValue
            return self
        }
        
        @discardableResult
        public func unique(value: Bool = true) -> Property<T, V> {
            isUnique = value
            return self
        }
        
        @discardableResult
        public func check(limited: String?) -> Property<T, V> {
            checkString = limited
            return self
        }
        
        @discardableResult
        public func length(valueLength: Int) -> Property<T, V> {
            length = valueLength
            return self
        }
        
        @discardableResult
        public func bindColumn(name: String) -> Property<T, V> {
            columnName = name
            return self
        }
    }
}
