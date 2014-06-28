﻿/********************************************************************

qml/Pages/RosterPage.qml
-- displays contact list and interfaces with XmppConnectivity

Copyright (c) 2013-2014 Maciej Janiszewski

This file is part of Lightbulb.

Lightbulb is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*********************************************************************/

import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import lightbulb 1.0
import "../Components"

Page {
    id: rosterPage
    objectName: "rosterPage"
    tools: toolBarLayout


    Connections {
        target: xmppConnectivity.client
        onErrorHappened: errorText.text = errorString
        onStatusChanged: if (xmppConnectivity.client.status == XmppClient.Offline) errorText.text = ""
    }

    Connections {
        target: xmppConnectivity
        onChatJidChanged: if (xmppConnectivity.chatJid == "") vars.selectedJid = "";
    }

    Connections {
        target: vars
        onHideOfflineChanged: {
            if (rosterSearch.height == 0)
                xmppConnectivity.offlineContactsVisibility = !vars.hideOffline
        }
    }

    Component.onCompleted: statusBarText.text = "Contacts"

    /*******************************************************************************/

    Component {
        id: componentRosterItem

        Rectangle {
            id: wrapper
            width: rosterView.width
            color: "transparent"
            visible: rosterSearch.text !== "" ? (txtJid.contact.toLowerCase().indexOf(rosterSearch.text.toLowerCase()) != -1 ? true : false ) : true
            height: vars.rosterItemHeight - txtJid.font.pixelSize > txtJid.height ? vars.rosterItemHeight : txtJid.height + txtJid.font.pixelSize

            gradient: gr_free
            Gradient {
                id: gr_free
                GradientStop { id: gr1; position: 0; color: "transparent" }
                GradientStop { id: gr3; position: 1; color: "transparent" }
            }
            Gradient {
                id: gr_press
                GradientStop { position: 0; color: "#1C87DD" }
                GradientStop { position: 1; color: "#51A8FB" }
            }

            states: [State {
                    name: "Current"
                    when: vars.selectedJid == jid
                    PropertyChanges { target: wrapper; gradient: gr_press }
                },State {
                    name: "Not current"
                    when: !vars.selectedJid == jid
                    PropertyChanges { target: wrapper; gradient: gr_free }
                }]

            Image {
                id: imgPresence
                source: vars.rosterLayoutAvatar ? avatar : presence
                sourceSize.height: vars.rosterItemHeight-4
                sourceSize.width: vars.rosterItemHeight-4
                anchors { top: parent.top; topMargin: (vars.rosterItemHeight-sourceSize.height)/2; left: parent.left; leftMargin: 10 }
                height: vars.rosterItemHeight-4
                width: vars.rosterItemHeight-4
                Image {
                    id: imgUnreadMsg
                    source: main.platformInverted ? "qrc:/unread-mark_inverse" : "qrc:/unread-mark"
                    sourceSize.height: imgPresence.height
                    sourceSize.width: imgPresence.height
                    smooth: true
                    visible: vars.markUnread ? unreadMsg != 0 : false
                    anchors.centerIn: parent
                    opacity: unreadMsg != 0 ? 1 : 0
                    Image {
                        id: imgUnreadCount
                        source: "qrc:/unread-count"
                        sourceSize.height: imgPresence.height
                        sourceSize.width: imgPresence.height
                        smooth: true
                        visible: vars.showUnreadCount ? unreadMsg != 0 : false
                        anchors.centerIn: parent
                        opacity: unreadMsg != 0 ? 1 : 0
                    }
                    Rectangle {
                        color: "transparent"
                        width: imgPresence.width * 0.30
                        height: width
                        anchors { right: parent.right; bottom: parent.bottom }
                        visible: vars.showUnreadCount ? unreadMsg != 0 : false
                        Text {
                            text: unreadMsg
                            font.pixelSize: 0.72*parent.width
                            anchors.centerIn: parent
                            z: 1
                            color: "white"
                        }
                    }
                }
            } //imgPresence
            Text {
                id: txtJid
                property string contact: (name === "" ? jid : name)
                anchors { left: imgPresence.right; right: imgPresenceR.left; leftMargin: 10; rightMargin: 10; verticalCenter: parent.verticalCenter }
                width: parent.width
                maximumLineCount: (vars.rosterItemHeight/22) > 1 ? (vars.rosterItemHeight/22) : 1
                text: (name === "" ? jid : name) + ((vars.showContactStatusText && statusText != "") ? (" · <font color='#aaaaaa'><i>" + statusText + "</i></font>") : "")
                onLinkActivated: dialog.createWithProperties("qrc:/menus/UrlContext", {"url": link})
                wrapMode: Text.WordWrap
                font.pixelSize: (vars.showContactStatusText ? 16 : 0)
                color: vars.textColor
            }
            MouseArea {
                id: mouseAreaItem;
                anchors.fill: parent

                onClicked: {
                    if (xmppConnectivity.currentAccount != accountId) xmppConnectivity.currentAccount = accountId
                    xmppConnectivity.chatJid = jid
                    vars.selectedJid = jid
                    vars.globalUnreadCount = vars.globalUnreadCount - unreadMsg
                    notify.updateNotifiers()
                    main.pageStack.push("qrc:/pages/Messages",{"contactName":txtJid.contact})
                }

                onPressAndHold: {
                    vars.selectedJid = jid
                    dialog.createWithProperties("qrc:/menus/Roster/Contact",{"accountId": accountId,"contactName":txtJid.contact,"contactJid":jid})
                }
            }
            Image {
                id: imgPresenceR
                source: vars.rosterLayoutAvatar ? presence : ""
                sourceSize.height: (wrapper.height/3) - 4
                sourceSize.width: (wrapper.height/3) - 4
                anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: vars.rosterLayoutAvatar ? 10 : 0 }
                height: vars.rosterLayoutAvatar ? (vars.rosterItemHeight/3) - 4 : 0
                width: vars.rosterLayoutAvatar ? (vars.rosterItemHeight/3) - 4 : 0
            }
            Rectangle {
                height: 1
                anchors { top: parent.bottom; left: parent.left; right: parent.right; leftMargin: 5; rightMargin: 5 }
                color: vars.textColor
                opacity: 0.2
            }
        } //Rectangle
    }

    Flickable {
        id: rosterView
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: rosterSearch.top; }
        contentHeight: columnContent.height
        contentWidth: columnContent.width
        clip: true

        flickableDirection: Flickable.VerticalFlick
        Column {
            id: columnContent
            spacing: 0

            Repeater {
                model: xmppConnectivity.roster
                delegate: componentRosterItem
            }
        }
    }

    ScrollBar {
        id: scrollBar

        anchors {
            top: parent.top
            bottom: rosterSearch.top
            right: parent.right
            margins: platformStyle.paddingSmall
        }
        flickableItem: rosterView
        platformInverted: main.platformInverted
    }

    /*********************************************************************/

    TextField {
        id: rosterSearch
        height: 0
        width: parent.width
        anchors.bottom: parent.bottom
        placeholderText: qsTr("Tap to write")

        Behavior on height { SmoothedAnimation { velocity: 200 } }
        onTextChanged: {
            if (text.length > 0) {
                if (!xmppConnectivity.offlineContactsVisibility)
                    xmppConnectivity.offlineContactsVisibility = true;
            } else if (xmppConnectivity.offlineContactsVisibility != !vars.hideOffline) xmppConnectivity.offlineContactsVisibility = !vars.hideOffline
        }
    }

    Item {
        id: splitViewInput

        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }

        Behavior on height { PropertyAnimation { duration: 1 } }

        states: [
            State {
                name: "Visible"; when: inputContext.visible
                PropertyChanges { target: splitViewInput; height: inputContext.height - toolBarLayout.height }
                PropertyChanges { target: vars; inputInProgress: true }
            },

            State {
                name: "Hidden"; when: !inputContext.visible
                PropertyChanges { target: splitViewInput; }
                PropertyChanges { target: vars; inputInProgress: false }
            }
        ]
    }

    ToolBarLayout {
        id: toolBarLayout
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-back_inverse" : "toolbar-back"
            onClicked: avkon.minimize();
            onPlatformPressAndHold: {
                avkon.hideChatIcon()
                Qt.quit();
            }
        }
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-add_inverse" : "toolbar-add"
            onClicked: dialog.createWithContext("qrc:/dialogs/Contact/Add")
        }
        ToolButton {
            iconSource: main.platformInverted ? "toolbar-search_inverse" : "toolbar-search"
            onClicked: {
                if (rosterSearch.height == 50) {
                    if (xmppConnectivity.offlineContactsVisibility != !vars.hideOffline)
                            xmppConnectivity.offlineContactsVisibility = !vars.hideOffline;
                    rosterSearch.height = 0;
                    rosterSearch.text = "";
                } else {
                    rosterSearch.height = 50;
                }
            }
        }

        ToolButton {
            id: toolBarButtonChats
            iconSource: main.platformInverted ? "qrc:/toolbar/chats_inverse" : "qrc:/toolbar/chats"
            onClicked: dialog.create("qrc:/dialogs/Chats")

            Image {
                id: imgMarkUnread
                source: main.platformInverted ? "qrc:/unread-mark_inverse" : "qrc:/unread-mark"
                smooth: true
                sourceSize.width: toolBarButtonChats.width
                sourceSize.height: toolBarButtonChats.width
                width: toolBarButtonChats.width
                height: toolBarButtonChats.width
                visible: vars.globalUnreadCount != 0
                anchors.centerIn: parent
            }
            Text {
                id: txtUnreadMsg
                text: vars.globalUnreadCount
                font.pixelSize: 16
                anchors.centerIn: parent
                visible: vars.globalUnreadCount != 0
                z: 1
                color: main.platformInverted ? "white" : "black"
            }
        }
        ToolButton {
            id: toolBarButtonOptions
            iconSource: main.platformInverted ? "toolbar-menu_inverse" : "toolbar-menu"
            smooth: true
            onClicked: dialog.create("qrc:/menus/Roster/Options")
        }
    }

    Rectangle {

        color: main.platformInverted ? "white" : "black"
        opacity: 0.7
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom }
        NumberAnimation { properties: "visible"; duration: 200 }

        visible: xmppConnectivity.client.status == XmppClient.Offline

        Rectangle {
            anchors.centerIn: parent
            color: "transparent"
            height: sadface.height + 5 + offlineText.height + 10 + errorText.height
            width: offlineText.width
            visible: xmppConnectivity.client.status == XmppClient.Offline
            Text {
                id: sadface
                color: vars.textColor
                anchors { top: parent.top; left: parent.left }
                visible: parent.visible
                text: ":("
                font.pixelSize: 64
            }
            Text {
                id: offlineText
                color: vars.textColor
                anchors { top: sadface.bottom; horizontalCenter: parent.horizontalCenter; topMargin: 5 }
                visible: parent.visible
                text: settings.accounts.count() > 0 ? (xmppConnectivity.currentAccount == "" ? "No account\nselected" : "You're offline") : "No accounts\navailable"
                font.pixelSize: 32
            }
            Text {
                id: errorText
                color: vars.textColor
                anchors { top: offlineText.bottom; topMargin: 10 }
                visible: parent.visible
                text: ""
                font.pixelSize: 16
            }
        }
    }
}
