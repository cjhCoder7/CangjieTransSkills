package ohos_app_cangjie_entry.services

public class NotificationNavigationState {
    private static var pendingEventId: ?Int64 = None

    public static func setPendingEventId(eventId: ?Int64): Unit {
        pendingEventId = eventId
    }

    public static func consumePendingEventId(): ?Int64 {
        let eventId = pendingEventId
        pendingEventId = None
        eventId
    }
}
