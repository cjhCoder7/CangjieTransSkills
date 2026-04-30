package ohos_app_cangjie_entry.services

import ohos_app_cangjie_entry.model.*
import std.collection.*
import std.time.*

public class CardEventData {
    public var title: String = ""
    public var countdownText: String = ""
    public var color: UInt32 = 0xFF8C939F
    public var dateText: String = ""
    public var status: String = "future"

    public init() {}
}

public class CardDataPayload {
    public var firstTitle: String = "赶快去应用里添加吧！"
    public var event1Title: String = ""
    public var event1CountdownText: String = ""
    public var event1Color: UInt32 = 0xFF8C939F
    public var event1DateText: String = ""
    public var event1Status: String = "future"
    public var event2Title: String = ""
    public var event2CountdownText: String = ""
    public var event2Color: UInt32 = 0xFF8C939F
    public var event2DateText: String = ""
    public var event2Status: String = "future"
    public var event3Title: String = ""
    public var event3CountdownText: String = ""
    public var event3Color: UInt32 = 0xFF8C939F
    public var event3DateText: String = ""
    public var event3Status: String = "future"
    public var eventCount: Int64 = 0
    public var dimension: Int64 = 2
    public var renderVersion: Int64 = 0

    public init() {}
}

public class CardDataBuilder {
    public static func build(events: ArrayList<EventItem>, dimension: Int64): CardDataPayload {
        let sortedEvents = ArrayList<EventItem>()
        for (e in events) { sortedEvents.add(e) }
        sortedEvents.sortBy(comparator: { a, b => if (a.sortIndex < b.sortIndex) { Ordering.LT } else if (a.sortIndex > b.sortIndex) { Ordering.GT } else { Ordering.EQ } })

        let top3 = ArrayList<EventItem>()
        var count = 0
        for (e in sortedEvents) {
            if (count >= 3) { break }
            top3.add(e)
            count++
        }

        let event1 = if (let Some(e) <- top3.get(0)) { buildEventData(e) } else { emptyEvent() }
        let event2 = if (let Some(e) <- top3.get(1)) { buildEventData(e) } else { emptyEvent() }
        let event3 = if (let Some(e) <- top3.get(2)) { buildEventData(e) } else { emptyEvent() }

        let payload = CardDataPayload()
        payload.firstTitle = if (top3.size > 0) { event1.title } else { "赶快去应用里添加吧！" }
        payload.event1Title = event1.title
        payload.event1CountdownText = event1.countdownText
        payload.event1Color = event1.color
        payload.event1DateText = event1.dateText
        payload.event1Status = event1.status
        payload.event2Title = event2.title
        payload.event2CountdownText = event2.countdownText
        payload.event2Color = event2.color
        payload.event2DateText = event2.dateText
        payload.event2Status = event2.status
        payload.event3Title = event3.title
        payload.event3CountdownText = event3.countdownText
        payload.event3Color = event3.color
        payload.event3DateText = event3.dateText
        payload.event3Status = event3.status
        payload.eventCount = Int64(top3.size)
        payload.dimension = dimension
        payload.renderVersion = DateTime.now().toUnixTimeStamp().toMilliseconds()
        payload
    }

    private static func buildEventData(item: EventItem): CardEventData {
        let statusInfo = EventOccurrenceService.resolveStatusInfo(item)
        let data = CardEventData()
        data.title = item.title
        data.countdownText = statusInfo.text
        data.color = item.themeColor ?? statusInfo.color
        data.dateText = EventOccurrenceService.formatEventDateText(item)
        data.status = statusInfo.status
        data
    }

    private static func emptyEvent(): CardEventData {
        CardEventData()
    }
}
