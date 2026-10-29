# Dell C1660w driver for macOS (Apple Silicon and Intel)

Dell's own Mac driver for the C1660w contains only PowerPC, i386 and x86_64
code. On a Mac without Rosetta 2 the print job stops with
`Bad CPU type in executable` in `/var/log/cups/error_log`. This package
replaces that filter with a native one, so the printer works again without
Rosetta.

The C1660w has no PostScript and no AirPrint. It speaks HBPL version 1, and the
Mac has to produce it. The filter does that: it reads CUPS raster from macOS's
own PDF renderer and writes HBPLv1.

According to the upstream projects, the same language is spoken by the Dell
1250c, Dell C1760nw, Fuji Xerox DocuPrint CP105b / CP205 and Epson AcuLaser
C1700. Only a C1660w PPD is included here, and only the C1660w was tested.

## Status

- Converts pages to a valid HBPLv1 stream (checked with `cupsfilter`).
- Tested on macOS 27 (Apple Silicon) with a real Dell C1660w over port 9100:
  test pages were printed, directly and through a print queue using the installed package.
- Not tested on Intel Macs, on older macOS versions, or with duplex, labels or envelopes.
- Colour and grayscale are implemented; **please report** what you see on your printer.

## Install

1. Download `HBPLv1-Driver-C1660w-<version>.pkg` from the Releases page.
2. The package is **not signed** (that needs a paid Apple developer account).
   If macOS refuses to open it: right-click, *Open*, or *System Settings →
   Privacy & Security → Open Anyway*.
3. Add the printer: *System Settings → Printers & Scanners → Add Printer…*,
   tab *IP*, address of the printer, protocol *HP Jetdirect – Socket*,
   *Use: Select Software…* → **Dell C1660w HBPLv1**.

Give the printer a fixed address in your router.

## Build it yourself

```bash
xcode-select --install   # once
bash build.sh            # build/HBPLv1-Driver-C1660w-<version>.pkg
```

## Uninstall

```bash
bash /Library/Printers/HBPLv1/uninstall.sh
```

## Test without a printer

```bash
cupsfilter -p "/Library/Printers/PPDs/Contents/Resources/Dell C1660w HBPLv1.ppd" \
    -m printer/foo tests/testpage.pdf > out.hbpl
```

## Licence

GPL v2 or later, see [LICENSE](LICENSE) and [NOTICE](NOTICE). Not affiliated with Dell Inc.

---

## Kurz auf Deutsch

Dells Mac-Treiber für den C1660w enthält nur Intel- und PowerPC-Code und läuft
auf einem Mac ohne Rosetta nicht mehr. Dieses Paket bringt einen nativen Filter
mit. Installieren: Paket öffnen (nicht signiert, also Rechtsklick → Öffnen),
dann den Drucker unter *Drucker & Scanner* per IP und **HP Jetdirect – Socket**
hinzufügen und als Software **Dell C1660w HBPLv1** wählen.
