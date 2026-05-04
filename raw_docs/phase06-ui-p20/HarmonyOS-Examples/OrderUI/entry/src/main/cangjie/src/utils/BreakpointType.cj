/**
 * Created on 2024/8/24
 */
package ohos_app_cangjie_entry.utils
import ohos_app_cangjie_entry.constants.BreakpointConstants
public class BreakpointType<T> {
    private let sm: T
    private let md: T
    private let lg: T

    public init(sm: T, md: T, lg: T) {
        this.sm = sm
        this.md = md
        this.lg = lg
    }

    public func getValue(currentBreakpoint: String): T {
        if (currentBreakpoint == BreakpointConstants.BREAKPOINT_MD) {
            return this.md
        }else if (currentBreakpoint == BreakpointConstants.BREAKPOINT_LG) {
            return this.lg
        } else {
           return this.sm
        }
    }
}
