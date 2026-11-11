# Multi-light

Flashlight app for [Ubuntu Touch](https://ubports.com) with blink mode, SOS signal and screen light.

- On/off with one big button
- Blink mode: 1–8 flashes per second
- SOS signal in Morse code (··· ––– ···)
- Screen light: full white screen, tap to close
- Keeps the screen awake while the light is on

The light is switched through the camera ("video light" flash mode, QtMultimedia), so the app only
needs the `camera` and `keep-display-on` permissions. No pictures or video are taken.

Languages: English, Danish. Translations are welcome (see below).

## Build

Needs [clickable](https://clickable-ut.dev) (`pipx install clickable-ut`) with Docker or Podman.

```
clickable build          # -> build/all/app/multilight.henrik68_<version>_all.click
```

`build-click.sh` does the same from a copy in `~/ut-apps` (for project paths with spaces) and
updates the translations first.

Framework `ubuntu-sdk-20.04` (installs on Ubuntu Touch 20.04 and 24.04), architecture `all` (pure QML).

## Translations

Texts use `i18n.tr()`; the translation domain is the app name `multilight.henrik68`.

- Template: `po/multilight.henrik68.pot`, translations: `po/<language>.po`
- New language: `msginit -i po/multilight.henrik68.pot -l de -o po/de.po`, translate, then
  `bash update-translations.sh` (updates the template, merges new texts, builds `share/locale/.../*.mo`)
- Missing languages or texts are shown in English.

## License

Copyright (C) 2026 Henrik Christiansen. GNU General Public License v3 – see [LICENSE](LICENSE).
