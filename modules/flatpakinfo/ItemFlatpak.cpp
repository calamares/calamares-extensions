#include <sys/wait.h>
#include <unistd.h>
#include <QVariantMap>

#include <ext/stdio_filebuf.h>
#include <fstream>
#include <iostream>

#include "utils/Logger.h"
#include "utils/Variant.h"
#include "ItemFlatpak.h"

QStringList installed;
bool installedFilled;

static void fill_installed()
{
    int pid_;
    int pipefd_[2];
    bool poolOk = false;

    pipe(pipefd_);

    pid_ = fork();
    if (0 == pid_)
    {
      close(pipefd_[0]);
      dup2(pipefd_[1], 1);

      execlp("flatpak", "flatpak", "list", "--app", "--columns=application", NULL);
      exit(1);
    }
    close(pipefd_[1]);

    std::string line;
    __gnu_cxx::stdio_filebuf<char> filebuf(pipefd_[0], std::ios::in);
    std::istream stream(&filebuf);

    while (!stream.eof())
    {
      getline(stream, line);
      installed.append(QString::fromStdString(line));
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

   for (auto names: installed)
   {
      if (names == CalamaresUtils::getString( item_map, "appstream" ))
      {
        item.setInstalled(true);
      }
      else
      {
        item.setInstalled(false);
      }
   }

   return item;
}
