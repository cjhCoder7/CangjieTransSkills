package mail_importer.errorstrategy

import mail_importer.local.LocalMessage

public class Fail <: ErrorStrategy {
    public func handleError(localMessage: LocalMessage, ex: Exception): ErrorStrategyResult {
        ErrorStrategyResult.STOP
    }
}
