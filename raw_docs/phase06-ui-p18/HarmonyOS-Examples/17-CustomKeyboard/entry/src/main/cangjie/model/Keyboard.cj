/**
 * Created on 2025/8/1
 */
package ohos_app_cangjie_entry.model
import std.collection.ArrayList

// 省份键盘数据
let province:ArrayList<String> = ArrayList<String>(['京', '豫', '川', '赣', '津', '沪', '粤', '渝', '港', '甘', '青', '苏', '藏', '澳', '晋', '冀', '新', '湘', '鄂',
    '鲁', '宁', '辽', '台', '皖', '吉', '云', '陕', '琼', '黑', '闽', '桂', '贵', '浙', '蒙'])

let upperCase = ArrayList<String>(['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z'])

let numeric = ArrayList<String>(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z'])



public enum KeyboardType {
	PROVINCE | UPPERCASE | NUMBERIC
}

public class KeyBoard {
    public var keyboardType: KeyboardType
    public var keyboardValue: ArrayList<String>
    public var rowCount: Int64
    public var columnCount: Int64
    public var rowTemplateStr: String = ""
    public var columnTemplateStr: String = ""
    public var x: Int64
    public var y: Int64

    public init(keyboardType: KeyboardType) {
        this.keyboardType = keyboardType
        let a = this.keyboardType
        match (a) {
            case PROVINCE => this.keyboardValue = province
            this.rowCount = 4
            this.columnCount = 7
            this.x = 153
            this.y = 141

            case UPPERCASE => this.keyboardValue = upperCase
            this.rowCount = 4
            this.columnCount = 7
            this.x = 164
            this.y = 141

            case NUMBERIC => this.keyboardValue = numeric
            this.rowCount = 4
            this.columnCount = 7
            this.x = 153
            this.y = 141
        }

        for (i in 1..=this.rowCount) {
            this.rowTemplateStr += "1fr "
        }
        this.rowTemplateStr += "1fr"

        for (i in 1..=this.columnCount) {
            this.columnTemplateStr += "1fr "
        }
        this.columnTemplateStr += "1fr"
    }
}