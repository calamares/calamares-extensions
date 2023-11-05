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
    id: fdeWait

    Item {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
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
            id: waitText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: logo.bottom
            anchors.topMargin: 50
            wrapMode: Text.WordWrap
            text: "Formatting and mounting target partition. This may" +
                  " take up to ten minutes, please be patient."
            width: 200
        }
    }
}
