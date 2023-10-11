/* === This file is part of Calamares - <https://calamares.io> ===
 *
 *   SPDX-FileCopyrightText: 2023 Sławomir Lach <slawek@lach.art.pl>
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Calamares is Free Software: see the License-Identifier above.
 *
 */

/* Qt */
#include <QVariantMap>

/* CPP */
#include <fstream>
#include <iostream>

/* Calamares */
#include "utils/CalamaresUtilsSystem.h"

/* Module */
#include "ItemFlatpak.h"
#include "utils/Logger.h"
#include "utils/Variant.h"

QStringList installed;
bool installedFilled;

static void
fillInstalled()
{
    long long int prev_pos;
    long long int pos = 0;
    QString line;
    auto process = CalamaresUtils::System::instance()->targetEnvCommand(
        QStringList { QString::fromLatin1( "flatpak" ),
                      QString::fromLatin1( "list" ),
                      QString::fromLatin1( "--app" ),
                      QString::fromLatin1( "--columns=application" ) } );
    auto outputStr = process.second;

    do {
        prev_pos = pos;

        pos = outputStr.indexOf('\n', prev_pos);
        QString line = outputStr.mid(prev_pos, pos);
        installed.append(line);

        /* Increase by 1 to not stuck on newline */
        ++pos;

    /* QString::indexOf returns -1 since no occurences. 0 = -1 + 1.*/
    } while (0 != pos);

    installedFilled = true;
}

void
ItemFlatpakFreeMem( void )
{
    installed.clear();
    installedFilled = false;
}

PackageItem
fromFlatpak( const QVariantMap& itemMap )
{
    if ( false == installedFilled )
    {
        fillInstalled();
    }
    // check if it is installed
    PackageItem item( CalamaresUtils::getString( itemMap, "appstream" ) );
    item.setInstalled( false );

    item.setInstalled( installed.contains( CalamaresUtils::getString( itemMap, "appstream" ) ) );

    return item;
}
