import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Services

Column {
    id: root
    spacing: Theme.spacingM

    property var pluginService
    property string pluginId: "dmsScreenshot"

    property string mode: "interactive"
    
    property bool showPointer: true
    property bool saveToDisk: true
    property string customPath: ""
    property string defaultPath: ""
    
    property string format: "png"
    property int quality: 90
    property bool copyToClipboard: true
    property bool showNotify: true
    property bool stdout: false
    property string pipeCommand: ""
    property int delaySeconds: 0
    property string output: "" // (deprecated)
    
    property bool _isReady: true

    signal saveSetting(string key, var value)

    function loadSetting(key, defaultValue) {
        if (pluginService) {
             return pluginService.loadPluginData("dmsScreenshot", key, defaultValue);
        }
        return defaultValue;
    }


    // --- Capture Mode Section ---
    StyledRect {
        width: parent.width; anchors.horizontalCenter: parent.horizontalCenter
        height: modeColumnCC.implicitHeight + Theme.spacingM * 2

        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surfaceContainerHigh, Theme.popupTransparency)
        border.width: 1
        border.color: Theme.withAlpha(Theme.primary, 0.15)

        Column {
            id: modeColumnCC
            width: Math.max(0, parent.width - Theme.spacingM * 2)
            x: Theme.spacingM
            y: Theme.spacingM
            spacing: Theme.spacingS

            RowLayout {
                anchors.left: parent.left; anchors.right: parent.right
                anchors.leftMargin: 4; anchors.rightMargin: 4
                spacing: Theme.spacingXS
                DankIcon { name: "camera"; size: 14; color: Theme.surfaceText }
                StyledText { text: "Capture Mode"; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Bold; color: Theme.surfaceText; Layout.fillWidth: true }
            }

            Column {
                id: modeList
                width: parent.width
                spacing: 4

                Repeater {
                    model: [
                        { label: "Interactive",    val: "interactive", ic: "touch_app"     },
                        { label: "Focused Screen", val: "full",        ic: "monitor"       },
                        { label: "All Screens",    val: "all",         ic: "monitor_weight"}
                    ]

                    delegate: Item {
                    id: modeDelegate
                    width: modeList.width
                    height: 44
                    readonly property bool isSelected: root.mode === modelData.val
                    readonly property bool hovered: modeMouseArea.containsMouse
                    readonly property int  totalCount: 3   // fixed 3 items

                    // Dynamic background with Shape for selective corner rounding
                    Shape {
                        id: modeBg
                        anchors.fill: parent
                        anchors.margins: 0.5

                        property real innerRadius: 6
                        property real outerRadius: 12
                        property bool isFirst: index === 0
                        property bool isLast:  index === modeDelegate.totalCount - 1
                        
                        property real tlr: isSelected ? 21.5 : (isFirst ? outerRadius : innerRadius)
                        property real trr: isSelected ? 21.5 : (isFirst ? outerRadius : innerRadius)
                        property real blr: isSelected ? 21.5 : (isLast ? outerRadius : innerRadius)
                        property real brr: isSelected ? 21.5 : (isLast ? outerRadius : innerRadius)

                        property real tlrAnim: tlr; Behavior on tlrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                        property real trrAnim: trr; Behavior on trrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                        property real blrAnim: blr; Behavior on blrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                        property real brrAnim: brr; Behavior on brrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }

                                        readonly property color colorActive: Theme.withAlpha(Theme.primary, 0.18)
                                        readonly property color colorHovered: Theme.withAlpha(Theme.primary, 0.1)
                                        readonly property color colorInactive: Theme.withAlpha(Theme.secondary, 0.04)
                                        
                                        readonly property color borderActive: Theme.withAlpha(Theme.primary, 0.6)
                                        readonly property color borderHovered: Theme.withAlpha(Theme.primary, 0.4)
                                        readonly property color borderInactive: Theme.withAlpha(Theme.secondary, 0.15)

                                        property color paintColor: isSelected ? colorActive : (hovered ? colorHovered : colorInactive)
                                        
                                        property color paintBorder: isSelected ? borderActive : (hovered ? borderHovered : borderInactive)

                        ShapePath {
                            fillColor: modeBg.paintColor
                            strokeColor: modeBg.paintBorder
                            strokeWidth: 1

                            startX: modeBg.tlrAnim
                            startY: 0

                            PathLine { x: modeBg.width - modeBg.trrAnim; y: 0 }
                            PathArc { x: modeBg.width; y: modeBg.trrAnim; radiusX: modeBg.trrAnim; radiusY: modeBg.trrAnim; direction: PathArc.Clockwise }
                            
                            PathLine { x: modeBg.width; y: modeBg.height - modeBg.brrAnim }
                            PathArc { x: modeBg.width - modeBg.brrAnim; y: modeBg.height; radiusX: modeBg.brrAnim; radiusY: modeBg.brrAnim; direction: PathArc.Clockwise }
                            
                            PathLine { x: modeBg.blrAnim; y: modeBg.height }
                            PathArc { x: 0; y: modeBg.height - modeBg.blrAnim; radiusX: modeBg.blrAnim; radiusY: modeBg.blrAnim; direction: PathArc.Clockwise }
                            
                            PathLine { x: 0; y: modeBg.tlrAnim }
                            PathArc { x: modeBg.tlrAnim; y: 0; radiusX: modeBg.tlrAnim; radiusY: modeBg.tlrAnim; direction: PathArc.Clockwise }
                        }

                        Rectangle { 
                            anchors.fill: parent; radius: parent.tlrAnim; color: "white"
                            anchors.margins: 0.5
                            opacity: hovered ? 0.05 : 0; Behavior on opacity { NumberAnimation { duration: 150 } } 
                        }
                    }

                    DankRipple { id: modeRipple; anchors.fill: parent; cornerRadius: modeBg.tlrAnim; rippleColor: Theme.primary }

                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: Theme.spacingS
                        DankIcon { 
                            name: modelData.ic
                            color: isSelected ? Theme.primary : Theme.surfaceVariantText
                            size: 18
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        StyledText { 
                            text: modelData.label; font.pixelSize: Theme.fontSizeSmall
                            font.weight: isSelected ? Font.Bold : Font.Normal 
                            color: isSelected ? Theme.primary : Theme.surfaceText
                            Layout.fillWidth: true 
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        DankIcon { 
                            name: "check_circle"; size: 16; color: Theme.primary
                            scale: isSelected ? 1.0 : 0.0
                            opacity: isSelected ? 1.0 : 0.0
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                    }

                    MouseArea {
                        id: modeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onWheel: function(wheel) { wheel.accepted = false; }
                        onPressed: function(mouse) { modeRipple.trigger(mouse.x, mouse.y); }
                        onClicked: {
                            root.mode = modelData.val;
                            root.saveSetting("mode", modelData.val);
                        }
                    }
                } // End Item
                } // End Repeater
            } // End Column
        }
    }

    // --- Options Section ---
    StyledRect {
        width: parent.width; anchors.horizontalCenter: parent.horizontalCenter
        height: optionsColumnCC.implicitHeight + Theme.spacingM * 2
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surfaceContainerHigh, Theme.popupTransparency)
        border.width: 1
        border.color: Theme.withAlpha(Theme.primary, 0.15)



        Column {
            id: optionsColumnCC
            width: Math.max(0, parent.width - Theme.spacingM * 2)
            x: Theme.spacingM
            y: Theme.spacingM
            spacing: Theme.spacingS

            RowLayout {
                anchors.left: parent.left; anchors.right: parent.right
                anchors.leftMargin: 4; anchors.rightMargin: 4
                spacing: Theme.spacingXS
                DankIcon { name: "settings"; size: 14; color: Theme.surfaceText }
                StyledText { text: "Options"; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Bold; color: Theme.surfaceText; Layout.fillWidth: true }
            }

            Column {
                id: optionsList
                width: parent.width
                spacing: 4

                readonly property var visibleKeys: {
                    let base = ["copyToClipboard", "saveToDisk", "showPointer", "stdout", "delaySeconds"];
                    base.push("format");
                    if (root.format === "jpg") base.push("quality");
                    base.push("customPath");
                    return base;
                }

                function getGroup(key) {
                    if (key === "copyToClipboard" || key === "saveToDisk" || key === "showPointer" || key === "stdout" || key === "delaySeconds") return 1;
                    if (key === "format" || key === "quality") return 2;
                    if (key === "customPath") return 3;
                    return 0;
                }

                Repeater {
                    model: [
                        { t: "Copy to Clipboard", i: "content_copy",  k: "copyToClipboard", type: "toggle"      },
                        { t: "Save to Disk",       i: "save",          k: "saveToDisk",      type: "toggle"      },
                        { t: "Show Pointer",       i: "mouse",         k: "showPointer",     type: "toggle"      },
                        { t: "Screenshot Editor",  i: "output",        k: "stdout",          type: "toggle"      },
                        { t: "Capture Delay",      i: "schedule",      k: "delaySeconds",    type: "delay"       },
                        { t: "Image Format",       i: "image",         k: "format",          type: "format"      },
                        { t: "JPEG Quality",       i: "high_quality",  k: "quality",         type: "qualityField"},
                        { t: "Custom Directory",   i: "folder",        k: "customPath",      type: "pathField"   }
                    ]

                    delegate: Item {
                    id: optDelegate
                    width: optionsList.width
                    clip: true

                    readonly property var  vk:      optionsList.visibleKeys
                    readonly property int  vIdx:    vk.indexOf(modelData.k)
                    readonly property int  myGroup: optionsList.getGroup(modelData.k)
                    readonly property bool isVisible: vIdx !== -1
                    readonly property bool isFirst: isVisible && (vIdx === 0 || optionsList.getGroup(vk[vIdx - 1]) !== myGroup)
                    readonly property bool isLast:  isVisible && (vIdx === vk.length - 1 || optionsList.getGroup(vk[vIdx + 1]) !== myGroup)
                    readonly property bool hovered: optMouseArea.containsMouse

                    property real baseHeight: {
                        if (modelData.type === "format")       return 72;
                        if (modelData.type === "delay")        return 72;
                        if (modelData.type === "qualityField") return root.format === "jpg" ? 72 : 0;
                        if (modelData.type === "pathField")    return 72;
                        return 44;
                    }

                    readonly property real groupMargin: (isLast && vIdx !== vk.length - 1 && baseHeight > 0) ? 8 : 0
                    
                    height: baseHeight + groupMargin
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                    
                    visible: height > 0 || baseHeight > 0
                    opacity: baseHeight > 0 ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    Item {
                        id: contentCard
                        width: parent.width
                        height: parent.height - parent.groupMargin
                        clip: true

                    Shape {
                        id: optBg
                        anchors.fill: parent
                        anchors.margins: 0.5

                        property real innerRadius: 6
                        property real outerRadius: 12
                        
                        property real tlr: isFirst ? outerRadius : innerRadius
                        property real trr: isFirst ? outerRadius : innerRadius
                        property real blr: isLast ? outerRadius : innerRadius
                        property real brr: isLast ? outerRadius : innerRadius

                        property real tlrAnim: tlr; Behavior on tlrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                        property real trrAnim: trr; Behavior on trrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                        property real blrAnim: blr; Behavior on blrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                        property real brrAnim: brr; Behavior on brrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }

                        property color paintColor: hovered ? Theme.withAlpha(Theme.primary, 0.1) : Theme.withAlpha(Theme.secondary, 0.04)
                        property color paintBorder: hovered ? Theme.withAlpha(Theme.primary, 0.4) : Theme.withAlpha(Theme.secondary, 0.15)

                        ShapePath {
                            fillColor: optBg.paintColor
                            strokeColor: optBg.paintBorder
                            strokeWidth: 1

                            startX: optBg.tlrAnim
                            startY: 0

                            PathLine { x: optBg.width - optBg.trrAnim; y: 0 }
                            PathArc { x: optBg.width; y: optBg.trrAnim; radiusX: optBg.trrAnim; radiusY: optBg.trrAnim; direction: PathArc.Clockwise }
                            
                            PathLine { x: optBg.width; y: optBg.height - optBg.brrAnim }
                            PathArc { x: optBg.width - optBg.brrAnim; y: optBg.height; radiusX: optBg.brrAnim; radiusY: optBg.brrAnim; direction: PathArc.Clockwise }
                            
                            PathLine { x: optBg.blrAnim; y: optBg.height }
                            PathArc { x: 0; y: optBg.height - optBg.blrAnim; radiusX: optBg.blrAnim; radiusY: optBg.blrAnim; direction: PathArc.Clockwise }
                            
                            PathLine { x: 0; y: optBg.tlrAnim }
                            PathArc { x: optBg.tlrAnim; y: 0; radiusX: optBg.tlrAnim; radiusY: optBg.tlrAnim; direction: PathArc.Clockwise }
                        }
                    }

                    DankRipple { id: optRipple; anchors.fill: parent; cornerRadius: optBg.tlrAnim; rippleColor: Theme.primary; visible: modelData.type === "toggle" }

                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: Theme.spacingS
                        visible: modelData.type === "toggle"
                        DankIcon { name: modelData.i; color: Theme.surfaceVariantText; size: 18 }
                        StyledText { text: modelData.t; color: Theme.surfaceText; font.pixelSize: Theme.fontSizeSmall; Layout.fillWidth: true }
                        DankToggle { 
                            scale: 0.85
                            checked: root[modelData.k]
                            onClicked: { root[modelData.k] = checked; root.saveSetting(modelData.k, checked); }
                        }
                    }

                    ColumnLayout {
                        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 4
                        visible: modelData.type === "format"
                        RowLayout {
                            Layout.fillWidth: true; spacing: Theme.spacingS
                            DankIcon { name: modelData.i; color: Theme.surfaceVariantText; size: 18 }
                            StyledText { text: modelData.t; color: Theme.surfaceText; font.pixelSize: Theme.fontSizeSmall; Layout.fillWidth: true }
                        }
                        RowLayout {
                            Layout.fillWidth: true; height: 30
                            scale: 0.85; transformOrigin: Item.Left
                            spacing: 4
                            Repeater {
                                model: [
                                    { label: "PNG", val: "png" },
                                    { label: "JPG", val: "jpg" },
                                    { label: "PPM", val: "ppm" }
                                ]
                                delegate: Item {
                                    Layout.fillWidth: true; Layout.fillHeight: true
                                    
                                    readonly property bool isSelected: root.format === modelData.val
                                    readonly property bool isFirst: index === 0
                                    readonly property bool isLast: index === 2
                                    readonly property bool hovered: btnMouseArea.containsMouse
                                    
                                    Shape {
                                        id: btnBg
                                        anchors.fill: parent
                                        anchors.margins: 0.5

                                        property real innerRadius: 4
                                        property real outerRadius: 8
                                        property real pillRadius: height / 2
                                        
                                        property real tlr: isSelected ? pillRadius : (isFirst ? outerRadius : innerRadius)
                                        property real trr: isSelected ? pillRadius : (isLast ? outerRadius : innerRadius)
                                        property real blr: isSelected ? pillRadius : (isFirst ? outerRadius : innerRadius)
                                        property real brr: isSelected ? pillRadius : (isLast ? outerRadius : innerRadius)

                                        property real tlrAnim: tlr; Behavior on tlrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                                        property real trrAnim: trr; Behavior on trrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                                        property real blrAnim: blr; Behavior on blrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                                        property real brrAnim: brr; Behavior on brrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }

                                        readonly property color colorActive: Theme.withAlpha(Theme.primary, 0.18)
                                        readonly property color colorHovered: Theme.withAlpha(Theme.primary, 0.1)
                                        readonly property color colorInactive: Theme.withAlpha(Theme.secondary, 0.04)
                                        
                                        readonly property color borderActive: Theme.withAlpha(Theme.primary, 0.6)
                                        readonly property color borderHovered: Theme.withAlpha(Theme.primary, 0.4)
                                        readonly property color borderInactive: Theme.withAlpha(Theme.secondary, 0.15)

                                        property color paintColor: isSelected ? colorActive : (hovered ? colorHovered : colorInactive)
                                        
                                        property color paintBorder: isSelected ? borderActive : (hovered ? borderHovered : borderInactive)

                                        ShapePath {
                                            fillColor: btnBg.paintColor
                                            strokeColor: btnBg.paintBorder
                                            strokeWidth: 1

                                            startX: btnBg.tlrAnim
                                            startY: 0

                                            PathLine { x: btnBg.width - btnBg.trrAnim; y: 0 }
                                            PathArc { x: btnBg.width; y: btnBg.trrAnim; radiusX: btnBg.trrAnim; radiusY: btnBg.trrAnim; direction: PathArc.Clockwise }
                                            
                                            PathLine { x: btnBg.width; y: btnBg.height - btnBg.brrAnim }
                                            PathArc { x: btnBg.width - btnBg.brrAnim; y: btnBg.height; radiusX: btnBg.brrAnim; radiusY: btnBg.brrAnim; direction: PathArc.Clockwise }
                                            
                                            PathLine { x: btnBg.blrAnim; y: btnBg.height }
                                            PathArc { x: 0; y: btnBg.height - btnBg.blrAnim; radiusX: btnBg.blrAnim; radiusY: btnBg.blrAnim; direction: PathArc.Clockwise }
                                            
                                            PathLine { x: 0; y: btnBg.tlrAnim }
                                            PathArc { x: btnBg.tlrAnim; y: 0; radiusX: btnBg.tlrAnim; radiusY: btnBg.tlrAnim; direction: PathArc.Clockwise }
                                        }
                                    }
                                    StyledText {
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.weight: isSelected ? Font.Bold : Font.Normal
                                        color: isSelected ? Theme.primary : Theme.surfaceText
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                    DankRipple { id: btnRipple; anchors.fill: parent; cornerRadius: btnBg.tlrAnim; rippleColor: Theme.primary }
                                    MouseArea {
                                        id: btnMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onPressed: mouse => btnRipple.trigger(mouse.x, mouse.y)
                                        onClicked: {
                                            root.format = modelData.val;
                                            root.saveSetting("format", modelData.val);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 4
                        visible: modelData.type === "delay"
                        RowLayout {
                            Layout.fillWidth: true; spacing: Theme.spacingS
                            DankIcon { name: modelData.i; color: Theme.surfaceVariantText; size: 18 }
                            StyledText { text: modelData.t; color: Theme.surfaceText; font.pixelSize: Theme.fontSizeSmall; Layout.fillWidth: true }
                        }
                        RowLayout {
                            Layout.fillWidth: true; height: 30
                            scale: 0.85; transformOrigin: Item.Left
                            spacing: 4
                            Repeater {
                                model: [
                                    { label: "Off", val: 0 },
                                    { label: "3s", val: 3 },
                                    { label: "5s", val: 5 },
                                    { label: "10s", val: 10 }
                                ]
                                delegate: Item {
                                    Layout.fillWidth: true; Layout.fillHeight: true
                                    
                                    readonly property bool isSelected: root.delaySeconds === modelData.val
                                    readonly property bool isFirst: index === 0
                                    readonly property bool isLast: index === 3
                                    readonly property bool hovered: btnMouseArea.containsMouse
                                    
                                    Shape {
                                        id: btnBg
                                        anchors.fill: parent
                                        anchors.margins: 0.5

                                        property real innerRadius: 4
                                        property real outerRadius: 8
                                        property real pillRadius: height / 2
                                        
                                        property real tlr: isSelected ? pillRadius : (isFirst ? outerRadius : innerRadius)
                                        property real trr: isSelected ? pillRadius : (isLast ? outerRadius : innerRadius)
                                        property real blr: isSelected ? pillRadius : (isFirst ? outerRadius : innerRadius)
                                        property real brr: isSelected ? pillRadius : (isLast ? outerRadius : innerRadius)

                                        property real tlrAnim: tlr; Behavior on tlrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                                        property real trrAnim: trr; Behavior on trrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                                        property real blrAnim: blr; Behavior on blrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
                                        property real brrAnim: brr; Behavior on brrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }

                                        readonly property color colorActive: Theme.withAlpha(Theme.primary, 0.18)
                                        readonly property color colorHovered: Theme.withAlpha(Theme.primary, 0.1)
                                        readonly property color colorInactive: Theme.withAlpha(Theme.secondary, 0.04)
                                        
                                        readonly property color borderActive: Theme.withAlpha(Theme.primary, 0.6)
                                        readonly property color borderHovered: Theme.withAlpha(Theme.primary, 0.4)
                                        readonly property color borderInactive: Theme.withAlpha(Theme.secondary, 0.15)

                                        property color paintColor: isSelected ? colorActive : (hovered ? colorHovered : colorInactive)
                                        
                                        property color paintBorder: isSelected ? borderActive : (hovered ? borderHovered : borderInactive)

                                        ShapePath {
                                            fillColor: btnBg.paintColor
                                            strokeColor: btnBg.paintBorder
                                            strokeWidth: 1

                                            startX: btnBg.tlrAnim
                                            startY: 0

                                            PathLine { x: btnBg.width - btnBg.trrAnim; y: 0 }
                                            PathArc { x: btnBg.width; y: btnBg.trrAnim; radiusX: btnBg.trrAnim; radiusY: btnBg.trrAnim; direction: PathArc.Clockwise }
                                            
                                            PathLine { x: btnBg.width; y: btnBg.height - btnBg.brrAnim }
                                            PathArc { x: btnBg.width - btnBg.brrAnim; y: btnBg.height; radiusX: btnBg.brrAnim; radiusY: btnBg.brrAnim; direction: PathArc.Clockwise }
                                            
                                            PathLine { x: btnBg.blrAnim; y: btnBg.height }
                                            PathArc { x: 0; y: btnBg.height - btnBg.blrAnim; radiusX: btnBg.blrAnim; radiusY: btnBg.blrAnim; direction: PathArc.Clockwise }
                                            
                                            PathLine { x: 0; y: btnBg.tlrAnim }
                                            PathArc { x: btnBg.tlrAnim; y: 0; radiusX: btnBg.tlrAnim; radiusY: btnBg.tlrAnim; direction: PathArc.Clockwise }
                                        }
                                    }
                                    StyledText {
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.weight: isSelected ? Font.Bold : Font.Normal
                                        color: isSelected ? Theme.primary : Theme.surfaceText
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                    DankRipple { id: btnRipple; anchors.fill: parent; cornerRadius: btnBg.tlrAnim; rippleColor: Theme.primary }
                                    MouseArea {
                                        id: btnMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onPressed: mouse => btnRipple.trigger(mouse.x, mouse.y)
                                        onClicked: {
                                            root.delaySeconds = modelData.val;
                                            root.saveSetting("delaySeconds", String(modelData.val));
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 4
                        visible: modelData.type === "pathField" || modelData.type === "qualityField"
                        RowLayout {
                            Layout.fillWidth: true; spacing: Theme.spacingS
                            DankIcon { name: modelData.i; color: Theme.surfaceVariantText; size: 18 }
                            StyledText { text: modelData.t; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceText; Layout.fillWidth: true }
                        }
                        DankTextField {
                            Layout.fillWidth: true; height: 28
                            font.pixelSize: Theme.fontSizeSmall - 2
                            text: modelData.k === "quality" ? root.quality.toString() : root.customPath
                            placeholderText: modelData.k === "quality" ? "90" : root.defaultPath
                            onEditingFinished: {
                                if (modelData.k === "quality") {
                                    var v = parseInt(text);
                                    if (!isNaN(v)) { root.quality = v; root.saveSetting("quality", v); }
                                } else {
                                    root.customPath = text; root.saveSetting("customPath", text);
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: optMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: modelData.type === "toggle" ? Qt.LeftButton : Qt.NoButton
                        onPressed: if (modelData.type === "toggle") optRipple.trigger(mouse.x, mouse.y)
                        onClicked: if (modelData.type === "toggle") { root[modelData.k] = !root[modelData.k]; root.saveSetting(modelData.k, root[modelData.k]); }
                    }
                    }
                } // End Item
            } // End Repeater
        } // End Column optionsList
        } // End Column optionsColumnCC
    } // End StyledRect
} // End root Item