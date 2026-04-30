package ohos_app_cangjie_entry.services


public class CardRefreshService {
    public static func refreshAll(abilityContext: Object): Unit {
        CardManager.getInstance().updateAllForms(abilityContext)
    }
}
