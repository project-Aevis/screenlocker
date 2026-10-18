# Aevis Screen Locker

PAM-integrated secure screen locker and session lock component for the Aevis Desktop Environment.

Part of the **[Project Aevis](https://github.com/project-Aevis)** suite.

## Features

- Secure user password validation with PAM (`kcheckpass`)
- Multi-monitor screen lock with clock and notification area
- Smooth unlock animations and FishUI visual styling

## Dependencies

### Debian / Ubuntu

```shell
sudo apt install cmake gcc qt6-base-dev qt6-declarative-dev libpam0g-dev libx11-dev
```

## Build and Install

```shell
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
sudo make install
```

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3).
