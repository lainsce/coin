# ![icon](data/icon.png) Coin
## Track the virtual currencies in real world currency value.

![Screenshot](data/shot.png)

## Dependencies

Please make sure you have these dependencies first before building.

```
granite
gtk+-3.0
meson
libsoup2.4
libjson-glib
```

## Building

Simply clone this repo, then:

```
$ meson build && cd build
$ mesonconf -Dprefix=/usr
$ sudo ninja install
```
