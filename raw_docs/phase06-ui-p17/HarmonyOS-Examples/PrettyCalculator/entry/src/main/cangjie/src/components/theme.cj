/**
 * Created on 2024/9/5
 */
package ohos_app_cangjie_entry.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.display.*
import ohos.state_macro_manage.*

import cj_res_entry.app
import std.collection.ArrayList
import std.convert.Parsable

public class Theme {
    public Theme(
        var foregroundColor !: Color = Color(0xFEB6B3),
        var backgroundColor !: Color = Color(0xFAD9DC)
    ) {}
}

public let themes: Array<Theme> = [
    Theme(foregroundColor: Color(0xFEB6B3), backgroundColor: Color(0xFAD9DC)),
    Theme(foregroundColor: Color(0x31D2C7), backgroundColor: Color(0xC5EFE3)),
    Theme(foregroundColor: Color(0x36AFFF), backgroundColor: Color(0xCFF1FF)),
    Theme(foregroundColor: Color(0x5F5A91), backgroundColor: Color(0x817AC4)),
    Theme(foregroundColor: Color(0xFF9900), backgroundColor: Color(0xFFCC00))
]

