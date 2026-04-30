package ohos_app_cangjie_entry

import kit.ArkUI.*
import kit.BasicServicesKit.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import std.convert.*

// ===== 日期时间辅助 =====

class DateParts {
    public var year: Int64
    public var month: Int64
    public var day: Int64
    public var hour: Int64
    public var minute: Int64
    public init(year: Int64, month: Int64, day: Int64, hour: Int64, minute: Int64) {
        this.year = year
        this.month = month
        this.day = day
        this.hour = hour
        this.minute = minute
    }
}

func currentTimestamp(): Float64 {
    Float64(SystemDateTime.getTime())
}

func dateTimeFromTimestamp(ts: Float64): DateParts {
    let ms = Int64(ts)
    let totalSec = ms / 1000
    let days = totalSec / 86400
    let timeOfDay = totalSec % 86400
    let a = days + 719468
    let era = (if (a >= 0) { a } else { a - 146096 }) / 146097
    let remainder = a - era * 146097
    let yoe = (remainder - remainder / 1460 + remainder / 36524 - remainder / 146096) / 365
    let doy = remainder - (365 * yoe + yoe / 4 - yoe / 100)
    let mp = (5 * doy + 2) / 153
    let day = doy - (153 * mp + 2) / 5 + 1
    let month = if (mp < 10) { mp + 3 } else { mp - 9 }
    let year = yoe + era * 400 + (if (month <= 2) { 1 } else { 0 })
    let hour = timeOfDay / 3600
    let minute = (timeOfDay % 3600) / 60
    DateParts(year, month, day, hour, minute)
}

func dateTimeToTimestamp(year: Int64, month: Int64, day: Int64): Float64 {
    let a = if (month <= 2) { year - 1 } else { year }
    let m = if (month <= 2) { month + 9 } else { month - 3 }
    let y = a
    let daysSinceEpoch = 365 * y + y / 4 - y / 100 + y / 400 + (153 * m + 2) / 5 + day - 719468
    Float64(daysSinceEpoch * 86400 + 12 * 3600) * 1000.0
}

// 字符中字符数
func runeCount(s: String): Int64 {
    var c: Int64 = 0
    for (_ in s.runes()) { c++ }
    c
}

// 取首字符
func firstRune(s: String): String {
    for (r in s.runes()) {
        return "${r}"
    }
    ""
}

// 安全 contains
func strContains(s: String, sub: String): Bool {
    s.contains(sub)
}

// 尝试解析 Float64
func tryParseFloat(s: String): Float64 {
    match (Float64.tryParse(s)) {
        case Some(v) => v
        case None => 0.0
    }
}

// 移除字符串中的数字
func removeDigits(s: String): String {
    var result = StringBuilder()
    var inDigit = false
    for (r in s.runes()) {
        if (r >= r'0' && r <= r'9') {
            inDigit = true
        } else if (r == r'.' && inDigit) {
            inDigit = true
        } else {
            inDigit = false
            result.append("${r}")
        }
    }
    result.toString()
}

// 提取字符串中第一个数字
func extractFirstNumber(s: String): String {
    var found = false
    var result = StringBuilder()
    var hasDot = false
    for (r in s.runes()) {
        if (r >= r'0' && r <= r'9') {
            found = true
            result.append("${r}")
        } else if (r == r'.' && found && !hasDot) {
            hasDot = true
            result.append(".")
        } else if (found) {
            break
        }
    }
    result.toString()
}

// Color 辅助：从十六进制字符串创建
func colorFromHex(hex: String): Color {
    Color(UInt32.parse(hex.replace("#", ""), radix: 16))
}

// ===== 数据模型 =====

class CategoryMeta {
    public var name: String
    public var color: String
    public init(name: String, color: String) {
        this.name = name
        this.color = color
    }
}

class CategoryStat {
    public var name: String = ""
    public var color: String = ""
    public var total: Float64 = 0.0
    public var count: Int64 = 0
    public var rate: Float64 = 0.0
}

class TrendPoint {
    public var label: String = ""
    public var amount: Float64 = 0.0
    public var count: Int64 = 0
}

class AiCategoryRule {
    public var aiType: String
    public var category: String
    public var keywords: Array<String>
    public init(aiType: String, category: String, keywords: Array<String>) {
        this.aiType = aiType
        this.category = category
        this.keywords = keywords
    }
}

class AiTypeRule {
    public var aiType: String
    public var keywords: Array<String>
    public init(aiType: String, keywords: Array<String>) {
        this.aiType = aiType
        this.keywords = keywords
    }
}

class ThemeMeta {
    public var name: String
    public var primary: String
    public var soft: String
    public var surface: String
    public var warn: String
    public init(name: String, primary: String, soft: String, surface: String, warn: String) {
        this.name = name
        this.primary = primary
        this.soft = soft
        this.surface = surface
        this.warn = warn
    }
}

// ===== 常量 =====

let EXPENSE_CATEGORIES: Array<CategoryMeta> = [
    CategoryMeta("餐饮", "#E98155"),
    CategoryMeta("交通", "#5D8AA8"),
    CategoryMeta("购物", "#C87086"),
    CategoryMeta("娱乐", "#8B7FB8"),
    CategoryMeta("居家", "#7D9A72"),
    CategoryMeta("学习", "#D4A24C"),
    CategoryMeta("医疗", "#6EA6A1"),
    CategoryMeta("旅行", "#6F8FC7"),
    CategoryMeta("其他", "#8A8F98")
]

let INCOME_CATEGORIES: Array<CategoryMeta> = [
    CategoryMeta("工资", "#5E9F78"),
    CategoryMeta("兼职", "#5D8AA8"),
    CategoryMeta("理财", "#D4A24C"),
    CategoryMeta("红包", "#C87086"),
    CategoryMeta("其他", "#8A8F98")
]

let THEMES: Array<ThemeMeta> = [
    ThemeMeta("静谧蓝", "#4F7F98", "#E8F0F3", "#F5F8F8", "#E98155"),
    ThemeMeta("活力橙", "#D98654", "#F8ECE3", "#FBF7F3", "#C75B55"),
    ThemeMeta("松石绿", "#5F9A8B", "#E7F2EE", "#F5FAF8", "#D88255"),
    ThemeMeta("沉静紫", "#7F75A8", "#EFECF6", "#F8F7FB", "#D46D62")
]

let DAY_MS: Float64 = 24.0 * 60.0 * 60.0 * 1000.0
let AMOUNT_MAX_LENGTH: Int64 = 10
let NOTE_MAX_LENGTH: Int64 = 40
let AI_TEXT_MAX_LENGTH: Int64 = 80

