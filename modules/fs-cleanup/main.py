#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# === This file is part of Calamares - <https://github.com/calamares> ===
#
#   Calamares is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Calamares is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Calamares. If not, see <http://www.gnu.org/licenses/>.
#
#   SPDX-FileCopyrightText: 2020 Adriaan de Groot <groot@kde.org>
#   SPDX-License-Identifier: GPL-3.0-or-later
#   License-Filename: LICENSES/GPL-3.0

"""
This module install and removes packages based on which filesystems are used 
"""

import libcalamares
import subprocess

def remove_pkg(pkg):
    remove_command = libcalamares.job.configuration.get("remove_command")
    pkgs = " ".join(pkg)
    exit_code = libcalamares.utils.target_env_call(
            [check_installed_command, pkgs]          )
    if exit_code != 0:
            libcalamares.utils.warning(
                "Failed to remove unneeded packages packages"
                )
            libcalamares.utils.warning(
                "{} chroot returned error code {}".format(remove_command, ec)
                )


def is_installed(pkg):
    check_installed_command = libcalamares.job.configuration.get("check_installed_command")
    exit_code = libcalamares.utils.target_env_call(
            [check_installed_command, pkg]
            )
    if exit_code == 0:
        return True
    else:
        return False

def run():
    partitions = libcalamares.globalstorage.value("partitions")

    if not partitions:
        libcalamares.utils.warning("partitions is empty, {!s}".format(partitions))
        return (_("Configuration Error"),
                _("No partitions are defined for <pre>{!s}</pre> to use." ).format("fspackages"))

    # Get the rootfilesystem so we know which settings to apply
    for p in partitions:
        if p['mountPoint'] == '/'
            root_filesystem = p['fs']
    # read the configuration
    filesystems = libcalamares.job.configuration.get("filesystems") or []
    if not filesystems:
        libcalamares.utils.warning("No needed packages per filesystem defined. Does fs-cleanup.conf exist?")

    # Get all the packages listed in the configuration
    unneeded_packages = [ pkg for fs in filesystems.values() for pkg in fs ]
    # Remove from the list packages that are actually needed
    needed_packages = filesystems[root_filesystem] or []
    unneeded_packages = list(set(unneeded_packages) - set(needed_packages))

    # Remove packages that are unneeded
    for pkg in unneeded_packages:
        if not is_installed(pkg):
            unneeded_packages.remove(pkg)
    remove_pkg(unneeded_packages)
