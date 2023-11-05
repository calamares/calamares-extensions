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
    property var screen: "welcome"
    property var screenPrevious: []
    property var titles: {
        "welcome": null, /* titlebar disabled */
        "install_target": "Installation target",
        "install_target_confirm": "Warning",
        "user_pass": "User password",
        "ssh_confirm": "SSH server",
        "ssh_credentials": "SSH credentials",
        "fs_selection": "Root filesystem",
        "fde_confirm": "Full disk encryption",
        "fde_pass": "Full disk encryption",
        "install_confirm": "Ready to install",
        "wait": null
    }
    property var features: [
        {"name": "welcome",
         "screens": ["welcome"]},
        {"name": "installTarget",
         "screens": ["install_target", "install_target_confirm"]},
        {"name": "userPassword",
         "screens": ["user_pass"]},
        {"name": "sshd",
         "screens": ["ssh_confirm", "ssh_credentials"]},
        {"name": "fsType",
         "screens": ["fs_selection"]},
        {"name": "fde",
         "screens": ["fde_confirm", "fde_pass"]},
        {"name": "installConfirm",
         "screens": ["install_confirm", "wait"]}
    ]
    property var featureIdByScreen: (function() {
        /* Put "features" above into an index of screen name -> feature id:
         * featureIdByScreen = {"welcome": 0, "user_pass": 1, ...} */
        var ret = {};
        for (var i=0; i<features.length; i++) {
            for (var j=0; j<features[i]["screens"].length; j++) {
                ret[ features[i]["screens"][j] ] = i;
            }
        }
        return ret;
    }())
    /* Only allow characters, that can be typed in with osk-sdl
     * (src/keyboard.cpp). Details in big comment in validatePassword(). */
     property var allowed_chars:
        /* layer 0 */ "abcdefghijklmnopqrstuvwxyz" +
        /* layer 1 */ "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
        /* layer 2 */ "1234567890" + "@#$%&-_+()" + ",\"':;!?" +
        /* layer 3 */ "~`|·√πτ÷×¶" + "©®£€¥^°*{}" + "\\/<>=[]" +
        /* bottom row */ " ."

    Item {
        id: appContainer
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: inputPanel.top
        Item {
            width: parent.width
            height: parent.height

            Rectangle {
                id: mobileNavigation
                width: parent.width
                height: 30
                color: "#e6e4e1"
                Layout.fillWidth: true

                border.width: 1
                border.color: "#a7a7a7"

                anchors.left: parent.left
                anchors.right: parent.right

                RowLayout {
                    width: parent.width
                    height: parent.height
                    spacing: 6

                    Button {
                        Layout.leftMargin: 6
                        id: mobileBack
                        text: "<"

                        background: Rectangle {
                            implicitWidth: 10
                            implicitHeight: 7
                            border.color: "#c1bab5"
                            border.width: 1
                            radius: 4
                            color: mobileBack.down ? "#dbdbdb" : "#f2f2f2"
                        }

                        onClicked: navBack()
                    }
                    Rectangle {
                        implicitHeight: 10
                        Layout.fillWidth: true
                        color: "#e6e4e1"

                        Text {
                            id: mobileTitle
                            text: ""
                            color: "#303638"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    Rectangle {
                        color: "#e6e4e1"
                        Layout.rightMargin: 6
                        implicitWidth: 32
                        implicitHeight: 30
                        id: filler
                    }
                }
            }

            Loader {
                id: load
                anchors.left: parent.left
                anchors.top: mobileNavigation.bottom
                anchors.right: parent.right
            }
        }
    }
    InputPanel {
        id: inputPanel
        y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
        visible: config.builtinVirtualKeyboard
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Timer {
        id: timer
    }

    function skipFeatureInstallTarget() {
        return config.targetDeviceRootInternal == "";
    }

    /* Navigation related */
    function navTo(name, historyPush=true) {
        console.log("Navigating to screen: " + name);
        if (historyPush)
            screenPrevious.push(screen);
        screen = name;
        load.source = name + ".qml";
        mobileNavigation.visible = (titles[name] !== null);
        mobileTitle.text = "<b>" + titles[name] + "</b>";
        Qt.inputMethod.hide();
    }
    function navFinish() {
        /* Show a waiting screen and wait a second (so it can render). The big
         * comment in Config.cpp::runPartitionJobThenLeave() explains why this
         * is necessary. */
        navTo("wait");
        timer.interval = 1000;
        timer.repeat = false;
        timer.triggered.connect(function() {
            /* Trigger Config.cpp::runPartitionJobThenLeave(). (We could expose
             * the function directly with qmlRegisterSingletonType somehow, but
             * I haven't seen existing Calamares code do that with the Config
             * object, so just use the side effect of setting the variable, as
             * done in existing code of Calamares modules.) */
            config.runPartitionJobThenLeave = 1
        });
        timer.start();
    }
    function navNextFeature() {
        var id;

        /* Skip disabled features */
        for (id = featureIdByScreen[screen] + 1; id < features.length; id++) {
            /* First letter uppercase */
            var name = features[id]["name"];
            var nameUp = name.charAt(0).toUpperCase() + name.slice(1);

            /* Check config.Feature<Name> */
            var configOption = "feature" + nameUp;
            if (config[configOption] === false) {
                console.log("Skipping feature (disabled in config): " + name);
                continue;
            }

            /* Check skipFeature<Name>() */
            var funcName = "skipFeature" + nameUp;
            if (eval("typeof " + funcName) === "function"
                && eval(funcName + "()")) {
                console.log("Skipping feature (skip function): " + name);
                continue;
            }

            break;
        }

        console.log("Navigating to feature: " + features[id]["name"]);
        return navTo(features[id]["screens"][0]);
    }
    function navNext() {
        var featureId = featureIdByScreen[screen];
        var featureScreens = features[featureId]["screens"];
        for (var i = 0; i<featureScreens.length; i++) {
            /* Seek ahead until i is current screen */
            if (featureScreens[i] != screen)
                continue;

            /* Navigate to next screen in same feature */
            if (i + 1 < featureScreens.length) {
                var screenNext = featureScreens[i + 1];
                return navTo(screenNext);
            }

            /* Screen is last in feature */
            return navNextFeature();
        }
        console.log("ERROR: navNext() failed for screen: " + screen);
    }
    function navBack() {
        if (screenPrevious.length)
            return navTo(screenPrevious.pop(), false);
        ViewManager.back();
    }
    function onActivate() {
        navTo(screen, false);
    }

    /* Input validation: show/clear failures */
    function validationFailure(errorText, message="") {
        errorText.text = message;
        errorText.visible = true;
        return false;
    }
    function validationFailureClear(errorText) {
        errorText.text = "";
        errorText.visible = false;
        return true;
    }

    /* Input validation: user-screens (fde_pass, user_pass, ssh_credentials) */
    function validatePin(userPin, userPinRepeat, errorText) {
        var pin = userPin.text;
        var repeat = userPinRepeat.text;

        if (pin == "")
            return validationFailure(errorText);

        if (!pin.match(/^[0-9]*$/))
            return validationFailure(errorText,
                                     "Only digits are allowed.");

        if (pin.length < 5)
            return validationFailure(errorText,
                                     "Too short: needs at least 5 digits.");

        if (repeat == "")
            return validationFailure(errorText);

        if (repeat != pin)
            return validationFailure(errorText,
                                     "The PINs don't match.");

        return validationFailureClear(errorText);
    }
    function validateUsername(username, errorText, extraReservedUsernames = []) {
        var name = username.text;
        var reserved = config.reservedUsernames.concat(extraReservedUsernames);

        /* Validate characters */
        for (var i = 0; i < name.length; i++) {
            if (i) {
                if (!name[i].match(/^[a-z0-9_-]$/))
                    return validationFailure(errorText,
                                             "Characters must be lowercase" +
                                             " letters, numbers,<br>" +
                                             " underscores or minus signs.");
            } else {
                if (!name[i].match(/^[a-z_]$/))
                    return validationFailure(errorText,
                                             "First character must be a" +
                                             " lowercase letter or an" +
                                             " underscore.");
            }
        }

        /* Validate against reserved usernames */
        for (var i = 0; i < reserved.length; i++) {
            if (name == reserved[i])
                return validationFailure(errorText, "Username '" +
                                                    reserved[i] +
                                                    "' is reserved.");
        }

        /* Passed */
        return validationFailureClear(errorText);
    }

    function validateSshdUsername(username, errorText) {
        return validateUsername(username, errorText, [config.username]);
    }
    function validateSshdPassword(password, passwordRepeat, errorText) {
        var pass = password.text;
        var repeat = passwordRepeat.text;

        if (pass == "")
            return validationFailure(errorText);

        if (pass.length < 6)
            return validationFailure(errorText,
                                     "Too short: needs at least 6" +
                                     " digits/characters.");

        if (repeat == "")
            return validationFailure(errorText);

        if (pass != repeat)
            return validationFailure(errorText, "Passwords don't match.");

        return validationFailureClear(errorText);
    }
    function check_chars(input) {
        for (var i = 0; i < input.length; i++) {
            if (allowed_chars.indexOf(input[i]) == -1)
                return false;
        }
        return true;
    }
    function allowed_chars_multiline() {
        /* return allowed_chars split across multiple lines */
        var step = 20;
        var ret = "";
        for (var i = 0; i < allowed_chars.length + step; i += step)
            ret += allowed_chars.slice(i, i + step) + "\n";
        return ret.trim();
    }
    function validatePassword(password, passwordRepeat, errorText) {
        var pass = password.text;
        var repeat = passwordRepeat.text;

        if (pass == "")
            return validationFailure(errorText);

        /* This function gets called for the FDE password and for the user
         * password. As of writing, all distributions shipping the mobile
         * module are using osk-sdl to type in the FDE password after the
         * installation, and another keyboard after booting up, to type in the
         * user password. The osk-sdl password has the same keys as
         * squeekboard's default layout, and other keyboards should be able to
         * type these characters in as well. For now, verify that the password
         * only contains characters that can be typed in by osk-sdl. If you
         * need this to be more sophisticated, feel free to submit patches to
         * make this more configurable. */
        if (!check_chars(pass))
            return validationFailure(errorText,
                                     "The password must only contain" +
                                     " these characters, others can possibly" +
                                     " not be typed in after installation:\n" +
                                     "\n" +
                                     allowed_chars_multiline());

        if (pass.length < 6)
            return validationFailure(errorText,
                                     "Too short: needs at least 6" +
                                     " digits/characters.");

        if (repeat == "")
            return validationFailure(errorText);

        if (pass != repeat)
            return validationFailure(errorText, "Passwords don't match.");

        return validationFailureClear(errorText);
    }
}
