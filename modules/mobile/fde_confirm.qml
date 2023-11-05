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

        text: "To protect your data in case your device gets stolen," +
              " it is recommended to enable full disk encryption.<br>" +
              "<br>" +
              "If you enable full disk encryption, you will be asked for" +
              " a password. Without this password, it is not possible to" +
              " boot your device or access any data on it. Make sure that" +
              " you don't lose this password!"

        width: 200
    }

    Button {
        id: firstButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: mainText.bottom
        anchors.topMargin: 10
        width: 200

        text: qsTr("Enable")
        onClicked: {
            config.isFdeEnabled = true;
            navNext();
        }
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: firstButton.bottom
        anchors.topMargin: 10
        width: 200

        text: qsTr("Disable")
        onClicked: {
            config.isFdeEnabled = false;
            navNextFeature();
        }
    }
}
