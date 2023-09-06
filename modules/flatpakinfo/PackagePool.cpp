
#include <ext/stdio_filebuf.h>
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


void serializePackagesInfo(void);

QVector < PackageItem > packages;

void downloadPackagesInfo(void)
{
    int pid;
    int pipefd[2];

    int pid_;
    int pipefd_[2];
    bool poolOk = false;

    pipe(pipefd_);

    pid_ = fork();
    if (0 == pid_)
    {
      close(pipefd_[0]);
      dup2(pipefd_[1], 1);

      execlp("flatpak", "flatpak", "remotes", "--columns=name", NULL);
      exit(1);
    }
    close(pipefd_[1]);

    std::string line;
    __gnu_cxx::stdio_filebuf<char> filebuf(pipefd_[0], std::ios::in);
    std::istream stream(&filebuf);

    while (!stream.eof())
    {
       getline(stream, line);

       pipe(pipefd);

       pid = fork();
       if (0 == pid)
       {
          close(pipefd[0]);
          dup2(pipefd[1], 1);
          execlp("flatpak", "flatpak", "remote-ls", "--app", "--columns=application", line.c_str(), NULL);
          exit(1);
       }
      close(pipefd[1]);

      std::string line;
      __gnu_cxx::stdio_filebuf<char> filebuf(pipefd[0], std::ios::in);
      std::istream stream(&filebuf);

      while (!stream.eof())
      {
        getline(stream, line);
        QVariantMap item_map;

        if (std::string::npos == line.find('.')) {
            continue;
        }

        //std::cerr << line;
        item_map.insert("appstream", QVariant(QString::fromStdString(line)));
        item_map.insert("id", QVariant(QString::fromStdString(line)));

        PackageItem item = fromFlatpak(item_map);
        packages.append(item);
    }
    }

    waitpid(pid, nullptr, 0);

    serializePackagesInfo();
}

void serializePackagesInfo(void)
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
               newValue.insert("selected", false);

               selfInstall.append(current.getAppStreamId());
               newValue.insert("packages", selfInstall);
               changedValue.append(newValue);
            }

            gs->remove( "netinstallAdd" );
        }
        gs->insert( "netinstallAdd", changedValue );
}
