# === This file is part of Calamares - <https://calamares.io> ===
#
#   SPDX-FileCopyrightText: 2020 Adriaan de Groot <groot@kde.org>
#   SPDX-License-Identifier: BSD-2-Clause
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