let AI_TYPE_RULES: Array<AiTypeRule> = [
    AiTypeRule("收入", ["赚", "挣", "收入", "收到", "收款", "入账", "转入", "报销", "退款", "奖金", "发薪", "工资", "兼职", "副业", "外快", "利息", "分红", "红包"]),
    AiTypeRule("支出", ["花", "买", "付", "支付", "消费", "支出", "扣款", "缴费", "充值", "订阅", "打车", "地铁", "公交", "外卖"])
]

let AI_CATEGORY_RULES: Array<AiCategoryRule> = [
    AiCategoryRule("收入", "兼职", ["兼职", "副业", "外快", "赚", "挣"]),
    AiCategoryRule("收入", "工资", ["工资", "薪水", "发薪", "奖金"]),
    AiCategoryRule("收入", "理财", ["理财", "利息", "分红"]),
    AiCategoryRule("收入", "红包", ["红包"]),
    AiCategoryRule("支出", "交通", ["地铁", "公交", "打车", "出租", "高铁", "机票"]),
    AiCategoryRule("支出", "餐饮", ["饭", "餐", "咖啡", "奶茶", "外卖", "早餐", "午饭", "晚饭"]),
    AiCategoryRule("支出", "购物", ["买", "购物", "衣服", "鞋", "生活用品"]),
    AiCategoryRule("支出", "娱乐", ["电影", "游戏", "演出", "会员"]),
    AiCategoryRule("支出", "学习", ["课程", "书", "学习", "培训"]),
    AiCategoryRule("支出", "医疗", ["药", "医院", "体检", "看病"]),
    AiCategoryRule("支出", "旅行", ["旅行", "酒店", "景区", "门票"])
]

// ===== 主页面 =====

@Entry
@Component
class EntryView {
    @State var activeTab: Int64 = 0
    @State var reportType: String = "支出"
    @State var recordType: String = "支出"
    @State var selectedCategory: String = "餐饮"
    @State var amountText: String = ""
    @State var noteText: String = ""
    @State var aiText: String = ""
    @State var recordDateText: String = ""
    @State var formMessage: String = ""
    @State var editingId: Int64 = -1
    @State var nextRecordId: Int64 = 7
    @State var monthlyBudget: Float64 = 3000.0
    @State var themeIndex: Int64 = 0
    @State var cachedExpenseTotal: Float64 = 0.0
    @State var cachedIncomeTotal: Float64 = 0.0
    @State var cachedExpenseCount: Int64 = 0
    @State var cachedIncomeCount: Int64 = 0
    @State var cachedExpenseStats: Array<CategoryStat> = []
    @State var cachedIncomeStats: Array<CategoryStat> = []
    @State var cachedExpenseTrend: Array<TrendPoint> = []
    @State var cachedIncomeTrend: Array<TrendPoint> = []
    @State var cachedLargestExpenseTitle: String = "暂无记录"
    @State var cachedLargestIncomeTitle: String = "暂无记录"
    @State var cachedLargestExpenseAmount: Float64 = 0.0
    @State var cachedLargestIncomeAmount: Float64 = 0.0
    @State var records: Array<BillRecordModel> = []

    protected override func aboutToAppear() {
        let seedNow = currentTimestamp()
        this.records = [
            BillRecordModel(1, "支出", "餐饮", "午饭", 35.0, seedNow - 2.0 * 60.0 * 60.0 * 1000.0),
            BillRecordModel(2, "支出", "交通", "地铁通勤", 7.0, seedNow - 6.0 * 60.0 * 60.0 * 1000.0),
            BillRecordModel(3, "收入", "工资", "四月工资", 8200.0, seedNow - DAY_MS),
            BillRecordModel(4, "支出", "购物", "生活用品", 128.5, seedNow - DAY_MS),
            BillRecordModel(5, "支出", "娱乐", "电影票", 48.0, seedNow - 3.0 * DAY_MS),
            BillRecordModel(6, "支出", "学习", "课程订阅", 199.0, seedNow - 4.0 * DAY_MS)
        ]
        this.recordDateText = formatDateInput(currentTimestamp())
        this.nextRecordId = findNextRecordId()
        refreshStats()
    }

    // ===== 工具方法 =====
    func currentTheme(): ThemeMeta { THEMES[this.themeIndex] }
    func totalByType(billType: String): Float64 { if (billType == "支出") { this.cachedExpenseTotal } else { this.cachedIncomeTotal } }
    func expenseTotal(): Float64 { totalByType("支出") }
    func incomeTotal(): Float64 { totalByType("收入") }
    func balance(): Float64 { incomeTotal() - expenseTotal() }
    func budgetRate(): Float64 { if (this.monthlyBudget <= 0.0) { 0.0 } else if (expenseTotal() / this.monthlyBudget > 1.0) { 1.0 } else { expenseTotal() / this.monthlyBudget } }
    func money(value: Float64): String { if (value - Float64(Int64(value)) == 0.0) { Int64(value).toString() } else { value.toString() } }
    func findNextRecordId(): Int64 { var m: Int64 = 0; for (item in this.records) { if (item.id > m) { m = item.id } }; m + 1 }
    func padNumber(value: Int64): String { if (value < 10) { "0${value}" } else { "${value}" } }
    func formatDateInput(timestamp: Float64): String { let d = dateTimeFromTimestamp(timestamp); "${d.year}-${padNumber(d.month)}-${padNumber(d.day)}" }
    func formatShortDate(timestamp: Float64): String { let d = dateTimeFromTimestamp(timestamp); "${padNumber(d.month)}/${padNumber(d.day)}" }
    func formatRecordTime(timestamp: Float64): String { let d = dateTimeFromTimestamp(timestamp); "${formatDateInput(timestamp)} ${padNumber(d.hour)}:${padNumber(d.minute)}" }

    func parseDateInput(value: String): Float64 {
        let n = value.trimAscii()
        if (n.size < 10) { return -1.0 }
        let yearOpt = Int64.tryParse(n[0..4])
        let monthOpt = Int64.tryParse(n[5..7])
        let dayOpt = Int64.tryParse(n[8..10])
        if (let Some(year) <- yearOpt) {
            if (let Some(month) <- monthOpt) {
                if (let Some(day) <- dayOpt) {
                    if (month < 1 || month > 12 || day < 1 || day > 31) { return -1.0 }
                    return dateTimeToTimestamp(year, month, day)
                }
            }
        }
        -1.0
    }

