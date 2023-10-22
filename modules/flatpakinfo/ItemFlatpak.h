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
        : m_appstreamid( appstreamid )
        , m_installed( false )
    {
    }
    QString getAppStreamId( ) const { return m_appstreamid; }
    void setInstalled( bool installed )  { m_installed = installed; }
    bool getInstalled( ) const { return m_installed; }

private:
    QString m_appstreamid;
    bool m_installed;
};


PackageItem fromFlatpak( const QVariantMap& map );
void ItemFlatpakFreeMem( void );
void fillInstalled();
#endif
