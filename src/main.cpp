/********************************************************************

src/main.cpp

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

#include <QtGui/QApplication>
#include <QtGui/QSplashScreen>
#include <QtGui/QPixmap>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/qdeclarative.h>
#include <QUrl>
#include "qmlapplicationviewer.h"

#include "MyXmppClient.h"

#include "AccountsListModel.h"
#include "RosterListModel.h"
#include "MsgListModel.h"
#include "QMLVCard.h"
#include "Settings.h"
#include "LightbulbHSWidget.h"
#include "QAvkonHelper.h"
#include "DatabaseManager.h"
#include "SymbiosisAPIClient.h"
#include "SkinSelectorHandler.h"
#include "XmppConnectivity.h"
#include "EmoticonParser.h"
#include "NetworkManager.h"

Q_DECL_EXPORT int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    QSplashScreen *splash = new QSplashScreen(QPixmap(":/splash"));
    splash->show();

    // expose C++ classes to QML
    qmlRegisterType<Settings>("lightbulb", 1, 0, "Settings" );
    qmlRegisterType<QMLVCard>("lightbulb", 1, 0, "XmppVCard" );
    qmlRegisterType<ClipboardAdapter>("lightbulb", 1, 0, "Clipboard" );
    qmlRegisterType<LightbulbHSWidget>("lightbulb", 1, 0, "HSWidget" );
    qmlRegisterType<SkinSelectorHandler>("lightbulb",1,0,"SelectorHandler");
    qmlRegisterType<XmppConnectivity>("lightbulb",1,0,"XmppConnectivity");

    qmlRegisterType<NetworkManager>("lightbulb",1,0,"NetworkManager");

    qmlRegisterType<SymbiosisAPIClient>("lightbulb", 1, 0, "SymbiosisAPI" );

    qmlRegisterUncreatableType<SqlQueryModel>("lightbulb", 1, 0, "SqlQuery", "");
    qmlRegisterUncreatableType<AccountsListModel>("lightbulb", 1, 0, "AccountsList", "Use settings.accounts instead");
    qmlRegisterUncreatableType<RosterListModel>("lightbulb",1,0,"RosterModel","");
    qmlRegisterUncreatableType<ChatsListModel>("lightbulb",1,0,"ChatsModel","because I say so, who cares?");
    qmlRegisterUncreatableType<MsgListModel>("lightbulb", 1, 0, "MsgModel", "because sliced bread is awesome");
    qmlRegisterUncreatableType<MyXmppClient>("lightbulb", 1, 0, "XmppClient", "Use XmppConnectivity.client instead" );

    // initialize viewer and set it parameters
    QmlApplicationViewer viewer;
    QAvkonHelper avkon(&viewer);
    viewer.rootContext()->setContextProperty("avkon", &avkon);

    EmoticonParser parser;
    viewer.rootContext()->setContextProperty("emoticon",&parser);

    viewer.setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.setAttribute(Qt::WA_NoSystemBackground);
    viewer.viewport()->setAttribute(Qt::WA_OpaquePaintEvent);
    viewer.viewport()->setAttribute(Qt::WA_NoSystemBackground);
    viewer.setProperty("orientationMethod", 1);

    viewer.setSource( QUrl(QLatin1String("qrc:/qml/main.qml")) );
    viewer.showFullScreen();

    splash->finish(&viewer);
    splash->deleteLater();

    return app.exec();
}

