package ohos_app_cangjie_entry

import std.collection.ArrayList

class DataExportManager {
    public func toJson(records: Array<BillRecordModel>): String {
        var items = ArrayList<String>()
        for (r in records) {
            items.add("{\"id\":${r.id},\"type\":\"${r.billType}\",\"category\":\"${r.category}\",\"title\":\"${r.title}\",\"amount\":${r.amount},\"timestamp\":${r.timestamp}}")
        }
        "[" + String.join(items.toArray(), delimiter: ",") + "]"
    }

    public func toCsv(records: Array<BillRecordModel>): String {
        var header = "id,type,category,title,amount,timestamp"
        var rows = ArrayList<String>()
        for (item in records) {
            rows.add("${item.id},${item.billType},${item.category},${item.title},${item.amount},${item.timestamp}")
        }
        var all = ArrayList<String>()
        all.add(header)
        for (r in rows) { all.add(r) }
        String.join(all.toArray(), delimiter: "\n")
    }

    public func exportFile(records: Array<BillRecordModel>, format: String): FeatureResult {
        featureSuccess("export:${format}:${records.size}")
    }
}
