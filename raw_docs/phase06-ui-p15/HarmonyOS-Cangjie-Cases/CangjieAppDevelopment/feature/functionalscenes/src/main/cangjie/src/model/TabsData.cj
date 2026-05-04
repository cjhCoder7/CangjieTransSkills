/**
 * Created on 2024/9/9
 */
package functionalscenes.model

public class TabDataModel {
    public TabDataModel(
        public let id: Int64,
        public let navData: String
    ) {}
}

public let TAB_DATA: Array<TabDataModel> = [
    TabDataModel(0, "全部"),
    TabDataModel(1, "UI布局"),
    TabDataModel(2, "动效"),
    TabDataModel(3, "三方库"),
    TabDataModel(4, "Native"),
    TabDataModel(5, "性能示例"),
    TabDataModel(6, "其他")
]