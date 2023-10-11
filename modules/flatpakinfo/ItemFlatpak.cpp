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
fill_installed()
{
    QString line;
    auto process = CalamaresUtils::System::instance()->targetEnvCommand(
        QStringList { QString::fromStdString( "flatpak" ),
                      QString::fromStdString( "list" ),
                      QString::fromStdString( "--app" ),
                      QString::fromStdString( "--columns=application" ) } );
    auto output_str = process.second;
    QTextStream output( &output_str );

    while ( output.readLineInto( &line ) )
    {
        installed.append( line );
    }
    installedFilled = true;
}

void
ItemFlatpak_freeMem( void )
{
    installed.clear();
    installedFilled = false;
}

PackageItem
fromFlatpak( const QVariantMap& item_map )
{
    if ( false == installedFilled )
    {
        fill_installed();
    }
    // check if it is installed
    PackageItem item( CalamaresUtils::getString( item_map, "appstream" ) );
    item.setInstalled( false );

    for ( auto names : installed )
    {
        if ( names == CalamaresUtils::getString( item_map, "appstream" ) )
        {
            item.setInstalled( true );
        }
    }

    return item;
}
