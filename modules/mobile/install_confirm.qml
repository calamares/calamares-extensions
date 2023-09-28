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

Item {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.right: parent.right
    width: parent.width
    height: parent.height

    Text {
        id: mainText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        wrapMode: Text.WordWrap

        text: (function() {
            var ret = "Once you hit 'install', the installation will begin." +
                " It will typically take a few minutes. Do not power off the" +
                " device until it is done.<br>";

            if (config.installFromExternalToInternal) {
                ret += "<b>After the installation, your device will shutdown" +
                       " automatically. You must remove the external storage" +
                       " (SD card) before booting again.</b>" +
                       "<br><br>" +
                       "Otherwise, your device will boot into the installer" +
                       " again, and not into the installed system."
            } else {
                ret += "Afterwards, it will reboot into the installed system.";
            }

            return ret;
        }())

        width: 200
    }

    Button {
        id: firstButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: mainText.bottom
        anchors.topMargin: 10
        width: 200

        text: qsTr("Install")
        onClicked: navFinish()
    }
}
