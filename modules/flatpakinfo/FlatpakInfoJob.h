/* === This file is part of Calamares - <https://calamares.io> ===
 *
 *   SPDX-FileCopyrightText: 2023 Sławomir Lach <slawek@lach.art.pl>
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Calamares is Free Software: see the License-Identifier above.
 *
 */

#ifndef FLATPAKINFOJOB_H
#define FLATPAKINFOJOB_H

#include <QObject>
#include <QStringList>
#include <QVariantMap>

#include "CppJob.h"
#include "ItemFlatpak.h"

#include "utils/PluginFactory.h"

#include "DllMacro.h"

/** @brief Create zpools and zfs datasets
 *
 */
class PLUGINDLLEXPORT FlatpakInfoJob : public Calamares::CppJob
{
    Q_OBJECT

public:
    explicit FlatpakInfoJob( QObject* parent = nullptr );

    InstalledList IList;

    QString prettyName() const override;

    Calamares::JobResult exec() override;

    void setConfigurationMap( const QVariantMap& configurationMap ) override;
};

CALAMARES_PLUGIN_FACTORY_DECLARATION( FlatpakInfoJobFactory )

#endif  // ZFSJOB_H
