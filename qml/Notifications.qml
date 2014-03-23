/********************************************************************

qml/Notifications.qml
-- Handles notifications. Should be redone with C++ in XmppConnectivity
-- class

Copyright (c) 2013 Maciej Janiszewski

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
import QtMobility.feedback 1.1
import lightbulb 1.0

Item {
    Component.onCompleted: if (settings.gBool("widget","enableHsWidget")) hsWidget.registerWidget()
    Connections {
        target: xmppConnectivity
        onWidgetDataChanged: updateWidget()
    }

    function getStatusNameByIndex(status) {
       if (status == XmppClient.Online) return "online"
       else if (status == XmppClient.Chat) return "chatty"
       else if (status == XmppClient.Away) return "away"
       else if (status == XmppClient.XA) return "xa"
       else if (status == XmppClient.DND) return "busy"
       else if (status == XmppClient.Offline) return "offline"
    }

    function updateNotifiers() {
        if (vars.globalUnreadCount > 0 && !settings.gBool("behavior","disableChatIcon"))
            avkon.showChatIcon();
        else avkon.hideChatIcon();
        updateWidget();
    }

    function cleanWidget() {
        hsWidget.changeRow(0,"",-2,"",0,false)
        hsWidget.changeRow(1,"",-2,"",0,false)
        hsWidget.changeRow(2,"",-2,"",0,false)
        hsWidget.changeRow(3,"",-2,"",0,false)
        hsWidget.unreadCount = 0
        hsWidget.status = 0
        hsWidget.pushWidget()
    }

    function updateWidget() {
        if (settings.gBool("widget","enableHsWidget")) {
            hsWidget.status = xmppConnectivity.client.status
            hsWidget.unreadCount = vars.globalUnreadCount
            hsWidget.getLatest4Chats();
            hsWidget.pushWidget();
        }
    }

    HSWidget {
        id: hsWidget
        property int unreadCount: 0
        property int status: 0

        Component.onCompleted: {
            var skinName = settings.gStr("widget","skin")
            if (skinName === "false") skinName = "C:\\data\\.config\\Lightbulb\\widgets\\Belle Albus";
            loadSkin(skinName);
            if (settings.gBool("widget","enableHsWidget")) cleanWidget()
        }

        function pushWidget() { postWidget(unreadCount,status,settings.gBool("widget","showGlobalUnreadCnt"),settings.gBool("widget","showUnreadCntChat"),settings.gBool("widget","showStatus"),xmppConnectivity.getAccountIcon(xmppConnectivity.currentAccount)); }

        function getLatest4Chats() {
            var name,presence,unreadCount,accountId;
            for (var i=0; i<4;i++) {
                name = xmppConnectivity.getChatProperty(i+1,"name")
                presence = xmppConnectivity.getChatProperty(i+1,"presence")
                unreadCount = xmppConnectivity.getChatProperty(i+1,"unreadMsg")
                accountId = xmppConnectivity.getChatProperty(i+1,"accountId")
                hsWidget.changeRow(i,name,presence,accountId,unreadCount,false)
            }
            hsWidget.renderWidget()
        }
        function getFirst4Contacts() {
            /*row1 = xmppConnectivity.client.getNameByOrderID(0);
            r1presence = getPresenceId(xmppConnectivity.client.getPresenceByOrderID(0));
            row2 = xmppConnectivity.client.getNameByOrderID(1);
            r2presence = getPresenceId(xmppConnectivity.client.getPresenceByOrderID(1));
            row3 = xmppConnectivity.client.getNameByOrderID(2);
            r3presence = getPresenceId(xmppConnectivity.client.getPresenceByOrderID(2));
            row4 = xmppConnectivity.client.getNameByOrderID(3);
            r4presence = getPresenceId(xmppConnectivity.client.getPresenceByOrderID(3));*/
        }
        function getPresenceId(presence) {
            if (presence == "qrc:/presence/online") return 0;
            else if (presence == "qrc:/presence/chatty") return 1;
            else if (presence == "qrc:/presence/away") return 2;
            else if (presence == "qrc:/presence/busy") return 3;
            else if (presence == "qrc:/presence/xa") return 4;
            else if (presence == "qrc:/presence/offline") return 5;
            else return -2;
        }
    }

    function updateSkin() {
        var skinName = settings.gStr("widget","skin")
        if (skinName === "false") skinName = "C:\\data\\.config\\Lightbulb\\widgets\\Belle Albus";
        hsWidget.loadSkin(skinName);
        hsWidget.renderWidget();
    }

    function postInfo(messageString) { avkon.displayGlobalNote(messageString,false) }
    function postError(messageString) { avkon.displayGlobalNote(messageString,true) }

    function registerWidget() {
        if (settings.gBool("widget","enableHsWidget")) {
            hsWidget.registerWidget()
            hsWidget.publishWidget()
        }
    }

    function removeWidget() { hsWidget.removeWidget() }

    HapticsEffect { id: hapticsEffect }

    function notifySndVibr(how) {
        if( settings.gBool("notifications","vibra"+how )) {
            hapticsEffect.duration = settings.gInt("notifications","vibra"+how+"Duration" )
            hapticsEffect.intensity = settings.gInt("notifications","vibra"+how+"Intensity" )/100
            hapticsEffect.running = true
        }
        if( settings.gBool("notifications","sound"+how ))
            avkon.playNotification(settings.gStr("notifications","sound"+how+"File" ));
    }
}
