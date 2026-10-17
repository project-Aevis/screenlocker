/*
 * Copyright (C) 2021 CutefishOS Team.
 * Copyright (C) 2026 Project Aevis Contributors.
 *
 * Author:     Reion Wong <aj@cutefishos.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import Qt5Compat.GraphicalEffects
import FishUI 1.0 as FishUI
import Cutefish.Media 1.0

Item {
    id: control

    property bool available: mprisManager.availableServices.length > 0
    property bool isPlaying: currentService && mprisManager.playbackStatus === Mpris.Playing
    property alias currentService: mprisManager.currentService
    property var artUrlTag: Mpris.metadataToString(Mpris.ArtUrl)
    property var titleTag: Mpris.metadataToString(Mpris.Title)
    property var artistTag: Mpris.metadataToString(Mpris.Artist)

    MprisManager {
        id: mprisManager

        onCurrentServiceChanged: {
            control.updateInfo()
        }

        onMetadataChanged: {
            control.updateInfo()
        }
    }

    Component.onCompleted: { control.updateInfo() }

    function updateInfo() {
        var titleAvailable = (titleTag in mprisManager.metadata) ? mprisManager.metadata[titleTag].toString() !== "" : false
        var artistAvailable = (artistTag in mprisManager.metadata) ? mprisManager.metadata[artistTag].toString() !== "" : false

        control.visible = titleAvailable || artistAvailable
        _songLabel.text = titleAvailable ? mprisManager.metadata[titleTag].toString() : ""
        _artistLabel.text = artistAvailable ? mprisManager.metadata[artistTag].toString() : ""
        artImage.source = (artUrlTag in mprisManager.metadata) ? mprisManager.metadata[artUrlTag].toString() : ""
    }

    Rectangle {
        anchors.fill: parent
        radius: FishUI.Theme.bigRadius + 2
        color: FishUI.Theme.darkMode ? "#424242" : "white"
        opacity: 0.5
    }

    RowLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.margins: FishUI.Units.largeSpacing
        spacing: FishUI.Units.largeSpacing

        Rectangle {
            id: artMask
            width: _mainLayout.height
            height: width
            radius: FishUI.Theme.smallRadius
            visible: false
        }

        Image {
            id: defaultImage
            width: _mainLayout.height
            height: width
            source: "qrc:/images/media-cover.svg"
            sourceSize: Qt.size(width, height)
            visible: !artImage.visible

            layer.enabled: defaultImage.visible
            layer.smooth: true
            layer.effect: OpacityMask {
                maskSource: artMask
            }
        }

        Image {
            id: artImage
            Layout.preferredHeight: _mainLayout.height
            Layout.preferredWidth: _mainLayout.height
            visible: status === Image.Ready
            sourceSize: Qt.size(Math.max(64, Math.ceil(_mainLayout.height * FishUI.Dpi.ratio)), Math.max(64, Math.ceil(_mainLayout.height * FishUI.Dpi.ratio)))
            asynchronous: true
            fillMode: Image.PreserveAspectFit

            layer.enabled: artImage.visible
            layer.smooth: true
            layer.effect: OpacityMask {
                maskSource: artMask
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent

                Item {
                    Layout.fillHeight: true
                }

                Label {
                    id: _songLabel
                    Layout.fillWidth: true
                    visible: _songLabel.text !== ""
                    elide: Text.ElideRight
                }

                Label {
                    id: _artistLabel
                    Layout.fillWidth: true
                    visible: _artistLabel.text !== ""
                    elide: Text.ElideRight
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

        Item {
            id: _buttons
            Layout.fillHeight: true
            Layout.preferredWidth: _buttonsLayout.implicitWidth

            RowLayout {
                id: _buttonsLayout
                anchors.fill: parent
                spacing: FishUI.Units.smallSpacing

                IconButton {
                    width: 30
                    height: 30
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark" : "light") + "/media-skip-backward-symbolic.svg"
                    onLeftButtonClicked: {
                        if (mprisManager.canGoPrevious) {
                            mprisManager.previous()
                        } else if (control.available) {
                            mprisManager.setPosition(0)
                        }
                    }
                    visible: true
                    enabled: mprisManager.canGoPrevious || control.available
                    opacity: enabled ? 1.0 : 0.35
                    Layout.alignment: Qt.AlignRight
                }

                IconButton {
                    width: 30
                    height: 30
                    source: control.isPlaying ? "qrc:/images/" + (FishUI.Theme.darkMode ? "dark" : "light") + "/media-playback-pause-symbolic.svg"
                                              : "qrc:/images/" + (FishUI.Theme.darkMode ? "dark" : "light") + "/media-playback-start-symbolic.svg"
                    Layout.alignment: Qt.AlignRight
                    visible: true
                    enabled: true
                    opacity: 1.0
                    onLeftButtonClicked: {
                        if (control.available) {
                            mprisManager.playPause()
                        }
                    }
                }

                IconButton {
                    width: 30
                    height: 30
                    source: "qrc:/images/" + (FishUI.Theme.darkMode ? "dark" : "light") + "/media-skip-forward-symbolic.svg"
                    Layout.alignment: Qt.AlignRight
                    visible: true
                    enabled: mprisManager.canGoNext || control.available
                    opacity: enabled ? 1.0 : 0.35
                    onLeftButtonClicked: if (mprisManager.canGoNext) mprisManager.next()
                }
            }
        }
    }
}
