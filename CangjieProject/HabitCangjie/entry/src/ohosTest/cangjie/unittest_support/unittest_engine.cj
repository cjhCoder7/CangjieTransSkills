package ohos_app_cangjie_entry_test.unittest_support

import std.fs.Path
import std.fs.Directory
import std.collection.filter
import std.fs.FileInfo
import std.collection.first
import std.fs.File
import std.collection.forEach
import std.convert.Parsable
import std.collection.any
import std.collection.HashMap
import std.collection.ArrayList
import std.unittest.common.Configuration
import std.unittest.TestClass
import std.unittest.TestSuite
import std.unittest.XmlReporter
import kit.AbilityKit.BundleManager
import kit.AbilityKit.BundleFlag
import kit.AbilityKit.Want
import kit.PerformanceAnalysisKit.Hilog
import kit.TestKit.AbilityDelegatorRegistry
import kit.TestKit.TestRunner
import std.env.setVariable

@When[coverage == "true"]
foreign func __gcov_dump(): Unit

@When[coverage == "true"]
public func gcov_dump(coveragePath: String): Unit {
    Hilog.info(0, "Cangjie-Test", "execute test with coverage")
    unsafe { __gcov_dump() }
    let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
    abilityDelegator.print("GENERATE_COVERAGE: ${coveragePath}")
}

@When[coverage == "false"]
public func gcov_dump(coveragePath: String): Unit {
    Hilog.info(0, "Cangjie-Test", "execute test without coverage")
}

public func registerTestSuite(testClassInstanceGenerator: () -> TestClass): Unit {
    OpenHarmonyTestRunner
        .testClassInstanceGenerators
        .add(testClassInstanceGenerator)
}

public class OpenHarmonyTestRunner <: TestRunner {
    public static let testSuiteMap = HashMap<String, TestSuite>()
    public static let testClassInstanceGenerators = ArrayList<() -> TestClass>()
    private static func getDetailedInfoOf(e: Exception): String {
        let sb = StringBuilder("exception: ${e.toString()}\n")
        e.getStackTrace() |>
            forEach {
            s => sb.append("         at ${s.declaringClass}.${s.methodName}(${s.fileName}:${s.lineNumber})\n")
        }
        sb.toString()
    }

