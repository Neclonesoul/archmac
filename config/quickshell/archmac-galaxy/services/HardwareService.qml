import QtQuick

QtObject {
    // Phase 1 intentionally exposes only known stable identity.
    // Live hardware discovery is added behind this service later.
    readonly property string profile: "apple/macbookpro9-2"
    readonly property string model: "MacBookPro9,2"
}