    func sanitizeText(value: String, maxLength: Int64): String {
        var result = StringBuilder()
        var count: Int64 = 0
        for (r in value.runes()) {
            if (count >= maxLength) { break }
            if (r != r'\n' && r != r'\r' && r != r'\t') { result.append("${r}"); count++ }
        }
        result.toString()
    }

    func currentCategories(): Array<CategoryMeta> { if (this.recordType == "支出") { EXPENSE_CATEGORIES } else { INCOME_CATEGORIES } }
    func categoryColor(category: String): String {
        var color = "#8A8F98"
        for (item in EXPENSE_CATEGORIES) { if (item.name == category) { color = item.color } }
        for (item in INCOME_CATEGORIES) { if (item.name == category) { color = item.color } }
        color
    }
    func categoryTotalByType(billType: String, category: String): Float64 { var total: Float64 = 0.0; for (item in this.records) { if (item.billType == billType && item.category == category) { total += item.amount } }; total }
    func categoryCountByType(billType: String, category: String): Int64 { var count: Int64 = 0; for (item in this.records) { if (item.billType == billType && item.category == category) { count++ } }; count }

    func buildCategoryStats(billType: String): Array<CategoryStat> {
        let metas = if (billType == "支出") { EXPENSE_CATEGORIES } else { INCOME_CATEGORIES }
        let total = totalByType(billType)
        var stats = ArrayList<CategoryStat>()
        for (item in metas) {
            let catAmount = categoryTotalByType(billType, item.name)
            if (catAmount > 0.0) {
                let stat = CategoryStat()
                stat.name = item.name; stat.color = item.color; stat.total = catAmount
                stat.count = categoryCountByType(billType, item.name)
                stat.rate = if (total > 0.0) { catAmount / total * 100.0 } else { 0.0 }
                stats.add(stat)
            }
        }
        stats.toArray()
    }

    func startOfDay(timestamp: Float64): Float64 { let d = dateTimeFromTimestamp(timestamp); dateTimeToTimestamp(d.year, d.month, d.day) }

    func buildTrendPoints(billType: String): Array<TrendPoint> {
        let todayStart = startOfDay(currentTimestamp())
        var points = ArrayList<TrendPoint>()
        var index: Int64 = 6
        while (index >= 0) {
            let dayStart = todayStart - Float64(index) * DAY_MS
            let point = TrendPoint()
            point.label = formatShortDate(dayStart); point.amount = 0.0; point.count = 0
            points.add(point)
            index--
        }
        for (item in this.records) {
            if (item.billType == billType) {
                let dayDiff = Int64((startOfDay(item.timestamp) - (todayStart - 6.0 * DAY_MS)) / DAY_MS)
                if (dayDiff >= 0 && dayDiff < points.size) {
                    points[dayDiff].amount += item.amount; points[dayDiff].count++
                }
            }
        }
        points.toArray()
    }

    func refreshStats() {
        var expTotal: Float64 = 0.0; var incTotal: Float64 = 0.0
        var expCount: Int64 = 0; var incCount: Int64 = 0
        var lExpAmt: Float64 = 0.0; var lIncAmt: Float64 = 0.0
        var lExpTitle = "暂无记录"; var lIncTitle = "暂无记录"
        for (item in this.records) {
            if (item.billType == "支出") {
                expTotal += item.amount; expCount++
                if (item.amount > lExpAmt) { lExpAmt = item.amount; lExpTitle = item.title }
            } else {
                incTotal += item.amount; incCount++
                if (item.amount > lIncAmt) { lIncAmt = item.amount; lIncTitle = item.title }
            }
        }
        this.cachedExpenseTotal = expTotal; this.cachedIncomeTotal = incTotal
        this.cachedExpenseCount = expCount; this.cachedIncomeCount = incCount
        this.cachedLargestExpenseTitle = lExpTitle; this.cachedLargestIncomeTitle = lIncTitle
        this.cachedLargestExpenseAmount = lExpAmt; this.cachedLargestIncomeAmount = lIncAmt
        this.cachedExpenseStats = buildCategoryStats("支出"); this.cachedIncomeStats = buildCategoryStats("收入")
        this.cachedExpenseTrend = buildTrendPoints("支出"); this.cachedIncomeTrend = buildTrendPoints("收入")
    }

    func countByType(billType: String): Int64 { if (billType == "支出") { this.cachedExpenseCount } else { this.cachedIncomeCount } }
    func averageByType(billType: String): Float64 { let c = countByType(billType); if (c == 0) { 0.0 } else { totalByType(billType) / Float64(c) } }
    func categoryStats(billType: String): Array<CategoryStat> { if (billType == "支出") { this.cachedExpenseStats } else { this.cachedIncomeStats } }

    func topCategoryStat(billType: String): CategoryStat {
        let stats = categoryStats(billType)
        if (stats.size > 0) { return stats[0] }
        let f = CategoryStat(); f.name = "暂无"; f.color = "#8A8F98"; f.total = 0.0; f.count = 0; f.rate = 0.0; f
    }

    func sortRecordsByTime(recs: Array<BillRecordModel>): Array<BillRecordModel> {
        var arr = ArrayList<BillRecordModel>()
        for (r in recs) { arr.add(r) }
        arr.sortBy { a, b => if (b.timestamp < a.timestamp) { Ordering.LT } else if (b.timestamp > a.timestamp) { Ordering.GT } else { Ordering.EQ } }
        arr.toArray()
    }

    func trendPoints(billType: String): Array<TrendPoint> { if (billType == "支出") { this.cachedExpenseTrend } else { this.cachedIncomeTrend } }
    func trendKey(point: TrendPoint): String { "${this.reportType}-${point.label}" }
    func categoryRankKey(item: CategoryStat): String { "${this.reportType}-${item.name}" }
    func maxTrendAmount(billType: String): Float64 { var m: Float64 = 0.0; for (p in trendPoints(billType)) { if (p.amount > m) { m = p.amount } }; m }
    func trendBarHeight(amount: Float64, billType: String): Int64 { let m = maxTrendAmount(billType); if (m <= 0.0) { 8 } else { let h = Int64(amount / m * 96.0); if (h < 10) { 10 } else { h } } }
    func largestRecordTitle(billType: String): String { if (billType == "支出") { this.cachedLargestExpenseTitle } else { this.cachedLargestIncomeTitle } }
    func largestRecordAmount(billType: String): Float64 { if (billType == "支出") { this.cachedLargestExpenseAmount } else { this.cachedLargestIncomeAmount } }
    func reportPrimaryColor(): String { if (this.reportType == "支出") { "#D46D62" } else { "#4E956C" } }
    func budgetLeft(): Float64 { if (this.monthlyBudget - expenseTotal() > 0.0) { this.monthlyBudget - expenseTotal() } else { 0.0 } }
    func savingRate(): Float64 { if (incomeTotal() <= 0.0) { 0.0 } else if (balance() / incomeTotal() * 100.0 > 0.0) { balance() / incomeTotal() * 100.0 } else { 0.0 } }