    private func executeTestClass(testClassName: String): Unit {
        let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
        Hilog.info(0, "Cangjie-Test", "EXECUTE_CLASS_START: \"${testClassName}\"")
        abilityDelegator.print("EXECUTE_CLASS_START: \"${testClassName}\"")
        let testSuite = match (OpenHarmonyTestRunner
            .testSuiteMap
            .get(testClassName)) {
            case None => return
            case Some(testClassInstanceGenerator) => testClassInstanceGenerator
        }

        testSuite
            .runTests()
            .reportTo(XmlReporter(Path("/data/storage/el1/base")))

        let testReportXmlFileName = "test-default.${testClassName}.xml"
        match (Directory.readFrom("/data/storage/el1/base/tests") |>
            filter {fileInfo => fileInfo.name == testReportXmlFileName} |> first) {
            case None => Hilog.error(1, "Cangjie-Test", "${testReportXmlFileName} not found.")
            case Some(testReportXmlFileInfo) =>
                let testReportXmlFilePath = testReportXmlFileInfo.path
                let testReportXmlFileContent = File.readFrom(testReportXmlFilePath)
                let xmlReport = String.fromUtf8(testReportXmlFileContent)
                Hilog.info(0, "Cangjie-Test", "XML_REPORT_CONTENT_LENGTH: ${xmlReport.size}")
                Hilog.info(0, "Cangjie-Test", xmlReport)
                abilityDelegator.print("XML_REPORT_CONTENT_LENGTH: ${xmlReport.size}")
                abilityDelegator.print(xmlReport)
                Hilog.info(0, "Cangjie-Test", "EXECUTE_CLASS_END: \"${testClassName}\"")
                abilityDelegator.print("EXECUTE_CLASS_END: \"${testClassName}\"")
                reportTestReport("test-default.${testClassName}.xml")
        }
    }
    private func executeAllTestClasses(): Unit {
        for (testClassName in OpenHarmonyTestRunner
                .testSuiteMap
                .keys()) {
            executeTestClass(testClassName)
        }
    }
    private func executeTestCase(testClassName: String, testCaseName: String): Unit {
        let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
        abilityDelegator.print("EXECUTE_CLASS_START: \"${testClassName}\"")
        Hilog.info(0, "Cangjie-Test", "EXECUTE_METHOD_START: \"${testClassName}#${testCaseName}\"")
        let testSuite = match (OpenHarmonyTestRunner
            .testSuiteMap
            .get(testClassName)) {
            case None => return
            case Some(testClassInstanceGenerator) => testClassInstanceGenerator
        }
        let configuration = Configuration()
        configuration.setByName("filter", "${testClassName}.${testCaseName}")
        testSuite
            .runTests(configuration)
            .reportTo(XmlReporter(Path("/data/storage/el1/base")))

        let testReportXmlFileName = "test-default.${testClassName}.xml"
        match (Directory.readFrom("/data/storage/el1/base/tests") |>
            filter {fileInfo => fileInfo.name == testReportXmlFileName} |> first) {
            case None => Hilog.error(1, "Cangjie-Test", "${testReportXmlFileName} not found.")
            case Some(testReportXmlFileInfo) =>
                let testReportXmlFilePath = testReportXmlFileInfo.path
                let testReportXmlFileContent = File.readFrom(testReportXmlFilePath)
                let xmlReport = String.fromUtf8(testReportXmlFileContent)
                Hilog.info(0, "Cangjie-Test", "XML_REPORT_CONTENT_LENGTH: ${xmlReport.size}")
                Hilog.info(0, "Cangjie-Test", xmlReport)
                abilityDelegator.print("XML_REPORT_CONTENT_LENGTH: ${xmlReport.size}")
                abilityDelegator.print(xmlReport)
                Hilog.info(0, "Cangjie-Test", "EXECUTE_METHOD_END: \"${testClassName}#${testCaseName}\"")
                abilityDelegator.print("EXECUTE_CLASS_END: \"${testClassName}\"")
                reportTestReport("test-default.${testClassName}.xml")
        }
    }
    private func reportTestReport(testReportName: String): Unit {
        let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
        let abilityDelegatorArguments = AbilityDelegatorRegistry.getArguments()
        let bundleName = abilityDelegatorArguments.bundleName
        abilityDelegator.print("REPORT_TEST_RESULT: /data/app/el1/100/base/${bundleName}/tests/${testReportName}")
    }
    public override func onPrepare(): Unit {
        Hilog.info(0, "Cangjie-Test", "OpenHarmonyTestRunner onPrepare")
        for (testClassInstanceGenerator in OpenHarmonyTestRunner.testClassInstanceGenerators) {
            let testClassInstance = try {
                testClassInstanceGenerator()
            } catch (e: Exception) {
                Hilog.error(1, "Cangjie-Test", "exception occurred during testsuite generation:\n${getDetailedInfoOf(e)}")
                continue
            }
            let testSuite = testClassInstance.asTestSuite()
            let testSuiteName = testSuite.name
            Hilog.info(0, "Cangjie-Test", "Registering TestSuite ${testSuiteName}")
            OpenHarmonyTestRunner
                .testSuiteMap
                .add(testSuiteName, testSuite)
        }
    }
    public override func onRun(): Unit {
        Hilog.info(0, "Cangjie-Test", "OpenHarmonyTestRunner onRun")
        let abilityDelegatorArguments = AbilityDelegatorRegistry.getArguments()
        let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator()
        Hilog.info(0, "Cangjie-Test", "bundleName = ${abilityDelegatorArguments.bundleName}")
        Hilog.info(0, "Cangjie-Test", "abilityDelegatorArguments.testRunnerClassName = ${abilityDelegatorArguments.testRunnerClassName}")
        Hilog.info(0, "Cangjie-Test", "abilityDelegatorArguments.testCaseNames = ${abilityDelegatorArguments.testCaseNames}")
        Hilog.info(0, "Cangjie-Test", "abilityDelegatorArguments.parameters = ${abilityDelegatorArguments.parameters}")
        Hilog.info(0, "Cangjie-Test", "Started running tests.")
        abilityDelegator.print("OpenHarmonyTestRunner onRun")
        let parameters = abilityDelegatorArguments.parameters
        let bundleName = abilityDelegatorArguments.bundleName
        let bundleInfo = BundleManager.getBundleInfoForSelf(
            BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE | BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
        let moduleName = match (parameters.get("-m")) {
            case None =>
                abilityDelegator.finishTest("Module name was not specified.", -1)
                return
            case Some(moduleName) =>
                if (bundleInfo.hapModulesInfo |> any {hapModuleInfo => hapModuleInfo.name == moduleName}) {
                    moduleName
                } else {
                    abilityDelegator.finishTest(
                        "No module with name \"${moduleName}\" was found in bundle ${bundleName}.", -1)
                    return
                }
        }
        let abilityName = match (bundleInfo.hapModulesInfo |> filter {hapModuleInfo => hapModuleInfo.name == moduleName} |>
            first) {
            case None =>
                abilityDelegator.finishTest("No module with name \"${moduleName}\" was found in bundle ${bundleName}.",
                    -1)
                return
            case Some(hapModuleInfo) =>
                let mainElementName = hapModuleInfo.mainElementName
                Hilog.info(0, "Cangjie-Test", "mainElementName = ${mainElementName}")
                mainElementName
        }
        let want = Want(bundleName: bundleName, moduleName: moduleName, abilityName: abilityName)
        abilityDelegator.startAbility(want)
        let timeOut = match (parameters.get("-s timeout")) {
            case None => None<Int64>
            case Some(timeOutText) => match (Int64.tryParse(timeOutText)) {
                case None =>
                    abilityDelegator.finishTest("The parameter \"timeout\": ${timeOutText} is invalid", -1)
                    return
                case Some(timeOutValue) => timeOutValue
            }
        }
        spawn {
            try {
                match (parameters.get("-s class")) {
                    case None => executeAllTestClasses()
                    case Some(text) => text.split(",", removeEmpty: true) |>
                        forEach {
                        t: String =>
                        let pair = t.split("#", removeEmpty: true)
                        let testClassName = match (pair.get(0)) {
                            case None => return
                            case Some(text) => text.trimAscii()
                        }
                        match (pair.get(1)) {
                            case None => executeTestClass(testClassName)
                            case Some(testCaseName) => executeTestCase(testClassName, testCaseName)
                        }
                    }
                }
            } catch (e: Exception) {
                Hilog.error(1, "Cangjie-Test", "an exception occurred:\n${getDetailedInfoOf(e)}")
            }
            setVariable("GCOV_PREFIX", "/data/storage/el1/base/cov")
            gcov_dump("/data/app/el1/100/base/${bundleName}/cov/")

            abilityDelegator.finishTest("Test finished.", 0)
        }
    }
}

let _ = TestRunner.registerCreator("OpenHarmonyTestRunner") {OpenHarmonyTestRunner()}
