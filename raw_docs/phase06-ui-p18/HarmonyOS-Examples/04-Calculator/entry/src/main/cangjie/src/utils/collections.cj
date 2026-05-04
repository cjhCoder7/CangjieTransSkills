/**
 * Created on 2025/7/18
 */
package ohos_app_cangjie_entry.utils
import std.collection.*

public class Stack<T> {
    let stack: ArrayList<T> = ArrayList()

    public func push(ele: T) {
        stack.append(ele)
    }

    public func pop() {
        stack.remove(stack.size - 1)
    }

    public func peek() {
        stack[stack.size - 1]
    }

    public func isEmpty() {
        stack.isEmpty()
    }

    public func size() {
        return stack.size
    }
}