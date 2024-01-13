/* === This file is part of Calamares - <https://calamares.io> ===
 *
 *   SPDX-FileCopyrightText: 2023 Sławomir Lach <slawek@lach.art.pl>
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Calamares is Free Software: see the License-Identifier above.
 */

#ifndef ___PACKAGEPOOL__H___
#define ___PACKAGEPOOL__H___

#include "ItemFlatpak.h"

class PackagePool {
private:
    QVector < PackageItem > packages;
public:
    void downloadPackagesInfo( InstalledList& );
    void serializePackagesInfo( void );
};


#endif
