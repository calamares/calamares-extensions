/* === This file is part of Calamares - <https://calamares.io> ===
 *
 *   SPDX-FileCopyrightText: 2023 Sławomir Lach <slawek@lach.art.pl>
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Calamares is Free Software: see the License-Identifier above.
 */

#include <fstream>
#include <iostream>

#include <stdio.h>
#include <sys/wait.h>
#include <unistd.h>

#include <QString>
#include <QDesktopServices>
#include <QVariantMap>

#include "GlobalStorage.h"
#include "JobQueue.h"
#include "utils/Logger.h"
#include "utils/Variant.h"
#include "ItemFlatpak.h"


#include "utils/CalamaresUtilsSystem.h"

void serializePackagesInfo(void);

QVector < PackageItem > packages;

void downloadPackagesInfo(InstalledList &list)
{
    QHash<QString,bool> addedPackages;
    QString line;
    auto process = CalamaresUtils::System::instance()->targetEnvCommand( QStringList { QString::fromStdString( "flatpak" ), QString::fromStdString( "remotes" ), QString::fromStdString( "--columns=name" ) });
    auto outputStr = process.second;
    QTextStream output(&outputStr);

    while (output.readLineInto(&line))
    {
        QString line2;
        auto process2 = CalamaresUtils::System::instance()->targetEnvCommand(
            QStringList { QString::fromStdString( "flatpak" ),
                          QString::fromStdString( "remote-ls" ),
                          QString::fromStdString( "--app" ),
                          QString::fromStdString( "--columns=application" ),
                          line } );
        auto output2Str = process2.second;
        QTextStream output2( &output2Str );

        while ( output2.readLineInto( &line2 ) )
        {
            if ( line2 == "" )
            {
                continue;
            }
            QVariantMap itemMap;

            if ( addedPackages.contains( line2 ) )
            {
                continue;
            }

            addedPackages.insert( line2, true );

            itemMap.insert( "appstream", QVariant( line2 ) );
            itemMap.insert( "id", QVariant( line2 ) );

            PackageItem item = fromFlatpak( itemMap, list );
            packages.append( item );
        }
    }

    serializePackagesInfo();
}

void serializePackagesInfo()
{
        QList<QVariant> changedValue;
        auto* gs = Calamares::JobQueue::instance()->globalStorage();

        // If an earlier packagechooser instance added this data to global storage, combine them
        if ( gs->contains( "netinstallAdd" ) )
        {
            auto selectedOrig = gs->value( "netinstallAdd" );

            changedValue = selectedOrig.toList();
            for (auto current: packages)
            {
               QStringList selfInstall;
               QVariantMap newValue;
               newValue.insert("name", current.getAppStreamId());

               if (current.getInstalled())
               {
                 newValue.insert("selected", true);
                 newValue.insert("immutable", true);
                 newValue.insert("description", "[Already installed; cannot be uninstalled]");
               }
               else
               {
                 newValue.insert("selected", false);
               }
               selfInstall.append(current.getAppStreamId());
               newValue.insert("packages", selfInstall);
               changedValue.append(newValue);
            }

            gs->remove( "netinstallAdd" );
        }
        gs->insert( "netinstallAdd", changedValue );
}
