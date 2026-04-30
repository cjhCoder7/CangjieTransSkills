package ohos_app_cangjie_entry

class BillFilter {
    public func `match`(record: BillRecordModel, query: BillQuery): Bool {
        if (let Some(keyword) <- query.keyword) {
            if (!record.title.contains(keyword)) {
                return false
            }
        }
        if (let Some(category) <- query.category) {
            if (record.category != category) {
                return false
            }
        }
        if (let Some(startTime) <- query.startTime) {
            if (record.timestamp < startTime) {
                return false
            }
        }
        if (let Some(endTime) <- query.endTime) {
            if (record.timestamp > endTime) {
                return false
            }
        }
        if (let Some(minAmount) <- query.minAmount) {
            if (record.amount < minAmount) {
                return false
            }
        }
        if (let Some(maxAmount) <- query.maxAmount) {
            if (record.amount > maxAmount) {
                return false
            }
        }
        true
    }
}
