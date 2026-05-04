from ohos import base.*
from ohos import component.*
from ohos import state_manage.*
from ohos import state_macro_manage.*
from std import collection.*
import editor_kit.*
import editor_kit.editorKitUtils.*

@Entry
@Component
class MyView {
    // 子组件高度
    var height: Float64 = 300.0

    // 子组件宽度
    var width: Float64 = 380.0

    // language 默认 C 语言
    var language: LANGUAGETYPE = LANGUAGETYPE.C

    // fontSize 默认 16
    var fontSize: Int64 = 16

    // theme 默认 DARCULA
    var theme: THEMENAMETYPE = THEMENAMETYPE.DARCULA

    // tabLen 默认 4
    var tabLen: Int64 = 4

    var text: String = """
/**
 * Note: The returned array must be malloced, assume caller calls free().
 */
int* twoSum(int* nums, int numsSize, int target, int* returnSize) {

}"""

    func getTemplate(language: LANGUAGETYPE): String {
        match (language) {
            case LANGUAGETYPE.C => return """
/**
 * Note: The returned array must be malloced, assume caller calls free().
 */
int* twoSum(int* nums, int numsSize, int target, int* returnSize) {

}"""
            case LANGUAGETYPE.CANGJIE => return """
class Solution {
    public func twoSum(nums: ArrayList<Int64>, target: Int64): ArrayList<Int64> {

    }
}"""
            case LANGUAGETYPE.GO => return """
func twoSum(nums []int, target int) []int {

}"""
            case LANGUAGETYPE.JAVA => return """
class Solution {
    public int[] twoSum(int[] nums, int target) {

    }
}"""
            case LANGUAGETYPE.KOTLIN => return """
class Solution {
    fun twoSum(nums: IntArray, target: Int): IntArray {

    }
}"""
            case LANGUAGETYPE.SWIFT => return """
class Solution {
    func twoSum(_ nums: [Int], _ target: Int) -> [Int] {

    }
}"""
            case LANGUAGETYPE.PYTHON => return """
class Solution(object):
    def twoSum(self, nums, target):
        \"\"\"
        :type nums: List[int]
        :type target: int
        :rtype: List[int]
        \"\"\""""
            case LANGUAGETYPE.PYTHON3 => return """
class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:"""
            case LANGUAGETYPE.RUST => return """
impl Solution {
   pub fn two_sum(nums: Vec<i32>, target: i32) -> Vec<i32> {

   }
}"""
            case LANGUAGETYPE.JAVASCRIPT => return """
/**
 * @param {number[]} nums
 * @param {number} target
 * @return {number[]}
 */
var twoSum = function(nums, target) {

};"""
            case LANGUAGETYPE.TYPESCRIPT => return """
function twoSum(nums: number[], target: number): number[] {

};"""
            case LANGUAGETYPE.CSHARP => return """
public class Solution {
    public int[] TwoSum(int[] nums, int target) {

    }
}"""
            case LANGUAGETYPE.CPP => return """
class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {

    }
};"""
             case LANGUAGETYPE.OTHERS => return """
others
others"""
        }
    }

    var editorKitController: EditorKitController = EditorKitController(width: width, height: height, language: language, text: text)

    // 测试用户输入不同语言，不同字体大小时候响应情况
    let tabLenArray = [2, 4, 8]
    let languageArray = [LANGUAGETYPE.C, LANGUAGETYPE.CANGJIE, LANGUAGETYPE.GO, LANGUAGETYPE.JAVA, LANGUAGETYPE.KOTLIN, LANGUAGETYPE.SWIFT, LANGUAGETYPE.PYTHON, LANGUAGETYPE.PYTHON3, LANGUAGETYPE.RUST, LANGUAGETYPE.JAVASCRIPT, LANGUAGETYPE.TYPESCRIPT, LANGUAGETYPE.CSHARP, LANGUAGETYPE.CPP, LANGUAGETYPE.OTHERS]
    let fontSizeArray = [12, 13, 14, 15, 16, 18, 20]
    let themeNameArray = [THEMENAMETYPE.DARCULA, THEMENAMETYPE.MONOKAI, THEMENAMETYPE.OBSIDIAN, THEMENAMETYPE.LADIES_NIGHT, THEMENAMETYPE.TOMORROW_NIGHT, THEMENAMETYPE.VISUAL_STUDIO, THEMENAMETYPE.INTELLIJ_LIGHT, THEMENAMETYPE.SOLARIZED_LIGHT, THEMENAMETYPE.ECLIPSE]
    let textArray = ["text 1","thiewanfia", "china", "this is a luanma", "oh my god", "finish?"]

