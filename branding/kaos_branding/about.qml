/* === This file is part of Calamares - <https://calamares.io> ===
 *
 *   SPDX-FileCopyrightText: 2020 2022 Anke Boersma <demm@kaosx.us>
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Calamares is Free Software: see the License-Identifier above.
 *
 */

import io.calamares.core 1.0
import io.calamares.ui 1.0

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.3

ApplicationWindow {
    id: about
    visible: true
    width: 760
    height: 400
    title: qsTr("About Calamares")

    property var appName: "Calamares"
    property var appVersion: "3.3 RC"

    Rectangle {
        id: textArea
        anchors.fill: parent
        color: "#f2f2f2"

        Column {
            id: column
            anchors.centerIn: parent


            Rectangle {
                width: 560
                height: 250
                radius: 10
                border.width: 0

                Text {
                    width: 400
                    height: 250
                    anchors.centerIn: parent
                    text: qsTr("<h1>%1</h1><br/>
                        <strong>%2<br/>
                        for %3</strong><br/><br/>
                        Copyright 2014-2017 Teo Mrnjavac &lt;teo@kde.org&gt;<br/>
                        Copyright 2017-2022 Adriaan de Groot &lt;groot@kde.org&gt;<br/>
                        Thanks to <a href='https://calamares.io/team/'>the Calamares team</a>
                        and the <a href=\"https://www.transifex.com/kaos/kaos/\">KaOS
                        translators team</a>.<br/><br/>
                        <a href='https://calamares.io/'>Calamares</a>
                        development is sponsored by <br/>
                        <a href='http://www.blue-systems.com/'>Blue Systems</a> -
                        Liberating Software." )
                        .arg(appName)
                        .arg(appVersion)
                        .arg(Branding.string(Branding.VersionedName))

                        onLinkActivated: Qt.openUrlExternally(link)

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }

                    font.pointSize: 10
                    anchors.verticalCenterOffset: 10
                    anchors.horizontalCenterOffset: 40
                    wrapMode: Text.WordWrap
                }

                Image {
                    id: image
                    x: 8
                    y: 12
                    height: 100
                    fillMode: Image.PreserveAspectFit
                    source: "squid.png"
                }

            }

        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            icon.name: "window-close"
            text: qsTr("Close")
            hoverEnabled: true
            onClicked: about.close();
        }
    }

}
