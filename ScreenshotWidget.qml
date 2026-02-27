import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // --- State Management ---
    property string captureMode: "interactive" // interactive, window, screen
    property bool showPointer: true
    property bool saveToDisk: true

    // UI properties for the widget interface
    ccWidgetIcon: "photo_camera"
    ccWidgetPrimaryText: I18n.tr("Screenshot", "Screenshot tool name")
    ccWidgetSecondaryText: {
        switch(captureMode) {
            case "interactive": return I18n.tr("Interactive Mode");
            case "window": return I18n.tr("Focused Window");
            case "screen": return I18n.tr("Focused Screen");
            default: return "";
        }
    }
    
    // Logic to execute the dms command
    function triggerCapture() {
        let args = ["dms", "screenshot"];
        
        // Add mode
        if (captureMode === "interactive") args.push("--interactive");
        else if (captureMode === "window") args.push("--window");
        else if (captureMode === "screen") args.push("--screen");
        
        // Add options
        if (showPointer) args.push("--pointer");
        if (saveToDisk) args.push("--save");
        
        Quickshell.execDetached(args);
        
        // Close the UI if it's in a popout
        if (typeof closePopout === "function") closePopout();
    }

    // --- Control Center Detail (screenshot-control-center.png) ---
    ccDetailContent: Component {
        Column {
            spacing: Theme.spacingM
            width: parent.width

            StyledText {
                text: I18n.tr("Screenshot Settings")
                font.pixelSize: Theme.fontSizeL
                color: Theme.surfaceVariantText
            }

            // Capture Button
            DankButton {
                width: parent.width
                text: I18n.tr("Capture")
                iconName: "photo_camera"
                highlighted: true
                onClicked: root.triggerCapture()
            }

            // Mode Selection Group
            Column {
                width: parent.width
                spacing: 2
                
                StyledText { 
                    text: I18n.tr("Capture Mode"); 
                    font.pixelSize: Theme.fontSizeS; 
                    color: Theme.primary 
                    bottomPadding: 4
                }

                ModeEntry {
                    text: I18n.tr("Interactive (UI)")
                    icon: "touch_app"
                    active: root.captureMode === "interactive"
                    onClicked: root.captureMode = "interactive"
                }
                ModeEntry {
                    text: I18n.tr("Focused Window")
                    icon: "grid_view"
                    active: root.captureMode === "window"
                    onClicked: root.captureMode = "window"
                }
                ModeEntry {
                    text: I18n.tr("Focused Screen")
                    icon: "monitor"
                    active: root.captureMode === "screen"
                    onClicked: root.captureMode = "screen"
                }
            }
        }
    }

    // --- Bar Pill UI ---
    horizontalBarPill: Component {
        DankIcon {
            name: "photo_camera"
            size: Theme.barIconSize(root.barThickness, -4)
            color: Theme.widgetIconColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // --- Popout Content (screenshot-bar-widget.png) ---
    popoutContent: Component {
        PopoutComponent {
            id: popout
            headerText: I18n.tr("Screenshot Settings")
            detailsText: I18n.tr("Configure capture mode and options")
            showCloseButton: true

            Column {
                width: parent.width
                spacing: Theme.spacingL

                DankButton {
                    width: parent.width
                    text: I18n.tr("Capture")
                    iconName: "photo_camera"
                    highlighted: true
                    onClicked: root.triggerCapture()
                }

                // Modes Section
                Column {
                    width: parent.width
                    spacing: Theme.spacingS
                    
                    StyledText { text: I18n.tr("Capture Mode"); color: Theme.surfaceVariantText }
                    
                    ModeEntry {
                        text: I18n.tr("Interactive (UI)")
                        icon: "touch_app"
                        active: root.captureMode === "interactive"
                        onClicked: root.captureMode = "interactive"
                    }
                    ModeEntry {
                        text: I18n.tr("Focused Window")
                        icon: "grid_view"
                        active: root.captureMode === "window"
                        onClicked: root.captureMode = "window"
                    }
                    ModeEntry {
                        text: I18n.tr("Focused Screen")
                        icon: "monitor"
                        active: root.captureMode === "screen"
                        onClicked: root.captureMode = "screen"
                    }
                }

                // Options Section
                Column {
                    width: parent.width
                    spacing: Theme.spacingS
                    
                    StyledText { text: I18n.tr("Options"); color: Theme.surfaceVariantText }

                    DankCheckBox {
                        text: I18n.tr("Show Pointer")
                        checked: root.showPointer
                        onToggled: root.showPointer = !root.showPointer
                    }

                    DankCheckBox {
                        text: I18n.tr("Save to Disk")
                        checked: root.saveToDisk
                        onToggled: root.saveToDisk = !root.saveToDisk
                    }
                }
            }
        }
    }
}