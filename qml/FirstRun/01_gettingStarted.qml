// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: firstRunPage
    tools: toolBarLayout
    orientationLock: 1

    Component.onCompleted: statusBarText.text = qsTr("First run")

    Text {
        id: chapter
        color: main.textColor
        anchors { top: parent.top; topMargin: 32; horizontalCenterOffset: 0; horizontalCenter: parent.horizontalCenter }
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: platformStyle.fontSizeMedium*1.5
        text: "Getting Started"
    }

    Text {
        id: text
        color: main.textColor
        anchors { top: chapter.bottom; topMargin: 24; left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
        wrapMode: Text.WordWrap
        font.pixelSize: 20
        text: "Welcome to Lightbulb!\n\nIt looks like it's your first time! In the next few steps, app will be configured for you.\n\nTap on \"Next\" whenever you're ready to begin, or just tap on \"Close\" to close the wizard. Don't worry, if you change your mind or simply get something wrong, you can change all the settings later. :)"
    }

    // toolbar

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "qrc:/toolbar/close_inverse" : "qrc:/toolbar/close"
            onClicked: {
                pageStack.replace("qrc:/pages/Roster")
                settings.sBool(true,"main","not_first_run")
                settings.sStr(xmppClient.version,"main","last_used_rel")
            }
        }

        ToolButton {
            iconSource: main.platformInverted ? "toolbar-next_inverse" : "toolbar-next"
            onClicked: pageStack.push("qrc:/FirstRun/02")
        }

    }


}

