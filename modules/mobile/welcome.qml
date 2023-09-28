/* SPDX-FileCopyrightText: 2020 Oliver Smith <ollieparanoid@postmarketos.org>
 * SPDX-License-Identifier: GPL-3.0-or-later */
import io.calamares.core 1.0
import io.calamares.ui 1.0

import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import QtGraphicalEffects 1.0
import QtQuick.Window 2.3
import QtQuick.VirtualKeyboard 2.1

Page
{
    id: welcome

    Item {
        id: appContainer
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        Item {
            width: parent.width
            height: parent.height

            Image {
                id: logo
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                height: 50
                fillMode: Image.PreserveAspectFit
                source: "file:///usr/share/calamares/branding/default-mobile/logo.png"
            }
            Text {
                id: mainText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: logo.bottom
                anchors.topMargin: 10
                horizontalAlignment: Text.AlignRight
                text: "You are about to install<br>" +
                      "<b>" + config.osName +
                      " " + config.version + "</b><br>" +
                      "user interface " +
                      "<b>" + config.userInterface + "</b><br>" +
                      "architecture " +
                      "<b>" + config.arch + "</b><br>" +
                      "on your " +
                      "<b>" + config.device + "</b><br>"
                width: 200
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: mainText.bottom
                anchors.topMargin: 10
                width: 200

                text: qsTr("Continue")
                onClicked: navNext()
            }
        }
    }
}
