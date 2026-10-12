import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.Services
import QtCore

PluginSettings {
    id: root
    pluginId: "dmsScreenshot"

    focus: true
    activeFocusOnTab: true

    readonly property real outerR: Theme.cornerRadius || 12
    readonly property real innerR: 4

    property string defaultPath: ""
    property bool stdout: false

    function loadValue(key, def) {
        if (typeof PluginService !== "undefined" && PluginService && PluginService.loadPluginData) {
            return PluginService.loadPluginData(root.pluginId, key, def);
        }
        return def;
    }

    function saveValue(key, val) {
        if (typeof PluginService !== "undefined" && PluginService && PluginService.savePluginData) {
            PluginService.savePluginData(root.pluginId, key, val);
            if (PluginService.setGlobalVar) {
                PluginService.setGlobalVar(root.pluginId, key, val);
            }
        }
    }

    Component.onCompleted: {
        root.stdout = root.loadValue("stdout", false) === true || root.loadValue("stdout", false) === "true";
    }

    Connections {
        target: PluginService
        ignoreUnknownSignals: true
        function onPluginDataChanged(pId) {
            if (pId === root.pluginId) {
                mainSettingsCol.loadValueInternal();
            }
        }
        function onGlobalVarChanged(pId, varName) {
            if (pId === root.pluginId) {
                mainSettingsCol.loadValueInternal();
            }
        }
    }

    Process {
        id: defaultPathDetector
        command: ["bash", "-c", "dir=$(xdg-user-dir PICTURES 2>/dev/null); if [ -n \"$dir\" ]; then echo \"${dir/#$HOME/~}\"; else echo \"~/Pictures\"; fi"]
        running: true
        stdout: SplitParser {
            onRead: function(data) {
                if (data.trim() !== "") {
                    root.defaultPath = data.trim();
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // REUSABLE COMPONENTS
    // -------------------------------------------------------------------------

    component SectionHeader: Row {
        property string title: ""
        property string iconName: ""

        spacing: Theme.spacingXS
        leftPadding: Theme.spacingM

        DankIcon {
            name: iconName
            size: 16
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: title
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.DemiBold
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    component SettingsToggleItem: Rectangle {
        id: toggleCard
        width: parent.width
        height: 56
        color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
        border.width: 1
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

        property string iconName: ""
        property string title: ""
        property string description: ""
        property string settingKey: ""
        property bool defaultValue: false

        property bool isFirst: false
        property bool isLast: false
        property bool isSingle: false

        property alias checked: toggle.checked
        signal toggled(bool checked)

        topLeftRadius: (isFirst || isSingle) ? root.outerR : root.innerR
        topRightRadius: (isFirst || isSingle) ? root.outerR : root.innerR
        bottomLeftRadius: (isLast || isSingle) ? root.outerR : root.innerR
        bottomRightRadius: (isLast || isSingle) ? root.outerR : root.innerR

        function loadValue() {
            if (root) {
                var loaded = root.loadValue(settingKey, defaultValue);
                checked = loaded === true || loaded === "true";
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingM
            anchors.rightMargin: Theme.spacingM
            spacing: Theme.spacingM

            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: toggle.checked ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15) : Qt.rgba(Theme.surfaceContainerHighest.r, Theme.surfaceContainerHighest.g, Theme.surfaceContainerHighest.b, 0.5)
                Layout.alignment: Qt.AlignVCenter
                Behavior on color { ColorAnimation { duration: 150 } }

                DankIcon {
                    name: toggleCard.iconName
                    size: 18
                    color: toggle.checked ? Theme.primary : Theme.surfaceVariantText
                    anchors.centerIn: parent
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Layout.alignment: Qt.AlignVCenter

                StyledText {
                    text: toggleCard.title
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }

                StyledText {
                    text: toggleCard.description
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
            }

            DankToggle {
                id: toggle
                Layout.alignment: Qt.AlignVCenter
                onToggled: {
                    root.saveValue(toggleCard.settingKey, checked);
                    toggleCard.toggled(checked);
                }
            }
        }
    }

    component PathFieldItem: Rectangle {
        id: pathCard
        width: parent.width
        height: pathCol.implicitHeight + Theme.spacingM * 2
        color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
        border.width: 1
        border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

        property string iconName: ""
        property string title: ""
        property string description: ""
        property string settingKey: ""
        property string defaultValue: ""
        property string placeholder: defaultValue

        property bool isFirst: false
        property bool isLast: false
        property bool isSingle: false

        topLeftRadius: (isFirst || isSingle) ? root.outerR : root.innerR
        topRightRadius: (isFirst || isSingle) ? root.outerR : root.innerR
        bottomLeftRadius: (isLast || isSingle) ? root.outerR : root.innerR
        bottomRightRadius: (isLast || isSingle) ? root.outerR : root.innerR

        function loadValue() {
            textField.loadValue();
        }

        Column {
            id: pathCol
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS

            RowLayout {
                width: parent.width
                spacing: Theme.spacingM

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                    Layout.alignment: Qt.AlignVCenter

                    DankIcon {
                        name: pathCard.iconName
                        size: 18
                        color: Theme.primary
                        anchors.centerIn: parent
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2
                    StyledText {
                        text: pathCard.title
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }
                    StyledText {
                        text: pathCard.description
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                }
            }

            DankTextField {
                id: textField
                width: parent.width
                placeholderText: pathCard.placeholder
                text: ""

                function loadValue() {
                    text = root.loadValue(pathCard.settingKey, pathCard.defaultValue);
                }

                onEditingFinished: {
                    root.saveValue(pathCard.settingKey, text);
                }
            }
        }
    }

    Column {
        id: mainSettingsCol
        width: parent.width
        spacing: Theme.spacingL

        function loadValueInternal() {
            function triggerLoad(item) {
                if (!item) return;
                if (item.loadValue) item.loadValue();
                if (item.children) {
                    for (var i = 0; i < item.children.length; i++) triggerLoad(item.children[i]);
                }
            }
            triggerLoad(mainSettingsCol);
        }

        Component.onCompleted: loadValueInternal()

        // ====================================================================
        // SECTION 1: CAPTURE SETTINGS
        // ====================================================================
        Column {
            width: parent.width
            spacing: Theme.spacingS

            SectionHeader {
                title: "Capture Settings"
                iconName: "camera"
            }

            Column {
                width: parent.width
                spacing: 2

                // 1. Screenshot Mode (Segmented Pill - 3x2 Grid)
                Rectangle {
                    width: parent.width
                    height: capCol1.implicitHeight + Theme.spacingM * 2
                    topLeftRadius: root.outerR; topRightRadius: root.outerR; bottomLeftRadius: root.innerR; bottomRightRadius: root.innerR
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1; border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    ColumnLayout {
                        id: capCol1
                        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingM; anchors.rightMargin: Theme.spacingM
                        spacing: Theme.spacingS

                        RowLayout {
                            Layout.fillWidth: true; spacing: Theme.spacingM
                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                Layout.alignment: Qt.AlignVCenter
                                DankIcon { name: "camera"; size: 18; color: Theme.primary; anchors.centerIn: parent }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                StyledText { text: "Screenshot Mode"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                                StyledText { text: "Choose default capture target"; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                            }
                        }

                        SegmentedSetting {
                            Layout.fillWidth: true
                            settingKey: "mode"
                            defaultValue: "interactive"
                            columns: 3
                            options: [
                                { title: "Interactive", value: "interactive", icon: "crop" },
                                { title: "Window", value: "window", icon: "dock_to_left" },
                                { title: "Scroll", value: "scroll", icon: "swipe_vertical" },
                                { title: "Focused", value: "full", icon: "fullscreen" },
                                { title: "All", value: "all", icon: "grid_view" },
                                { title: "Output", value: "output", icon: "desktop_windows" }
                            ]
                        }
                    }
                }

                // 2. Specific Output Name
                PathFieldItem {
                    iconName: "desktop_windows"
                    title: "Output Monitor Name"
                    description: "Target display name for 'Output' mode (e.g. DP-1, HDMI-A-1)"
                    settingKey: "outputName"
                    defaultValue: ""
                    placeholder: "DP-1"
                }

                // 3. Scroll Capture Cadence / Interval
                Rectangle {
                    width: parent.width
                    height: scrollCol.implicitHeight + Theme.spacingM * 2
                    topLeftRadius: root.innerR; topRightRadius: root.innerR; bottomLeftRadius: root.innerR; bottomRightRadius: root.innerR
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1; border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    ColumnLayout {
                        id: scrollCol
                        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingM; anchors.rightMargin: Theme.spacingM
                        spacing: Theme.spacingS

                        SliderSettingV2 {
                            Layout.fillWidth: true; settingKey: "scrollInterval"
                            label: "Scroll Interval (ms)"; description: "Frame capture interval for scrolling screenshot (30-1000 ms, default: 45)"
                            defaultValue: "45"; minVal: 30; maxVal: 500; isFloatBackend: false; showPercentage: false
                            iconName: "swipe_vertical"
                        }
                    }
                }

                // 4. Capture Delay
                Rectangle {
                    width: parent.width
                    height: capCol2.implicitHeight + Theme.spacingM * 2
                    topLeftRadius: root.innerR; topRightRadius: root.innerR; bottomLeftRadius: root.innerR; bottomRightRadius: root.innerR
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1; border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    ColumnLayout {
                        id: capCol2
                        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingM; anchors.rightMargin: Theme.spacingM
                        spacing: Theme.spacingS

                        RowLayout {
                            Layout.fillWidth: true; spacing: Theme.spacingM
                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                Layout.alignment: Qt.AlignVCenter
                                DankIcon { name: "schedule"; size: 18; color: Theme.primary; anchors.centerIn: parent }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                StyledText { text: "Capture Delay"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                                StyledText { text: "Wait before shutter fires (ignored in Interactive and Scroll modes)"; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                            }
                        }

                        SegmentedSetting {
                            Layout.fillWidth: true
                            settingKey: "delaySeconds"
                            defaultValue: "0"
                            options: [
                                { title: "Off", value: "0", icon: "timer_off" },
                                { title: "3s", value: "3", icon: "timer_3" },
                                { title: "5s", value: "5", icon: "timer_5" },
                                { title: "10s", value: "10", icon: "timer_10" }
                            ]
                        }
                    }
                }

                // 5. Show Pointer
                SettingsToggleItem {
                    iconName: "mouse"
                    title: "Show Pointer"
                    description: "Include mouse pointer in the screenshot"
                    settingKey: "showPointer"
                    defaultValue: true
                    isLast: true
                }
            }
        }

        // ====================================================================
        // SECTION 2: OUTPUT & FORMAT SETTINGS
        // ====================================================================
        Column {
            width: parent.width
            spacing: Theme.spacingS

            SectionHeader {
                title: "Output & Format"
                iconName: "image"
            }

            Column {
                width: parent.width
                spacing: 2

                // 1. Image Format (Segmented Pill - First)
                Rectangle {
                    width: parent.width
                    height: outCol1.implicitHeight + Theme.spacingM * 2
                    topLeftRadius: root.outerR; topRightRadius: root.outerR; bottomLeftRadius: root.innerR; bottomRightRadius: root.innerR
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1; border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    ColumnLayout {
                        id: outCol1
                        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingM; anchors.rightMargin: Theme.spacingM
                        spacing: Theme.spacingS

                        RowLayout {
                            Layout.fillWidth: true; spacing: Theme.spacingM
                            Rectangle {
                                width: 32; height: 32; radius: 16
                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                Layout.alignment: Qt.AlignVCenter
                                DankIcon { name: "image"; size: 18; color: Theme.primary; anchors.centerIn: parent }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 2
                                StyledText { text: "Image Format"; font.pixelSize: Theme.fontSizeMedium; font.weight: Font.Medium; color: Theme.surfaceText }
                                StyledText { text: "Container format for saved screenshots"; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                            }
                        }

                        SegmentedSetting {
                            Layout.fillWidth: true
                            settingKey: "format"
                            defaultValue: "png"
                            options: [
                                { title: "PNG (Lossless)", value: "png", icon: "image" },
                                { title: "JPEG", value: "jpg", icon: "photo" },
                                { title: "PPM (Raw)", value: "ppm", icon: "raw_on" }
                            ]
                        }
                    }
                }

                // 2. JPEG Quality (Slider - Middle)
                Rectangle {
                    width: parent.width
                    height: outCol2.implicitHeight + Theme.spacingM * 2
                    topLeftRadius: root.innerR; topRightRadius: root.innerR; bottomLeftRadius: root.innerR; bottomRightRadius: root.innerR
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1; border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    ColumnLayout {
                        id: outCol2
                        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingM; anchors.rightMargin: Theme.spacingM
                        spacing: Theme.spacingS

                        SliderSettingV2 {
                            Layout.fillWidth: true; settingKey: "quality"
                            label: "JPEG Quality"; description: "Compression quality preset from 1-100% (JPEG only)"
                            defaultValue: "90"; minVal: 1; maxVal: 100; isFloatBackend: false; showPercentage: true
                            iconName: "high_quality"
                        }
                    }
                }

                // 3. Custom Path (Middle)
                PathFieldItem {
                    iconName: "folder"
                    title: "Custom Directory"
                    description: "Absolute path to save screenshots (leave empty for default)"
                    settingKey: "customPath"
                    defaultValue: ""
                    placeholder: root.defaultPath
                }

                // 4. Custom Filename (Last)
                PathFieldItem {
                    iconName: "terminal"
                    title: "Custom Filename"
                    description: "Override default filename pattern (e.g. %d-%m-%Y_%H%M%S)"
                    settingKey: "filename"
                    defaultValue: ""
                    placeholder: "screenshot.png"
                    isLast: true
                }
            }
        }

        // ====================================================================
        // SECTION 3: STORAGE & DESTINATIONS
        // ====================================================================
        Column {
            width: parent.width
            spacing: Theme.spacingS

            SectionHeader {
                title: "Storage & Destinations"
                iconName: "save"
            }

            Column {
                width: parent.width
                spacing: 2

                // 1. Save to Disk (First)
                SettingsToggleItem {
                    iconName: "save"
                    title: "Save to Disk"
                    description: "Save screenshot to disk (disable to only copy to clipboard)"
                    settingKey: "saveToDisk"
                    defaultValue: true
                    isFirst: true
                }

                // 2. Copy to Clipboard (Middle)
                SettingsToggleItem {
                    iconName: "content_copy"
                    title: "Copy to Clipboard"
                    description: "Copy resulting image to clipboard"
                    settingKey: "copyToClipboard"
                    defaultValue: true
                }

                // 3. Screenshot Editor (Middle or Last)
                SettingsToggleItem {
                    id: stdoutToggleItem
                    iconName: "output"
                    title: "Screenshot Editor"
                    description: "Pipe image output to stdout and custom editor command"
                    settingKey: "stdout"
                    defaultValue: false
                    isLast: !root.stdout
                    onToggled: function(newChecked) {
                        root.stdout = newChecked;
                    }
                }

                // 4. Editor Pipe Command (Conditionally Last)
                PathFieldItem {
                    visible: root.stdout
                    iconName: "terminal"
                    title: "Editor Pipe Command"
                    description: "Command executed after ' | ' (e.g. swappy -f -)"
                    settingKey: "pipeCommand"
                    defaultValue: ""
                    placeholder: "swappy -f -"
                    isLast: true
                }
            }
        }

        // ====================================================================
        // SECTION 4: NOTIFICATIONS & FEEDBACK
        // ====================================================================
        Column {
            width: parent.width
            spacing: Theme.spacingS

            SectionHeader {
                title: "Notifications & Feedback"
                iconName: "notifications"
            }

            Column {
                width: parent.width
                spacing: 2

                // 1. Show Notification (First)
                SettingsToggleItem {
                    iconName: "notifications"
                    title: "Show Notification"
                    description: "Send desktop notification when screenshot is saved"
                    settingKey: "showNotify"
                    defaultValue: true
                    isFirst: true
                }

                // 2. Show Toast Notification (Last)
                SettingsToggleItem {
                    iconName: "info"
                    title: "Show Toast Notification"
                    description: "Display quick pop-up toast on capture trigger"
                    settingKey: "showToast"
                    defaultValue: true
                    isLast: true
                }
            }
        }
    }
}