    func recordedDayCount(): Int64 {
        var days = ArrayList<String>()
        for (item in this.records) { let day = formatDateInput(item.timestamp); if (!days.contains(day)) { days.add(day) } }
        days.size
    }

    func categoryAmountInRange(category: String, startTime: Float64, endTime: Float64): Float64 {
        var total: Float64 = 0.0
        for (item in this.records) { if (item.billType == "支出" && item.category == category && item.timestamp >= startTime && item.timestamp < endTime) { total += item.amount } }
        total
    }

    func diningExpenseImproved(): Bool {
        let todayStart = startOfDay(currentTimestamp())
        let recentAmount = categoryAmountInRange("餐饮", todayStart - 2.0 * DAY_MS, todayStart + DAY_MS)
        let previousAmount = categoryAmountInRange("餐饮", todayStart - 5.0 * DAY_MS, todayStart - 2.0 * DAY_MS)
        previousAmount > 0.0 && recentAmount <= previousAmount * 0.9
    }

    func reportAdvice(): String {
        if (this.reportType == "收入") {
            if (incomeTotal() <= 0.0) { return "本月还没有收入记录，可以先补录工资、兼职或理财收益。" }
            return "当前结余率约${Int64(savingRate())}%，建议把固定储蓄单独记为目标。"
        }
        let top = topCategoryStat("支出")
        if (expenseTotal() <= 0.0) { return "本月还没有支出记录，开始记第一笔后这里会生成可执行建议。" }
        if (budgetRate() >= 0.85) { return "预算已使用${Int64(budgetRate() * 100.0)}%，建议优先压缩${top.name}类支出。" }
        return "${top.name}占支出${Int64(top.rate)}%，本月预算还剩¥${money(budgetLeft())}，节奏还算健康。"
    }

    func saveRecord() {
        let amount = tryParseFloat(this.amountText)
        if (amount <= 0.0) { this.formMessage = "请输入大于0的金额"; return }
        let timestamp = parseDateInput(this.recordDateText)
        if (timestamp < 0.0) { this.formMessage = "日期格式需为 YYYY-MM-DD"; return }
        let trimmedNote = this.noteText.trimAscii()
        let title = if (runeCount(trimmedNote) > 0) { trimmedNote } else { this.selectedCategory }
        if (this.editingId > 0) {
            var updated = ArrayList<BillRecordModel>()
            for (item in this.records) {
                if (item.id == this.editingId) { updated.add(BillRecordModel(item.id, this.recordType, this.selectedCategory, title, amount, timestamp)) }
                else { updated.add(item) }
            }
            this.records = sortRecordsByTime(updated.toArray())
        } else {
            let newRecord = BillRecordModel(this.nextRecordId, this.recordType, this.selectedCategory, title, amount, timestamp)
            var newList = ArrayList<BillRecordModel>()
            newList.add(newRecord)
            for (item in this.records) { newList.add(item) }
            this.records = sortRecordsByTime(newList.toArray())
            this.nextRecordId++
        }
        refreshStats(); clearForm()
    }

    func clearForm() {
        this.amountText = ""; this.noteText = ""; this.aiText = ""; this.formMessage = ""
        this.recordDateText = formatDateInput(currentTimestamp()); this.editingId = -1
        this.recordType = "支出"; this.selectedCategory = "餐饮"
    }

    func editRecord(record: BillRecordModel) {
        this.recordType = record.billType; this.selectedCategory = record.category
        this.amountText = "${record.amount}"; this.noteText = record.title
        this.recordDateText = formatDateInput(record.timestamp); this.formMessage = ""
        this.editingId = record.id; this.activeTab = 0
    }

    func deleteRecord(id: Int64) {
        var filtered = ArrayList<BillRecordModel>()
        for (item in this.records) { if (item.id != id) { filtered.add(item) } }
        this.records = filtered.toArray(); refreshStats()
    }

    func appendDigit(value: String) {
        if (value == "." && this.amountText.contains(".")) { return }
        if (runeCount(this.amountText) >= AMOUNT_MAX_LENGTH) { this.formMessage = "金额最多${AMOUNT_MAX_LENGTH}位"; return }
        this.amountText = this.amountText + value; this.formMessage = ""
    }

    func normalizeAmount(value: String): String {
        var result = StringBuilder(); var hasDot = false
        for (r in value.runes()) {
            if (r >= r'0' && r <= r'9') { result.append("${r}") }
            else if (r == r'.' && !hasDot) { result.append("."); hasDot = true }
            if (runeCount(result.toString()) >= AMOUNT_MAX_LENGTH) { this.formMessage = "金额最多${AMOUNT_MAX_LENGTH}位"; break }
        }
        result.toString()
    }

    func containsKeyword(text: String, keywords: Array<String>): Bool { for (kw in keywords) { if (text.contains(kw)) { return true } }; false }
    func inferTextType(text: String): String { for (rule in AI_TYPE_RULES) { if (containsKeyword(text, rule.keywords)) { return rule.aiType } }; this.recordType }
    func inferTextCategory(text: String, aiType: String): String {
        for (rule in AI_CATEGORY_RULES) { if (rule.aiType == aiType && containsKeyword(text, rule.keywords)) { return rule.category } }
        "其他"
    }

    func cleanRecognizedTitle(text: String, fallback: String): String {
        var title = removeDigits(text)
        let words = ["今天", "昨天", "刚刚", "本月", "这个月", "元", "块", "人民币", "赚了", "挣了", "收入", "收到", "收款", "入账", "转入", "报销", "退款", "花了", "消费", "支出", "支付", "付了", "买了"]
        for (w in words) { title = title.replace(w, "") }
        title = sanitizeText(title.trimAscii(), NOTE_MAX_LENGTH)
        if (runeCount(title) > 0) { title } else { fallback }
    }

