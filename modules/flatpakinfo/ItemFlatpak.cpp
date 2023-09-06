#include <sys/wait.h>
#include <unistd.h>
#include <QVariantMap>

#include <ext/stdio_filebuf.h>
#include <fstream>
#include <iostream>

#include "utils/Logger.h"
#include "utils/Variant.h"
#include "ItemFlatpak.h"

#include "utils/CalamaresUtilsSystem.h"

QStringList installed;
bool installedFilled;

static void fill_installed()
{
    int pid_;
    int pipefd_[2];
    bool poolOk = false;

    QString line;
    auto process = CalamaresUtils::System::instance()->targetEnvCommand( QStringList { QString::fromStdString( "flatpak" ), QString::fromStdString( "list" ), QString::fromStdString("--app"), QString::fromStdString( "--columns=application" ) });
    auto output_str = process.second;
    QTextStream output(&output_str);

    while (output.readLineInto(&line))
    {
      installed.append(line);
    }
    installedFilled = true;
}

void ItemFlatpak_freeMem(void)
{
  installed.clear();
  installedFilled = false;
}

PackageItem
fromFlatpak( const QVariantMap& item_map )
{
   if (false == installedFilled) {
     fill_installed();
   }
   // check if it is installed
   PackageItem item(CalamaresUtils::getString( item_map, "appstream" ));
   item.setInstalled(false);

   for (auto names: installed)
   {
      if (names == CalamaresUtils::getString( item_map, "appstream" ))
      {
        item.setInstalled(true);
      }
   }

   return item;
}
