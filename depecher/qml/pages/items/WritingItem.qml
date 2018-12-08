import QtQuick 2.0
import QtQml 2.2
import Sailfish.Silica 1.0

Drawer {
    id: attachDrawer
    state: "publish"
    property Page rootPage
    property int sendAreaHeight: sendArea.height
    property alias bottomArea: sendArea
    property alias actionButton: sendButton
    property alias text: messageArea.text
    property alias textArea:messageArea
    property alias replyMessageAuthor: authorsLabel.text
    property alias replyMessageText: authorsTextLabel.text
    property alias returnButtonItem: returnButton
    property alias returnButtonEnabled: returnButton.enabled
    property string reply_id: "0"
    property string typeWriter
    signal sendFiles(var files)
    signal setFocusToEdit()

    function clearReplyArea() {
        replyMessageAuthor = ""
        replyMessageText = ""
        reply_id = "0"
        if(writer.state=="edit")
            writer.state = "publish"

    }
    onSetFocusToEdit: messageArea.focus = true

    states: [
        State{
            name:"publish"
        },
        State{
            name:"edit"
        }
    ]

    open: false
    dock: Dock.Bottom
    anchors.fill: parent

    Item {
        id: sendArea
        anchors.bottom: parent.bottom
        width: parent.width
        height: replyArea.height + messageArea.height + returnButton.height + Theme.paddingSmall

        BackgroundItem {
        id:returnButton
        width: parent.width
        height: enabled ? Theme.paddingLarge + Theme.paddingMedium : 0
        anchors.bottom: replyArea.top
        enabled: false
        visible: enabled
        Rectangle {
            anchors.fill: parent
            color: Theme.highlightColor
        }
        Image {
             source: "image://theme/icon-s-low-importance"
             anchors.centerIn: parent
        }
        }

        Item {
            id: replyArea
            width: parent.width
            height: reply_id != "0" ? Theme.itemSizeExtraSmall : 0
            anchors.bottom: messageArea.top
            Rectangle {
                id: replyLine
                width: 3
                height: parent.height
                color: Theme.secondaryHighlightColor
                anchors.left: parent.left
                anchors.leftMargin: 8
            }

            Column {
                id: data
                anchors.left: replyLine.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: removeReplyButton.left

                Label {
                    id: authorsLabel
                    font.pixelSize: Theme.fontSizeExtraSmall
                    width: parent.width
                    elide: TruncationMode.Fade
                    height: authorsTextLabel.text == "" ? removeReplyButton.height : implicitHeight
                }
                Label {
                    id: authorsTextLabel
                    font.pixelSize: Theme.fontSizeExtraSmall
                    width: parent.width
                    maximumLineCount: 1
                    elide: TruncationMode.Fade
                    visible: authorsText != ""
                }
            }

            IconButton{
                id: removeReplyButton
                icon.source: "image://theme/icon-s-clear-opaque-cross?"+Theme.highlightColor
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                visible: parent.height!=0
                onClicked: {
                    clearReplyArea()
                }
            }
        }

        IconButton {
            id: skrepkaWizard
            icon.source: "image://theme/icon-m-attach"
            width: visible ? stickerButton.width : 0
            highlighted: false
            anchors.bottom: messageArea.bottom
            anchors.left:parent.left
            anchors.bottomMargin: 25
            onClicked: {
                attachLoader.setSource("AttachComponent.qml")
                attachDrawer.open=true
            }
            visible: messageArea.text.length == 0
        }
        IconButton {
            id:stickerButton
            icon.source: "image://theme/icon-m-other"
            highlighted: false
            anchors.bottom: messageArea.bottom
            anchors.left:skrepkaWizard.right
            anchors.bottomMargin: 25
            onClicked: {
                if(!attachDrawer.opened)
                attachLoader.setSource("AttachSticker.qml",{previewView:foregroundItem,rootPage:rootPage})
                attachDrawer.open=!attachDrawer.open
            }
        }

        TextArea {
            id: messageArea
            onTextChanged: {
                if(text === "")
                    messageArea.forceActiveFocus()
            }
            anchors.left: stickerButton.right
            anchors.bottom: parent.bottom
            anchors.right: sendButton.left
            height:  Math.min(Theme.itemSizeHuge,implicitHeight)
            width:parent.width - sendButton.width - skrepkaWizard.width - stickerButton.width
            _labelItem.opacity: 1
            _labelItem.font.pixelSize: Theme.fontSizeTiny

            Timer {
                interval: 60*1000
                repeat: true
                running: true
                onTriggered: {
                    var date = new Date()
                    messageArea.label =  Format.formatDate(date, Formatter.TimeValue)
                }
            }
            Component.onCompleted: {
                var date = new Date()
                label =  Format.formatDate(date, Formatter.TimeValue)
            }
        }

        IconButton {
            id: sendButton
            icon.source: "image://theme/icon-m-message"
            highlighted: false
            anchors.bottom: messageArea.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 25
        }
    }

    MouseArea {
        enabled: attachDrawer.open
        anchors.fill: parent
        onClicked: attachDrawer.open = false
    }

    Connections {
        target: attachLoader.item
        onSendUrlItems:
        {
            sendFiles(items)
        }
    }

    background: Loader {
        id: attachLoader
        anchors.fill: parent
    }
    onOpenedChanged:
        if(!opened)
            attachLoader.sourceComponent=undefined
}