    func parseSmartText() {
        let text = sanitizeText(this.aiText, AI_TEXT_MAX_LENGTH).trimAscii()
        if (runeCount(text) == 0) { this.formMessage = "请输入要识别的账单内容"; return }
        let amountStr = extractFirstNumber(text)
        if (amountStr.size > 0) { this.amountText = amountStr }
        let nextType = inferTextType(text)
        let nextCategory = inferTextCategory(text, nextType)
        this.recordType = nextType; this.selectedCategory = nextCategory
        this.noteText = cleanRecognizedTitle(text, nextCategory)
        this.formMessage = "已按规则识别为${nextType} · ${nextCategory}"
    }

    // ===== @Builder 组件 =====

    @Builder
    func StatCard(label: String, value: String, colorStr: String) {
        Column(space: 3) {
            Text(label).fontSize(10).fontColor(Color(0xFFEAF2F5))
            Text(value).fontSize(15).fontWeight(FontWeight.Bold).fontColor(Color.White).maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .padding(left: 12, right: 10, top: 11, bottom: 10)
        .height(52).borderRadius(16).backgroundColor(Color(0x20FFFFFF)).layoutWeight(1)
    }

    @Builder
    func SectionTitle(title: String, action: String) {
        Row() {
            Text(title).fontSize(16).fontWeight(FontWeight.Bold).fontColor(Color(0xFF1E252B))
            Blank()
            if (action.size > 0) { Text(action).fontSize(12).fontColor(colorFromHex(this.currentTheme().primary)) }
        }
        .width(100.percent).margin(top: 14, bottom: 8)
    }

    @Builder
    func Segment(label: String, value: String) {
        Text(label)
            .fontSize(14)
            .fontWeight(if (this.recordType == value) { FontWeight.Bold } else { FontWeight.Regular })
            .fontColor(if (this.recordType == value) { Color.White } else { Color(0xFF56616B) })
            .textAlign(TextAlign.Center)
            .padding(top: 7, bottom: 7).borderRadius(16)
            .backgroundColor(if (this.recordType == value) { colorFromHex(this.currentTheme().primary) } else { Color(0xFFEEF1F2) })
            .layoutWeight(1)
            .onClick({ evt => this.recordType = value; this.selectedCategory = if (value == "支出") { "餐饮" } else { "工资" } })
    }

    @Builder
    func CategoryGrid() {
        Grid() {
            ForEach(this.currentCategories(),
                itemGeneratorFunc: { item: CategoryMeta, idx: Int64 =>
                    GridItem() {
                        Column(space: 7) {
                            Text(firstRune(item.name))
                                .fontSize(13).fontWeight(FontWeight.Bold)
                                .fontColor(if (this.selectedCategory == item.name) { Color.White } else { colorFromHex(item.color) })
                                .textAlign(TextAlign.Center).width(32).height(32).borderRadius(16)
                                .backgroundColor(if (this.selectedCategory == item.name) { colorFromHex(item.color) } else { Color(0xFFF4F6F6) })
                            Text(item.name).fontSize(11).fontColor(Color(0xFF4A545D))
                        }
                        .width(100.percent)
                        .onClick({ evt => this.selectedCategory = item.name })
                    }
                },
                keyGeneratorFunc: { item: CategoryMeta, idx: Int64 => item.name }
            )
        }
        .columnsTemplate("1fr 1fr 1fr 1fr 1fr").rowsGap(10).columnsGap(6)
        .height(if (this.recordType == "支出") { 126 } else { 58 })
    }

    @Builder
    func RecordRow(item: BillRecordModel) {
        Row(space: 10) {
            Text(firstRune(item.category))
                .fontSize(14).fontWeight(FontWeight.Bold).fontColor(Color.White)
                .textAlign(TextAlign.Center).width(36).height(36).borderRadius(18)
                .backgroundColor(colorFromHex(this.categoryColor(item.category)))
            Column(space: 4) {
                Text(item.title).fontSize(14).fontWeight(FontWeight.Medium).fontColor(Color(0xFF1F272D)).maxLines(1)
                Text("${item.category} · ${formatRecordTime(item.timestamp)}").fontSize(12).fontColor(Color(0xFF7A838C))
            }
            .alignItems(HorizontalAlign.Start).layoutWeight(1)
            Text("${if (item.billType == "支出") { "-" } else { "+" }}${money(item.amount)}")
                .fontSize(15).fontWeight(FontWeight.Bold).fontColor(if (item.billType == "支出") { Color(0xFFD46D62) } else { Color(0xFF4E956C) })
            Button("编辑").fontSize(12).fontColor(colorFromHex(this.currentTheme().primary))
                .height(30).padding(left: 8, right: 8).borderRadius(10).backgroundColor(colorFromHex(this.currentTheme().soft))
                .onClick({ evt => editRecord(item) })
            Button("删").fontSize(12).fontColor(Color(0xFFD46D62))
                .height(30).padding(left: 8, right: 8).borderRadius(10).backgroundColor(Color(0xFFF8E7E5))
                .onClick({ evt => deleteRecord(item.id) })
        }
        .width(100.percent).padding(top: 10, bottom: 10).border(width: 1, color: Color(0xFFEEF0F1))
    }

    @Builder
    func ReportTypeButton(label: String) {
        Text(label)
            .fontSize(13)
            .fontWeight(if (this.reportType == label) { FontWeight.Bold } else { FontWeight.Regular })
            .fontColor(if (this.reportType == label) { Color.White } else { Color(0xFF56616B) })
            .textAlign(TextAlign.Center).height(32).padding(left: 18, right: 18).borderRadius(16)
            .backgroundColor(if (this.reportType == label) { colorFromHex(reportPrimaryColor()) } else { Color(0xFFEEF1F2) })
            .onClick({ evt => this.reportType = label })
    }

    @Builder
    func ReportMetricCard(label: String, value: String, hint: String, colorStr: String) {
        Column(space: 5) {
            Text(label).fontSize(11).fontColor(Color(0xFF7A838C))
            Text(value).fontSize(18).fontWeight(FontWeight.Bold).fontColor(colorFromHex(colorStr)).maxLines(1)
            Text(hint).fontSize(10).fontColor(Color(0xFF8A929A)).maxLines(1)
        }
        .alignItems(HorizontalAlign.Start).padding(12).height(82).borderRadius(16)
        .backgroundColor(Color(0xFFF7F9F9)).layoutWeight(1)
    }

    @Builder
    func ChallengeCard(title: String, desc: String, unlocked: Bool) {
        Column(space: 8) {
            Text(if (unlocked) { "已解锁" } else { "挑战中" })
                .fontSize(12).fontColor(if (unlocked) { Color(0xFF4E956C) } else { Color(0xFF8A8F98) })
                .padding(left: 10, right: 10, top: 5, bottom: 5).borderRadius(12)
                .backgroundColor(if (unlocked) { Color(0xFFE7F2EE) } else { Color(0xFFEEF1F2) })
            Text(title).fontSize(16).fontWeight(FontWeight.Bold).fontColor(Color(0xFF1E252B))
            Text(desc).fontSize(12).fontColor(Color(0xFF687078)).textAlign(TextAlign.Center)
        }
        .justifyContent(FlexAlign.Center).height(122).layoutWeight(1).padding(12).borderRadius(22).backgroundColor(Color.White)
    }

    @Builder
    func SettingRow(title: String, value: String) {
        Row() {
            Text(title).fontSize(14).fontColor(Color(0xFF2C343B))
            Blank()
            Text(value).fontSize(12).fontColor(Color(0xFF7A838C))
        }
        .width(100.percent).padding(top: 14, bottom: 14).border(width: 1, color: Color(0xFFEEF0F1))
    }

    @Builder
    func TabItem(title: String, index: Int64) {
        Column(space: 4) {
            Text(title)
                .fontSize(12)
                .fontWeight(if (this.activeTab == index) { FontWeight.Bold } else { FontWeight.Regular })
                .fontColor(if (this.activeTab == index) { colorFromHex(this.currentTheme().primary) } else { Color(0xFF7A838C) })
            Column().width(16).height(3).borderRadius(2)
                .backgroundColor(if (this.activeTab == index) { colorFromHex(this.currentTheme().primary) } else { Color.Transparent })
        }
        .height(50).justifyContent(FlexAlign.Center).layoutWeight(1)
        .onClick({ evt => this.activeTab = index })
    }

    // ===== 页面 Builder =====

    @Builder
    func HomePage() {
        Scroll() {
            Column() {
                Column(space: 14) {
                    Row() {
                        Column(space: 6) {
                            Text("简账").fontSize(21).fontWeight(FontWeight.Bold).fontColor(Color.White)
                            Text("让每一笔钱都清清楚楚").fontSize(11).fontColor(Color(0xFFEAF2F5))
                        }
                        .alignItems(HorizontalAlign.Start)
                        Blank()
                        Text(THEMES[this.themeIndex].name).fontSize(11).fontColor(Color.White)
                            .padding(left: 12, right: 12, top: 6, bottom: 6).borderRadius(16).backgroundColor(Color(0x26FFFFFF))
                    }
                    .width(100.percent)
                    Row(space: 10) {
                        StatCard("本月支出", "¥${money(expenseTotal())}", "#D46D62")
                        StatCard("本月收入", "¥${money(incomeTotal())}", "#4E956C")
                        StatCard("结余", "¥${money(balance())}", "#2E596F")
                    }
                }
                .width(100.percent).padding(left: 16, right: 16, top: 16, bottom: 16).borderRadius(22)
                .linearGradient(angle: 135.0, colors: [(colorFromHex(this.currentTheme().primary), 0.0), (Color(0xFF7E9C9A), 1.0)])

                SectionTitle(if (this.editingId > 0) { "编辑账单" } else { "快捷记账" }, "文本识别")
                Column(space: 10) {
                    TextInput(placeholder: "试试：今天赚了500 / 午饭花了35块", text: this.aiText)
                        .height(36).fontSize(12).borderRadius(16).backgroundColor(Color(0xFFF5F7F7))
                        .onChange({ value => this.aiText = sanitizeText(value, AI_TEXT_MAX_LENGTH) })
                    Row(space: 10) {
                        Button("识别").fontSize(12).fontColor(Color.White).height(34).borderRadius(16)
                            .backgroundColor(colorFromHex(this.currentTheme().primary)).layoutWeight(1)
                            .onClick({ evt => parseSmartText() })
                        Button(if (this.editingId > 0) { "取消编辑" } else { "重置" })
                            .fontSize(12).fontColor(Color(0xFF56616B)).height(34).borderRadius(16)
                            .backgroundColor(Color(0xFFEEF1F2)).layoutWeight(1)
                            .onClick({ evt => clearForm() })
                    }
                    Row(space: 8) { Segment("支出", "支出"); Segment("收入", "收入") }
                    Row() {
                        Text("¥").fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color(0xFF56616B))
                        TextInput(placeholder: "0", text: this.amountText)
                            .fontSize(26).fontWeight(FontWeight.Bold).fontColor(Color(0xFF1E252B))
                            .placeholderColor(Color(0xFF1E252B)).backgroundColor(Color.Transparent).padding(left: 4, right: 4)
                            .onChange({ value => this.amountText = normalizeAmount(value) }).layoutWeight(1)
                    }
                    .width(100.percent).padding(left: 12, right: 12, top: 8, bottom: 8).borderRadius(18).backgroundColor(Color(0xFFF7F9F9))
                    CategoryGrid()
                    Row() {
                        Text(this.recordDateText).fontSize(14).fontWeight(FontWeight.Medium).fontColor(Color(0xFF1E252B))
                        Blank()
                        Text("选择日期").fontSize(12).fontColor(colorFromHex(this.currentTheme().primary))
                    }
                    .height(40).width(100.percent).padding(left: 12, right: 12).borderRadius(16).backgroundColor(Color(0xFFF5F7F7))
                    TextInput(placeholder: "备注可选，留空会使用分类名", text: this.noteText)
                        .height(36).fontSize(12).borderRadius(16).backgroundColor(Color(0xFFF5F7F7))
                        .onChange({ value => this.noteText = sanitizeText(value, NOTE_MAX_LENGTH) })
                    if (this.formMessage.size > 0) {
                        Text(this.formMessage).fontSize(12)
                            .fontColor(if (this.formMessage.contains("请输入") || this.formMessage.contains("格式")) { Color(0xFFD46D62) } else { Color(0xFF687078) })
                            .width(100.percent)
                    }
                    Row(space: 10) {
                        Button("清空").fontSize(12).fontColor(Color(0xFF56616B)).height(38).borderRadius(16)
                            .backgroundColor(Color(0xFFEEF1F2)).layoutWeight(1)
                            .onClick({ evt => this.amountText = ""; this.formMessage = "" })
                        Button(if (this.editingId > 0) { "保存修改" } else { "完成记账" })
                            .fontSize(13).fontWeight(FontWeight.Bold).fontColor(Color.White).height(38).borderRadius(16)
                            .backgroundColor(colorFromHex(this.currentTheme().primary)).layoutWeight(2)
                            .onClick({ evt => saveRecord() })
                    }
                }
                .width(100.percent).padding(14).borderRadius(22).backgroundColor(Color.White)
                .shadow(radius: 14.0, color: Color(0x0F4F5B61), offsetX: 0.0, offsetY: 6.0)

                SectionTitle("最近账单", "${this.records.size}笔")
                Column() {
                    ForEach(this.records,
                        itemGeneratorFunc: { item: BillRecordModel, idx: Int64 => RecordRow(item) },
                        keyGeneratorFunc: { item: BillRecordModel, idx: Int64 => "${item.id}" }
                    )
                }
                .width(100.percent).padding(left: 14, right: 14).borderRadius(22).backgroundColor(Color.White)
            }
            .width(100.percent).padding(left: 14, right: 14, top: 12, bottom: 90)
        }
        .width(100.percent).height(100.percent)
    }

