package mail_importer.errorstrategy

import mail_importer.local.LocalMessage

public interface ErrorStrategy {
    func handleError(localMessage: LocalMessage, ex: Exception): ErrorStrategyResult
}
