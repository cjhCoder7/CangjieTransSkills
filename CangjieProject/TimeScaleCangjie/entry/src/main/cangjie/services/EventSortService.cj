package ohos_app_cangjie_entry.services

import ohos_app_cangjie_entry.model.*
import std.collection.*

public class EventSortService {
    public static func reorderInPlace(eventList: ArrayList<EventItem>, fromIndex: Int64, toIndex: Int64): Unit {
        if (fromIndex < 0 || fromIndex >= eventList.size || toIndex < 0 || toIndex >= eventList.size || fromIndex == toIndex) {
            return
        }

        if (let Some(movedItem) <- eventList.get(fromIndex)) {
            eventList.remove(at: fromIndex)
            eventList.add(movedItem, at: toIndex)
        }
        normalizeSortIndexes(eventList)
    }

    public static func normalizeSortIndexes(eventList: ArrayList<EventItem>): Unit {
        for (i in 0..eventList.size) {
            if (let Some(event) <- eventList.get(i)) {
                event.sortIndex = Int64(i)
            }
        }
    }

    public static func canDragSort(keyword: String, totalCount: Int64): Bool {
        keyword.trimAscii().size == 0 && totalCount > 1
    }
}