    @Builder
    func ReportsPage() {
        Scroll() {
            Column() {
                SectionTitle("统计报表", "实时")
                Row(space: 10) { ReportTypeButton("支出"); ReportTypeButton("收入"); Blank() }
                    .width(100.percent).margin(bottom: 12)
                Row(space: 10) {
                    ReportMetricCard("${this.reportType}总额", "¥${money(totalByType(this.reportType))}", "${countByType(this.reportType)}笔记录", reportPrimaryColor())
                    ReportMetricCard("单笔均值", "¥${money(averageByType(this.reportType))}", "用于判断日常强度", this.currentTheme().primary)
                }
                .width(100.percent).margin(bottom: 12)
                Row(space: 10) {
                    ReportMetricCard("本月结余", "¥${money(balance())}", "结余率${Int64(savingRate())}%", if (balance() >= 0.0) { "#4E956C" } else { "#D46D62" })
                    ReportMetricCard("预算剩余", "¥${money(budgetLeft())}", "已用${Int64(budgetRate() * 100.0)}%", if (budgetRate() >= 0.85) { "#D46D62" } else { this.currentTheme().primary })
                }
                .width(100.percent)
                SectionTitle("趋势", "")
                Column(space: 12) {
                    Row() {
                        Column(space: 4) {
                            Text("${this.reportType}趋势").fontSize(17).fontWeight(FontWeight.Bold).fontColor(Color(0xFF1E252B))
                            Text("按账单时间自动汇总").fontSize(12).fontColor(Color(0xFF7A838C))
                        }
                        .alignItems(HorizontalAlign.Start)
                        Blank()
                        Text("¥${money(totalByType(this.reportType))}").fontSize(17).fontWeight(FontWeight.Bold).fontColor(colorFromHex(reportPrimaryColor()))
                    }
                    Row(space: 8) {
                        ForEach(trendPoints(this.reportType),
                            itemGeneratorFunc: { point: TrendPoint, idx: Int64 =>
                                Column(space: 7) {
                                    Text(if (point.amount > 0.0) { money(point.amount) } else { "-" }).fontSize(9).fontColor(Color(0xFF7A838C)).maxLines(1)
                                    Column() {
                                        Blank()
                                        Column().height(trendBarHeight(point.amount, this.reportType)).width(100.percent).borderRadius(8)
                                            .backgroundColor(if (point.amount > 0.0) { colorFromHex(reportPrimaryColor()) } else { Color(0xFFE8ECEE) })
                                    }
                                    .height(104).width(100.percent)
                                    Text(point.label).fontSize(10).fontColor(if (point.count > 0) { Color(0xFF2C343B) } else { Color(0xFF9AA1A8) }).maxLines(1)
                                }
                                .layoutWeight(1)
                            },
                            keyGeneratorFunc: { point: TrendPoint, idx: Int64 => trendKey(point) }
                        )
                    }
                }
                .width(100.percent).padding(16).borderRadius(22).backgroundColor(Color.White)
                .shadow(radius: 12.0, color: Color(0x0C4F5B61), offsetX: 0.0, offsetY: 5.0)

                SectionTitle("分类排行", "${categoryStats(this.reportType).size}类")
                Column(space: 12) {
                    if (categoryStats(this.reportType).size == 0) {
                        Text("暂无${this.reportType}分类数据").fontSize(13).fontColor(Color(0xFF7A838C))
                            .width(100.percent).textAlign(TextAlign.Center).padding(top: 18, bottom: 18)
                    } else {
                        ForEach(categoryStats(this.reportType),
                            itemGeneratorFunc: { item: CategoryStat, idx: Int64 =>
                                Column(space: 8) {
                                    Row(space: 10) {
                                        Text(firstRune(item.name)).fontSize(12).fontWeight(FontWeight.Bold).fontColor(Color.White)
                                            .textAlign(TextAlign.Center).width(28).height(28).borderRadius(14).backgroundColor(colorFromHex(item.color))
                                        Column(space: 3) {
                                            Row() {
                                                Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor(Color(0xFF2C343B))
                                                Blank()
                                                Text("${Int64(item.rate)}%").fontSize(12).fontColor(Color(0xFF7A838C))
                                            }
                                            Text("${item.count}笔 · ¥${money(item.total)}").fontSize(11).fontColor(Color(0xFF8A929A))
                                        }
                                        .alignItems(HorizontalAlign.Start).layoutWeight(1)
                                    }
                                    Row() {
                                        Row().width(item.rate.percent).height(100.percent).backgroundColor(colorFromHex(item.color))
                                    }
                                    .width(100.percent).height(7).backgroundColor(Color(0xFFEDF0F1)).borderRadius(4)
                                }
                            },
                            keyGeneratorFunc: { item: CategoryStat, idx: Int64 => categoryRankKey(item) }
                        )
                    }
                }
                .width(100.percent).padding(16).borderRadius(22).backgroundColor(Color.White)

                SectionTitle("洞察", "")
                Column(space: 12) {
                    Row(space: 10) {
                        Text("建议").fontSize(12).fontWeight(FontWeight.Bold).fontColor(Color.White)
                            .textAlign(TextAlign.Center).width(42).height(28).borderRadius(14).backgroundColor(colorFromHex(this.currentTheme().primary))
                        Text(reportAdvice()).fontSize(14).fontColor(Color(0xFF2C343B)).layoutWeight(1)
                    }
                    Row(space: 10) {
                        ReportMetricCard("最高分类", topCategoryStat(this.reportType).name, "¥${money(topCategoryStat(this.reportType).total)}", topCategoryStat(this.reportType).color)
                        ReportMetricCard("最大单笔", "¥${money(largestRecordAmount(this.reportType))}", largestRecordTitle(this.reportType), reportPrimaryColor())
                    }
                }
                .width(100.percent).padding(16).borderRadius(22).backgroundColor(colorFromHex(this.currentTheme().soft))
            }
            .width(100.percent).padding(left: 14, right: 14, top: 12, bottom: 90)
        }
    }

