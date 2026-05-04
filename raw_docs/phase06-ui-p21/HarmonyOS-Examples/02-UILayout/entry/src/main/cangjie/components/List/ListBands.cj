/**
 * Created on 2025/8/12
 */
package ohos_app_cangjie_entry.components.List

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import std.collection.ArrayList
import std.time.*
import std.sync.*



@Component
public class SimpleList {
    @State var userEntities: ObservedArrayList<UserEntity> = ObservedArrayList<UserEntity>(generateUserEntities(5))

    func build() {
        Column() {
            UserList(userEntities: userEntities)
        }.margin(bottom: 20.lpx)
    }
}


@Component
public class AddMoreList {
    @State var userEntities: ObservedArrayList<UserEntity> = ObservedArrayList<UserEntity>(generateUserEntities(5))

    func addMoreOnClick() {
        userEntities.appendAll(generateUserEntities(5))
    }

    func build() {
        Column(20.lpx) {
            UserList(userEntities: userEntities)

            Button("Add More").fontSize(26.lpx).fontColor(0x000000).backgroundColor(0xffffff)
                .border(width: 2.lpx, color: Color(0x000000), radius: 20.lpx).onClick({ e: ClickEvent => addMoreOnClick() })
        }.margin(bottom: 20.lpx)
    }
}

@Component
public class PaginationList {
    let pageNum: Int64 = 5
    let userEntityStore = Array<ArrayList<UserEntity>>(pageNum, { _ => generateUserEntities(5) })
    @State var userEntities: ObservedArrayList<UserEntity> = ObservedArrayList<UserEntity>(userEntityStore[0])
    let pageArray: Array<Int64> = Array<Int64>(pageNum, { index: Int64 => index + 1 })
    @State var currentPage: Int64 = 1

    func pageBtnOnClick(page: Int64) {
        if (page == currentPage) {
            return
        }
        currentPage = page
        userEntities.set(userEntityStore[currentPage - 1])
    }

    @Builder
    func pageBtn(pageNum: Int64, fontColor: UInt32, bgColor: UInt32) {
        Button("${pageNum}").fontSize(22.lpx).fontColor(fontColor).backgroundColor(bgColor)
            .shape(ShapeType.Normal).border(width: 2.lpx, color: Color(0x000000), radius: 10.lpx)
            .onClick({ e: ClickEvent => pageBtnOnClick(pageNum) })
    }

    func build() {
        Column(20.lpx) {
            UserList(userEntities: userEntities)

            List(space: 10) {
                ForEach(pageArray, itemGeneratorFunc: { n: Int64, index: Int64 =>
                    ListItem() {
                        if (n == currentPage) {
                                pageBtn(n, 0xffffff, 0x000000)
                        } else {
                                pageBtn(n, 0x000000, 0xffffff)
                        }
                    }
                }, keyGeneratorFunc: { n: Int64, index: Int64 => "pageNum-${n}" })
            }.listDirection(Axis.Horizontal)
        }.margin(bottom: 20.lpx)
    }
}
