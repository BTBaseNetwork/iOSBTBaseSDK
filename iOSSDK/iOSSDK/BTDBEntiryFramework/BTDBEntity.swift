//
//  BTDBEntity.swift
//  BTBaseSDK
//
//  Created by Alex Chow on 2018/6/6.
//  Copyright © 2018年 btbase. All rights reserved.
//

import Foundation

public protocol BTDBEntityModel {
    static func newDefaultModel() -> BTDBEntityModel
    static func onBuildBTDBEntity(entity: BTDBEntity.Builder)
}

public class BTDBEntity {
    private(set) var properties = [PropertyBase]()
    var scheme: String
    
    init(scheme: String) {
        self.scheme = scheme
    }
    
    private func addProperty(property: PropertyBase) {
        properties.append(property)
    }
}

extension BTDBEntity {
    func getProperties<T>() -> [Property<T>] {
        return properties as! [Property<T>]
    }
    
    func getPrimaryKey<T>() -> [Property<T>] {
        let keys = properties.filter { $0.primaryKey }
        return keys as! [Property<T>]
    }
    
    func getNotPrimaryKey<T>() -> [Property<T>] {
        let keys = properties.filter { !$0.primaryKey }
        return keys as! [Property<T>]
    }
    
    var primaryKeys: [PropertyBase] {
        return properties.filter { $0.primaryKey }
    }
    
    var notPrimaryKeys: [PropertyBase] {
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
        public func hasProperty<T>(_ name: String, _ type: Any, setter: @escaping PropertyAccessor<T>.Setter) -> Property<T> {
            let defaultGetter: PropertyAccessor<T>.Getter = { model in
                let modelMirror = Mirror(reflecting: model)
                let modelP = modelMirror.children.first(where: { (label, _) -> Bool in
                    label! == name
                })!
                return modelP.value
            }
            
            /* TODO: after swift upgrade reflecting features*/
            
            let defaultSetter: PropertyAccessor<T>.Setter = { model, value in
                setter(model, value)
            }
            
            let accessor = PropertyAccessor<T>.init(getter: defaultGetter, setter: defaultSetter)
            
            let pt = Property<T>(name, type, accessor: accessor)
            entity.addProperty(property: pt)
            return pt
        }
        
        public func build<T>(_ type: T.Type) -> BTDBEntity where T: BTDBEntityModel {
            T.onBuildBTDBEntity(entity: self)
            return entity
        }
    }
    
    public class PropertyBase {
        private(set) var propertyName: String
        private(set) var valueType: Any
        var valueTypeName: String { return "\(valueType)" }
        
        private(set) var columnName: String
        private(set) var primaryKey = false
        private(set) var isNotNull = false
        private(set) var isUnique = false
        private(set) var isAutoIncrement = false
        private(set) var defaultValue: Any?
        private(set) var checkString: String?
        private(set) var length: Int = 0
        internal init(propertyName: String, valueType: Any) {
            self.propertyName = propertyName
            self.valueType = valueType
            columnName = propertyName
        }
        
        @discardableResult
        public func hasPrimaryKey(value: Bool = true) -> PropertyBase {
            primaryKey = value
            return self
        }
        
        @discardableResult
        public func notNull(value: Bool = true) -> PropertyBase {
            isNotNull = value
            return self
        }
        
        @discardableResult
        public func autoIncrement(value: Bool = true) -> PropertyBase {
            isAutoIncrement = value
            return self
        }
        
        @discardableResult
        public func hasDefaultValue(defaultValue: Any?) -> PropertyBase {
            self.defaultValue = defaultValue
            return self
        }
        
        @discardableResult
        public func unique(value: Bool = true) -> PropertyBase {
            isUnique = value
            return self
        }
        
        @discardableResult
        public func check(limited: String?) -> PropertyBase {
            checkString = limited
            return self
        }
        
        @discardableResult
        public func length(valueLength: Int) -> PropertyBase {
            length = valueLength
            return self
        }
        
        @discardableResult
        public func bindColumn(name: String) -> PropertyBase {
            columnName = name
            return self
        }
    }
    
    public class Property<T>: PropertyBase {
        var accessor: PropertyAccessor<T>!
        internal init(_ propertyName: String, _ valueType: Any, accessor: PropertyAccessor<T>) {
            self.accessor = accessor
            super.init(propertyName: propertyName, valueType: valueType)
        }
    }
    
    public class PropertyAccessor<T> {
        public typealias Setter = (_ model: T, _ value: Any?) -> Void
        public typealias Getter = (_ model: T) -> Any?
        internal private(set) var getValue: Getter
        internal private(set) var setValue: Setter
        init(getter: @escaping Getter, setter: @escaping Setter) {
            getValue = getter
            setValue = setter
        }
    }
}
