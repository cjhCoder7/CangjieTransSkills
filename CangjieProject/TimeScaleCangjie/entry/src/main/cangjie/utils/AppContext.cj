package ohos_app_cangjie_entry.utils

import kit.AbilityKit.UIAbilityContext

public class AppContext {
    private static var abilityContext: ?UIAbilityContext = None

    public static func setup(context: UIAbilityContext): Unit {
        abilityContext = context
    }

    public static func get(): UIAbilityContext {
        if (let Some(ctx) <- abilityContext) {
            return ctx
        }
        throw Exception("AppContext not initialized")
    }
}
