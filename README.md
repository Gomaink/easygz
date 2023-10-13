# EasyGZ

[![sampctl](https://img.shields.io/badge/sampctl-easygz_inc-2f2f2f.svg?style=for-the-badge)](https://github.com/Gomaink/easygz_inc)

A filterscript that helps you easily and dynamically create gangzones with SQLite saves.

[img]https://i.imgur.com/yH8jmFo.png[/img]

[img]https://i.imgur.com/hqDPQOv.png[/img]

[img]https://i.imgur.com/juiEAZl.png[/img]

## Installation

Simply install to your project:

```bash
sampctl package install Gomaink/easygz
```

Include in your code and begin using the library:

```pawn
#include <easygz_inc>
```

## Usage

First make sure you are using the database available in this repository, whose name is "gangzones.db".
Making sure of this, in your server.cfg in the "filterscripts" field add easygz.pwn, and then turn on gamemode.

## Commands

- /creategangzone ! Need to be logged in RCON !
- /destroygangzone <id> ! Need to be logged in RCON !

To test, simply run the package:

```bash
sampctl package run
```
