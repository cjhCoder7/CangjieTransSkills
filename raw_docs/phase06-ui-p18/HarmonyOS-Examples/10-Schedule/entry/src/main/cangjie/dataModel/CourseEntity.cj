/**
 * Created on 2025/7/25
 */
package ohos_app_cangjie_entry.dataModel

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import cj_res_entry.*
import std.collection.*

let COURSE_MODEL = ArrayList<CourseItem>([
    CourseItem(@r(app.string.empty), Color.WHITE),
    CourseItem(@r(app.string.course8), Color(0xEDC7FF)),
    CourseItem(@r(app.string.course5_1), Color(0xFFE1E8)),
    CourseItem(@r(app.string.course2), Color(0xE1F9FF)),
    CourseItem(@r(app.string.course1_1), Color(0xE5F0E1)),
    CourseItem(@r(app.string.course7), Color(0xFFDACC)),
    CourseItem(@r(app.string.course6), Color(0xECFC9A)),
    CourseItem(@r(app.string.course5), Color(0xFFE1E8)),
    CourseItem(@r(app.string.course4_1), Color(0xFFFCA3)),
    CourseItem(@r(app.string.course4), Color(0xFBF0FF)),
    CourseItem(@r(app.string.course3), Color(0xFFE4C7)),
    CourseItem(@r(app.string.course1), Color(0xFFF0F0)),
    CourseItem(@r(app.string.course9), Color(0xECDC96))
])

func createCourseTable(indexMatrix: Array<Array<Int64>>) {
    var courseTable = ArrayList<ArrayList<CourseItem>>()
    for (rowIndices in indexMatrix) {
        var courseRow = ArrayList<CourseItem>()
        for (i in rowIndices) {
            courseRow.append(COURSE_MODEL[i])
        }
        courseTable.append(courseRow)
    }
    return courseTable
}

public class CourseEntity {
    let courseIndexMatrix = [
        [0, 1, 4, 1, 10, 2, 0],
        [3, 1, 4, 1, 10, 2, 0],
        [5, 8, 9, 0, 0, 7, 10],
        [5, 8, 9, 0, 0, 7, 10],
        [11, 1, 2, 0, 0, 0, 0],
        [11, 12, 2, 12, 0, 0, 0],
        [11, 12, 2, 12, 4, 5, 0],
        [0, 0, 6, 1, 4, 5, 6]
    ]
    public let data = createCourseTable(courseIndexMatrix)
    public let arr = ArrayList<Int64>([0, 1, 2, 3, 4, 5, 6, 7])
}