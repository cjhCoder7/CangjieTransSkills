/**
 * Created on 2025/8/11
 */
package ohos_app_cangjie_entry.components.List

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.resource_manager.*
import cj_res_entry.app
import std.collection.ArrayList

let userListItemFontSize: Int64 = 24
let userListItemLineHeight: Int64 = 40


@Component
public class UserList{
    @Prop var userEntities: ObservedArrayList<UserEntity>

    func getLocationFlag(locate: String): CJResource {
        match (locate) {
            case "UK" => @r(app.media.UK)
            case "US" => @r(app.media.US)
            case "UAE" => @r(app.media.UAE)
            case "Spain" => @r(app.media.Spain)
            case "Singapore" => @r(app.media.Singapore)
            case "NewZealand" => @r(app.media.NewZealand)
            case "Japan" => @r(app.media.Japan)
            case "Germany" => @r(app.media.Germany)
            case "France" => @r(app.media.France)
            case "Australia" => @r(app.media.Australia)
            case _ => @r(app.media.UK)
        }
    }

    @Builder
    func userListItem(userEntity: UserEntity) {
        ListItem() {
            Column(10.lpx) {
                Flex() {
                    Text(userEntity.name).fontSize(userListItemFontSize.lpx)
                        .lineHeight(userListItemLineHeight.lpx).flexGrow(1)

                     Text(userEntity.phoneNumber).fontSize(userListItemFontSize.lpx)
                        .lineHeight(userListItemLineHeight.lpx)
                }.width(100.percent)
                Flex() {
                    Text(userEntity.email).fontSize(userListItemFontSize.lpx)
                        .lineHeight(userListItemLineHeight.lpx).fontStyle(FontStyle.Italic)

                    Row() {
                        Image(getLocationFlag(userEntity.country)).height(userListItemLineHeight.lpx)
                            .margin(right: 10.lpx)

                        Text(userEntity.city).fontSize(userListItemFontSize.lpx).lineHeight(userListItemLineHeight.lpx)
                    }.flexGrow(1).justifyContent(FlexAlign.End)
                }.width(100.percent)
            }.width(100.percent)
        }.width(100.percent)
    }


    func build() {
        List(space: 30) {
            ForEach(userEntities, itemGeneratorFunc: { userEntity: UserEntity, index: Int64 =>
                userListItem(userEntity)
            }, keyGeneratorFunc: { userEntity: UserEntity, index: Int64 => "userEntity-${userEntity.name}-${index}"})
        }.width(100.percent).divider(strokeWidth: 1.lpx, color: Color(0xdee2e6)).padding(20.lpx)
            .border(width: 1.lpx, color: Color(0xdee2e6), radius: 20.lpx)
            .backgroundColor(0xfcfcfc).height(800.lpx)
    }
}