    protected func onAppear() {
    }

    func render() {
        Column() {
            // 调用editorKit组件，并给属性赋初始值。
            EditorKit(
                editorKitController: editorKitController,
            )

           Column(){
               Text("高度")
                   .fontSize(16)
                   .backgroundColor(Color.GRAY)
               Flex(FlexParams(wrap: FlexWrap.Wrap)) {
                       Button("300vp")
                           .shape(ShapeType.Capsule)
                           .stateEffect(true)
                           .width(120)
                           .height(40)
                           .backgroundColor(0x317aff)
                           .fontSize(16.fp)
                           .onClick({ =>
                               editorKitController.setHeight(300.0)
                           })
                        Button("600vp")
                           .shape(ShapeType.Capsule)
                           .stateEffect(true)
                           .width(120)
                           .height(40)
                           .backgroundColor(0x317aff)
                           .fontSize(16.fp)
                           .onClick({ =>
                               editorKitController.setHeight(600.0)
                           })
                }
            }.borderWidth(2.vp)

            //测试切换主题接口，设置主题接口
            Column(){
                Text("切换主题")
                    .fontSize(16)
                    .backgroundColor(Color.GRAY)
                Flex(FlexParams(alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap)) {
                    ForEach(themeNameArray, itemGeneratorFunc: {item: THEMENAMETYPE, idx: Int64 =>
                        Button(convertTheme(item))
                            .shape(ShapeType.Capsule)
                            .stateEffect(true)
                            .height(40)
                            .width(110)
                            .backgroundColor(0x317aff)
                            .fontSize(14.fp)
                            .onClick({ =>
                                editorKitController.setTheme(item)
                            })
                    })
                }
            }.borderWidth(2.vp)

            // 测试切换语言接口 设置语言接口
            Column(){
                Text("切换文本")
                    .fontSize(16)
                    .backgroundColor(Color.GRAY)
                Flex(FlexParams(wrap: FlexWrap.Wrap)) {
                    ForEach(textArray, itemGeneratorFunc: {item: String, idx: Int64 =>
                        Button(idx.toString())
                            .shape(ShapeType.Capsule)
                            .stateEffect(true)
                            .width(50)
                            .height(40)
                            .backgroundColor(0x317aff)
                            .fontSize(14.fp)
                            .onClick({ =>
                                editorKitController.setText(item)
                            })
                    })
                }
            }.borderWidth(2.vp)

            // 测试切换字体大小接口，设置字体接口
            Column(){
                Text("切换字体")
                    .fontSize(16)
                    .backgroundColor(Color.GRAY)
                Flex(FlexParams(alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap)) {
                    ForEach(fontSizeArray, itemGeneratorFunc: {item: Int64, idx: Int64 =>
                        Button(item.toString())
                            .shape(ShapeType.Capsule)
                            .stateEffect(true)
                            .width(50)
                            .height(40)
                            .backgroundColor(0x317aff)
                            .fontSize(14.fp)
                            .onClick({ =>
                                editorKitController.setFontSize(item)
                            })
                    })
                }
            }.borderWidth(2.vp)

            //测试切换缩进长度，设置tab接口
            Column(){
                Text("切换缩进长度")
                    .fontSize(16)
                    .backgroundColor(Color.GRAY)
                Flex(FlexParams(alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap)) {
                    ForEach(tabLenArray, itemGeneratorFunc: {item: Int64, idx: Int64 =>
                        Button(item.toString())
                            .shape(ShapeType.Capsule)
                            .stateEffect(true)
                            .height(40)
                            .backgroundColor(0x317aff)
                            .fontSize(14.fp)
                            .onClick({ =>
                                editorKitController.setTabLen(item)
                            })
                    })
                }
            }.borderWidth(2.vp)

            // 测试切换语言接口 设置语言接口
            Column(){
                Text("切换语言")
                    .fontSize(16)
                    .backgroundColor(Color.GRAY)
                Flex(FlexParams(wrap: FlexWrap.Wrap)) {
                    ForEach(languageArray, itemGeneratorFunc: {item: LANGUAGETYPE, idx: Int64 =>
                        Button(convertLanguage(item))
                            .shape(ShapeType.Capsule)
                            .stateEffect(true)
                            .width(90)
                            .height(40)
                            .backgroundColor(0x317aff)
                            .fontSize(16.fp)
                            .onClick({evt =>
                                editorKitController.setLanguageAndText(item, getTemplate(item))
                            })
                    })
                }
            }.borderWidth(2.vp)

        }
    }
}
