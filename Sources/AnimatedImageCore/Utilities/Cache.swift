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
    let entry = Entry(value: value)
    wrapped.setObject(entry, forKey: WrappedKey(key))
  }

  func insert(_ value: Value, forKey key: Key, cost: Int) {
    let entry = Entry(value: value)
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
  fileprivate final class WrappedKey: NSObject {
    let key: Key

    init(_ key: Key) { self.key = key }

    override var hash: Int { return key.hashValue }

    override func isEqual(_ object: Any?) -> Bool {
      guard let value = object as? WrappedKey else {
        return false
      }

      return value.key == key
    }
  }

  fileprivate final class Entry {
    let value: Value

    init(value: Value) {
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