    @Builder
    func BudgetPage() {
        Scroll() {
            Column() {
                SectionTitle("预算中心", "")
                Column(space: 18) {
                    Text("月度预算").fontSize(16).fontWeight(FontWeight.Bold).width(100.percent)
                    Row() {
                        Text("¥${money(this.monthlyBudget)}").fontSize(30).fontWeight(FontWeight.Bold).fontColor(Color(0xFF1E252B))
                        Blank()
                        Text("已用${Int64(budgetRate() * 100.0)}%").fontSize(13)
                            .fontColor(if (budgetRate() > 0.85) { Color(0xFFD46D62) } else { colorFromHex(this.currentTheme().primary) })
                            .padding(left: 12, right: 12, top: 7, bottom: 7).borderRadius(16)
                            .backgroundColor(if (budgetRate() > 0.85) { Color(0xFFF8E7E5) } else { colorFromHex(this.currentTheme().soft) })
                    }
                    Row() {
                        Row().width((budgetRate() * 100.0).percent).height(100.percent).backgroundColor(if (budgetRate() > 0.85) { Color(0xFFD46D62) } else { colorFromHex(this.currentTheme().primary) })
                    }
                    .width(100.percent).height(12).backgroundColor(Color(0xFFEDF0F1)).borderRadius(6)
                    Row(space: 10) {
                        Button("-100").height(40).borderRadius(12).backgroundColor(Color(0xFFEEF1F2)).fontColor(Color(0xFF56616B)).layoutWeight(1)
                            .onClick({ evt => this.monthlyBudget = if (this.monthlyBudget - 100.0 >= 500.0) { this.monthlyBudget - 100.0 } else { 500.0 } })
                        Button("+100").height(40).borderRadius(12).backgroundColor(colorFromHex(this.currentTheme().primary)).fontColor(Color.White).layoutWeight(1)
                            .onClick({ evt => this.monthlyBudget = this.monthlyBudget + 100.0 })
                    }
                }
                .width(100.percent).padding(18).borderRadius(22).backgroundColor(Color.White)
                .shadow(radius: 12.0, color: Color(0x0C4F5B61), offsetX: 0.0, offsetY: 5.0)

                SectionTitle("挑战赛", "")
                Row(space: 12) {
                    ChallengeCard("克制新星", "预算使用低于80%", budgetRate() < 0.8)
                    ChallengeCard("连续记账", "已记录${recordedDayCount()}天", recordedDayCount() >= 7)
                }
                Row(space: 12) {
                    ChallengeCard("少点外卖", "近3天餐饮下降10%", diningExpenseImproved())
                    ChallengeCard("结余守护", "保持正结余", balance() > 0.0)
                }
                .margin(top: 12)
            }
            .width(100.percent).padding(left: 14, right: 14, top: 12, bottom: 90)
        }
    }

