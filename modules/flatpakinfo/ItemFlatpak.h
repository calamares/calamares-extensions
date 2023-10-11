/* === This file is part of Calamares - <https://calamares.io> ===
 *
 *   SPDX-FileCopyrightText: 2023 Sławomir Lach <slawek@lach.art.pl>
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Calamares is Free Software: see the License-Identifier above.
 *
 */

#ifndef ITEMFLATPAK_H
#define ITEMFLATPAK_H

#include <QString>
#include <QVariant>
#include <QVector>

class PackageItem
{
public:
    PackageItem( QString appstreamid )
        : appstreamid( appstreamid )
        , installed( false )
    {
    }
    QString getAppStreamId( ) const { return appstreamid; }
    void setInstalled( bool installed )  { this->installed = installed; }
    bool getInstalled( ) const { return installed; }

private:
    QString appstreamid;
    bool installed;
};


PackageItem fromFlatpak( const QVariantMap& map );
void ItemFlatpak_freeMem( void );

#endif
