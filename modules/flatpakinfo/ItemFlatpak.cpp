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
    QString line;
    auto process = CalamaresUtils::System::instance()->targetEnvCommand(
        QStringList { QString::fromStdString( "flatpak" ),
                      QString::fromStdString( "list" ),
                      QString::fromStdString( "--app" ),
                      QString::fromStdString( "--columns=application" ) } );
    auto outputStr = process.second;
    QTextStream output( &outputStr );

    while ( output.readLineInto( &line ) )
    {
        installed.append( line );
    }
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

    for ( auto names : installed )
    {
        if ( names == CalamaresUtils::getString( itemMap, "appstream" ) )
        {
            item.setInstalled( true );
        }
    }

    return item;
}
