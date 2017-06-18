# ![icon](data/icon.png) Coin
## Track the Bitcoin & Ethereum currencies in dollar value.

![Screenshot](data/shot.png)

## Dependencies

Please make sure you have these dependencies first before building.

```
granite
gtk+-3.0
meson
libsoup-2.4
libjson0
```

## Building

Simply clone this repo, then:

```
$ meson build && cd build
$ mesonconf -Dprefix=/usr
$ sudo ninja install
```
