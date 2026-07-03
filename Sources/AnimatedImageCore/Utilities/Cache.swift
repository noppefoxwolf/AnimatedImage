import Foundation

nonisolated package final class Cache<Key: Hashable, Value>: @unchecked Sendable {
    private let wrapped = NSCache<WrappedKey, Entry>()

    package init(name: String) {
        wrapped.name = name
    }

    package var countLimit: Int {
        get { wrapped.countLimit }
        set { wrapped.countLimit = newValue }
    }

    // If 0, there is no total cost limit. The default value is 0.
    package var totalCostLimit: Int {
        get { wrapped.totalCostLimit }
        set { wrapped.totalCostLimit = newValue }
    }

    package func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
    }

    package func insert(_ value: Value, forKey key: Key, cost: Int) {
        let entry = Entry(value)
        wrapped.setObject(entry, forKey: WrappedKey(key), cost: cost)
    }

    package func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }

    package func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    package func removeAllObjects() {
        wrapped.removeAllObjects()
    }
}

//Our WrappedKey type will, wrap our Key values in order to make them NSCache compatible
extension Cache {
    fileprivate nonisolated final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) {
            self.key = key
        }

        override var hash: Int {
            key.hashValue
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? WrappedKey else { return false }
            return key == other.key
        }
    }

    fileprivate nonisolated final class Entry {
        let value: Value

        init(_ value: Value) {
            self.value = value
        }
    }
}

//Let's make a subscript for easy use
extension Cache {
    package subscript(key: Key) -> Value? {
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
