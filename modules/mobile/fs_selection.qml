/* SPDX-FileCopyrightText: 2020 Undef <calamares@undef.tools>
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

        text: "Select the filesystem for root partition. If unsure, leave the default."

        width: 200
    }

    ComboBox {
        id: fsTypeCB
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: mainText.bottom
        anchors.topMargin: 10
        width: 150
        height: 30
        editable: false
        model: config.fsList
        /* Save the current state on selection so it is there when the back button is pressed */
        onActivated: config.fsType = fsTypeCB.currentText;
        Component.onCompleted: fsTypeCB.currentIndex = find( config.fsType, Qt.MatchContains );
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: fsTypeCB.bottom
        anchors.topMargin: 10
        width: 200

        text: qsTr("Continue")
        onClicked: {
            config.fsType = fsTypeCB.currentText;
            navNextFeature();
        }
    }
}
