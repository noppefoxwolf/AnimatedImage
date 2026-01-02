import Foundation

final class Cache<Key: Hashable, Value>: @unchecked Sendable {
    private let wrapped = NSCache<WrappedKey, Entry>()

    public init(name: String) {
        wrapped.name = name
    }

    var countLimit: Int {
        get { wrapped.countLimit }
        set { wrapped.countLimit = newValue }
    }

    var totalCostLimit: Int {
        get { wrapped.totalCostLimit }
        set { wrapped.totalCostLimit = newValue }
    }

    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
    }

    func insert(_ value: Value, forKey key: Key, cost: Int) {
        let entry = Entry(value)
        wrapped.setObject(entry, forKey: WrappedKey(key), cost: cost)
    }

    func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    func removeAllObjects() {
        wrapped.removeAllObjects()
    }
}

//Our WrappedKey type will, wrap our Key values in order to make them NSCache compatible
extension Cache {
    fileprivate final class WrappedKey: Hashable {
        let key: Key
        
        init(_ key: Key) {
            self.key = key
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(key)
        }
        
        static func == (lhs: Cache<Key, Value>.WrappedKey, rhs: Cache<Key, Value>.WrappedKey) -> Bool {
            lhs.key == rhs.key
        }
    }

    fileprivate final class Entry {
        let value: Value

        init(_ value: Value) {
            self.value = value
        }
    }
}

//Let's make a subscript for easy use
extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}
