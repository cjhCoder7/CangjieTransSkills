/**
 * Created on 2025/2/26
 */
package ohos_app_cangjie_entry_test

import std.unittest.expectEqual
import std.unittest.testmacro.Expect

func unittest() {
    let a = "abc"
    let b = "b"
    @Expect(a.contains(b))
    @Expect(a, a)
}