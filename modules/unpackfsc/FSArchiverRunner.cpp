/* === This file is part of Calamares - <https://calamares.io> ===
 *
 *   SPDX-FileCopyrightText: 2021 Adriaan de Groot <groot@kde.org>
 *   SPDX-License-Identifier: GPL-3.0-or-later
 *
 *   Calamares is Free Software: see the License-Identifier above.
 *
 */

#include "FSArchiverRunner.h"

#include <utils/Logger.h>
#include <utils/Runner.h>

#include <QProcess>

static constexpr const int chunk_size = 137;
static const QString&
toolName()
{
    static const QString name = QStringLiteral( "fsarchiver" );
    return name;
}

void
FSArchiverRunner::fsarchiverProgress( QString line )
{
    m_since++;
    // Typical line of output is this:
    // -[00][ 99%][REGFILEM] /boot/thing
    //      5   9           ^21
    if ( m_since >= chunk_size && line.length() > 21 && line[ 5 ] == '[' && line[ 9 ] == '%' )
    {
        m_since = 0;
        double p = double( line.mid( 6, 3 ).toInt() ) / 100.0;
        const QString filename = line.mid( 22 );
        Q_EMIT progress( p, filename );
    }
}

Calamares::JobResult
FSArchiverRunner::checkPrerequisites( QString& fsarchiverExecutable ) const
{
    if ( !checkToolExists( toolName(), fsarchiverExecutable ) )
    {
        return Calamares::JobResult::internalError(
            tr( "Missing tools" ),
            tr( "The <i>%1</i> tool is not installed on the system." ).arg( toolName() ),
            Calamares::JobResult::MissingRequirements );
    }

    if ( !checkSourceExists() )
    {
        return Calamares::JobResult::internalError(
            tr( "Invalid fsarchiver configuration" ),
            tr( "The source archive <i>%1</i> does not exist." ).arg( m_source ),
            Calamares::JobResult::InvalidConfiguration );
    }
    return Calamares::JobResult::ok();
}

Calamares::JobResult
FSArchiverRunner::checkDestination( QString& destinationPath ) const
{
    destinationPath = Calamares::System::instance()->targetPath( m_destination );
    if ( destinationPath.isEmpty() )
    {
        return Calamares::JobResult::internalError(
            tr( "Invalid fsarchiver configuration" ),
            tr( "No destination could be found for <i>%1</i>." ).arg( m_destination ),
            Calamares::JobResult::InvalidConfiguration );
    }

    return Calamares::JobResult::ok();
}

Calamares::JobResult
FSArchiverDirRunner::run()
{
    QString fsarchiverExecutable;
    if ( auto res = checkPrerequisites( fsarchiverExecutable ); !res )
    {
        return res;
    }
    QString destinationPath;
    if ( auto res = checkDestination( destinationPath ); !res )
    {
        return res;
    }

    Calamares::Utils::Runner r(
        { fsarchiverExecutable, QStringLiteral( "-v" ), QStringLiteral( "restdir" ), m_source, destinationPath } );
    r.setLocation( Calamares::Utils::RunLocation::RunInHost ).enableOutputProcessing();
    connect( &r, &decltype( r )::output, this, &FSArchiverDirRunner::fsarchiverProgress );
    return r.run().explainProcess( toolName(), std::chrono::seconds( 0 ) );
}

Calamares::JobResult
FSArchiverFSRunner::run()
{
    QString fsarchiverExecutable;
    if ( auto res = checkPrerequisites( fsarchiverExecutable ); !res )
    {
        return res;
    }
    QString destinationPath;
    if ( auto res = checkDestination( destinationPath ); !res )
    {
        return res;
    }

    Calamares::Utils::Runner r(
        { fsarchiverExecutable, QStringLiteral( "-v" ), QStringLiteral( "restfs" ), m_source, destinationPath } );
    r.setLocation( Calamares::Utils::RunLocation::RunInHost ).enableOutputProcessing();
    connect( &r, &decltype( r )::output, this, &FSArchiverFSRunner::fsarchiverProgress );
    return r.run().explainProcess( toolName(), std::chrono::seconds( 0 ) );
}
