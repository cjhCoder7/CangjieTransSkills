/**
 * Created on 2024/8/26
 */
package ohos_app_cangjie_entry.global

import ohos_app_cangjie_entry.entity.*
import ohos_app_cangjie_entry.mock.*

public class DataStore<T> {
    private var _data: T

    public init(data: T) {
        this._data = data
    }

    public func get(): T {
        return this._data;
    }

    public func set(data: T) {
        this._data = data
    }
}

public let LOCAL_USER = user1
public var CURRENT_CHAT: DataStore<Chat> = DataStore<Chat>(chat1)
public var TARGET_USER: DataStore<User> = DataStore<User>(user1)
public var CURRENT_GROUP: DataStore<Group> = DataStore<Group>(group1)