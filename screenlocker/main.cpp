/*
 * Copyright (C) 2021 CutefishOS Team.
 * Copyright (C) 2026 Project Aevis Contributors.
 *
 * Author:     Reion Wong <reionwong@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "application.h"
#include <QDBusConnection>
#include <QFile>
#include <QTranslator>
#include <QLocale>
#include <QPixmapCache>
#include <QTimer>

#ifdef __GLIBC__
#include <malloc.h>
#endif

int main(int argc, char *argv[])
{
#ifdef __GLIBC__
    mallopt(M_ARENA_MAX, 1);
    mallopt(M_TRIM_THRESHOLD, 64 * 1024);
    mallopt(M_MMAP_THRESHOLD, 32 * 1024);
#endif

    if (!QFile::exists(QStringLiteral("/dev/nvidia0")) &&
        QFile::exists(QStringLiteral("/usr/share/glvnd/egl_vendor.d/50_mesa.json"))) {
        qputenv("__EGL_VENDOR_LIBRARY_FILENAMES", "/usr/share/glvnd/egl_vendor.d/50_mesa.json");
    }

    Application app(argc, argv);
    app.setApplicationName(QStringLiteral("aevis-screenlocker"));
    app.setDesktopFileName(QStringLiteral("aevis-screenlocker"));
    app.setOrganizationName(QStringLiteral("aevis"));
    QPixmapCache::setCacheLimit(2048);

    QTimer::singleShot(2000, []() {
#ifdef __GLIBC__
        malloc_trim(0);
#endif
    });

    QTimer *trimTimer = new QTimer(&app);
    trimTimer->setInterval(45000);
    QObject::connect(trimTimer, &QTimer::timeout, []() {
#ifdef __GLIBC__
        malloc_trim(0);
#endif
    });
    trimTimer->start();

    QDBusConnection bus = QDBusConnection::sessionBus();
    bus.registerService(QStringLiteral("org.aevis.ScreenLocker"));
    bus.registerService(QStringLiteral("com.cutefish.ScreenLocker"));

    if (!bus.registerObject(QStringLiteral("/ScreenLocker"), &app)) {
        return -1;
    }

    // Translations
    QLocale locale;
    QString qmFilePath = QStringLiteral("/usr/share/aevis-screenlocker/translations/%1.qm").arg(locale.name());
    if (!QFile::exists(qmFilePath)) {
        qmFilePath = QStringLiteral("/usr/share/cutefish-screenlocker/translations/%1.qm").arg(locale.name());
    }

    if (QFile::exists(qmFilePath)) {
        QTranslator *translator = new QTranslator(app.instance());
        if (translator->load(qmFilePath)) {
            app.installTranslator(translator);
        } else {
            translator->deleteLater();
        }
    }

    app.setQuitOnLastWindowClosed(false);
    app.initialViewSetup();
    return app.exec();
}
