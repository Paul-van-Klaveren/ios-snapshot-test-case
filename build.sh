#!/bin/sh

set -eu

function ci_lib() {
    NAME=$1
    xcodebuild -project FBSnapshotTestCase.xcodeproj \
               -scheme "FBSnapshotTestCase iOS" \
               -destination "platform=iOS Simulator,name=${NAME}" \
               -sdk iphonesimulator \
               build-for-testing
    xcodebuild -project FBSnapshotTestCase.xcodeproj \
               -scheme "FBSnapshotTestCase iOS" \
               -destination "platform=iOS Simulator,name=${NAME}" \
               -sdk iphonesimulator \
               test-without-building
}

function ci_demo() {
    NAME=$1
    pushd FBSnapshotTestCaseDemo
    pod install
    xcodebuild -workspace FBSnapshotTestCaseDemo.xcworkspace \
               -scheme FBSnapshotTestCaseDemo \
               -destination "platform=iOS Simulator,name=${NAME}" \
               build-for-testing
    xcodebuild -workspace FBSnapshotTestCaseDemo.xcworkspace \
               -scheme FBSnapshotTestCaseDemo \
               -destination "platform=iOS Simulator,name=${NAME}" \
               test-without-building
    popd
}

function ci_demo_preprocessor() {
    NAME=$1
    pushd FBSnapshotTestCaseDemo
    pod install
    xcodebuild -workspace FBSnapshotTestCaseDemo.xcworkspace \
               -scheme FBSnapshotTestCasePreprocessorDemo \
               -destination "platform=iOS Simulator,name=${NAME}" \
               build-for-testing
    xcodebuild -workspace FBSnapshotTestCaseDemo.xcworkspace \
               -scheme FBSnapshotTestCasePreprocessorDemo \
               -destination "platform=iOS Simulator,name=${NAME}" \
               test-without-building
    popd
}

function ci_carthage_demo() {
    NAME=$1
    pushd iOSSnapshotTestCaseCarthageDemo
    carthage bootstrap --no-use-binaries --use-xcframeworks # we're using --no-use-binaries because carthage's archive doesn't yet create xcframeworks, and we're using --use-xcframeworks because of Xcode 12
    xcodebuild -project iOSSnapshotTestCaseCarthageDemo.xcodeproj \
               -scheme iOSSnapshotTestCaseCarthageDemo \
               -destination "platform=iOS Simulator,name=${NAME}" \
               build-for-testing
    xcodebuild -project iOSSnapshotTestCaseCarthageDemo.xcodeproj \
               -scheme iOSSnapshotTestCaseCarthageDemo \
               -destination "platform=iOS Simulator,name=${NAME}" \
               test-without-building
    popd
}

function ci_swiftpm_demo() {
    NAME=$1
    pushd iOSSnapshotTestCaseSwiftPMDemo
    xcodebuild -project iOSSnapshotTestCaseSwiftPMDemo.xcodeproj \
               -scheme "iOSSnapshotTestCaseSwiftPMDemo (iOS)" \
               -destination "platform=iOS Simulator,name=${NAME}" \
               build-for-testing
    xcodebuild -project iOSSnapshotTestCaseSwiftPMDemo.xcodeproj \
               -scheme "iOSSnapshotTestCaseSwiftPMDemo (iOS)" \
               -destination "platform=iOS Simulator,name=${NAME}" \
               test-without-building
    popd
}

ci_lib "iPhone 8" && ci_demo "iPhone 8" && ci_demo_preprocessor "iPhone 8"
ci_lib "iPhone 11" && ci_demo "iPhone 11" && ci_demo_preprocessor "iPhone 11"
ci_carthage_demo "iPhone 8"
ci_carthage_demo "iPhone 11"
ci_swiftpm_demo "iPhone 8"
ci_swiftpm_demo "iPhone 11"