    @Builder
    func ProfilePage() {
        Scroll() {
            Column() {
                SectionTitle("个人中心", "")
                Column(space: 12) {
                    Text("简账默认账本").fontSize(18).fontWeight(FontWeight.Bold).fontColor(Color(0xFF1E252B)).width(100.percent)
                    Text("本地优先保存，云备份需授权后开启。").fontSize(13).fontColor(Color(0xFF687078)).width(100.percent)
                }
                .alignItems(HorizontalAlign.Start).width(100.percent).padding(18).borderRadius(22).backgroundColor(Color.White)

                SectionTitle("动态主题", "")
                Column(space: 10) {
                    ForEach(THEMES,
                        itemGeneratorFunc: { item: ThemeMeta, idx: Int64 =>
                            Row(space: 12) {
                                Column().width(28).height(28).borderRadius(14).backgroundColor(colorFromHex(item.primary))
                                Text(item.name).fontSize(15)
                                    .fontWeight(if (this.themeIndex == idx) { FontWeight.Bold } else { FontWeight.Regular })
                                    .fontColor(Color(0xFF2C343B)).layoutWeight(1)
                                Text(if (this.themeIndex == idx) { "使用中" } else { "切换" }).fontSize(13)
                                    .fontColor(if (this.themeIndex == idx) { Color(0xFF4E956C) } else { colorFromHex(this.currentTheme().primary) })
                            }
                            .padding(14).borderRadius(18)
                            .backgroundColor(if (this.themeIndex == idx) { colorFromHex(item.soft) } else { Color.White })
                            .onClick({ evt => this.themeIndex = idx })
                        },
                        keyGeneratorFunc: { item: ThemeMeta, idx: Int64 => item.name }
                    )
                }

                SectionTitle("隐私与备份", "")
                Column() {
                    SettingRow("数据库加密", "已开启本地加密")
                    SettingRow("云备份", "待授权")
                    SettingRow("导出数据", "CSV / PDF")
                    SettingRow("广告SDK", "未接入")
                }
                .width(100.percent).padding(left: 16, right: 16).borderRadius(22).backgroundColor(Color.White)
            }
            .width(100.percent).padding(left: 14, right: 14, top: 12, bottom: 90)
        }
    }

    // ===== 主 build =====
    func build() {
        Stack(alignContent: Alignment.Bottom) {
            Column() {
                if (this.activeTab == 0) { HomePage() }
                else if (this.activeTab == 1) { ReportsPage() }
                else if (this.activeTab == 2) { BudgetPage() }
                else { ProfilePage() }
            }
            .width(100.percent).height(100.percent).backgroundColor(colorFromHex(this.currentTheme().surface))

            Row() {
                TabItem("记账", 0); TabItem("统计", 1); TabItem("预算", 2); TabItem("我的", 3)
            }
            .width(88.percent).height(54).margin(bottom: 10).padding(left: 8, right: 8).borderRadius(20)
            .backgroundColor(Color.White).shadow(radius: 16.0, color: Color(0x1A000000), offsetX: 0.0, offsetY: 7.0)
        }
        .width(100.percent).height(100.percent)
    }
}
