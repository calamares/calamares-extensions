# === This file is part of Calamares - <https://calamares.io> ===
#
#   SPDX-FileCopyrightText: 2023 Sławomir Lach <slawek@lach.art.pl>
#   SPDX-License-Identifier: GPL-3.0-or-later
#
#   Calamares is Free Software: see the License-Identifier above.
#
#
calamares_add_plugin(flatpakInfo
    TYPE job
    EXPORT_MACRO PLUGINDLLEXPORT_PRO
    SOURCES
        FlatpakInfoJob.h
        ItemFlatpak.h
        PackagePool.h
        FlatpakInfoJob.cpp
        ItemFlatpak.cpp
        PackagePool.cpp
    SHARED_LIB
)
