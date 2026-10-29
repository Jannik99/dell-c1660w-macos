#!/bin/bash
# Builds a universal (arm64 + x86_64) filter and an installer package.
# Needs the Xcode command line tools (xcode-select --install). No sudo.
#
# The package is assembled with cpio/mkbom rather than pkgbuild: pkgbuild turns
# extended attributes into "._" files inside the payload, and one of them would
# end up beside the PPD in the driver list.
set -euo pipefail
cd "$(dirname "$0")"
VERSION=${VERSION:-1.1.0}
ID=io.github.hbpl1-macos.driver
OUT="build/HBPLv1-Driver-C1660w-$VERSION.pkg"
ROOT=build/root
FILTER_DIR="$ROOT/Library/Printers/HBPLv1/Filter"
PPD_DIR="$ROOT/Library/Printers/PPDs/Contents/Resources"
PKG=build/pkg

rm -rf build && mkdir -p "$FILTER_DIR" "$PPD_DIR" "$PKG"
clang -O2 -Wall -Wno-deprecated-declarations -mmacosx-version-min=11.0 \
    -arch arm64 -arch x86_64 -o "$FILTER_DIR/rastertohbpl1" src/rastertohbpl1.c -lcups
install -m 644 "ppd/Dell C1660w HBPLv1.ppd" "$PPD_DIR/"
install -m 644 LICENSE "$ROOT/Library/Printers/HBPLv1/LICENSE"
install -m 755 scripts/uninstall.sh "$ROOT/Library/Printers/HBPLv1/uninstall.sh"
chmod 755 "$FILTER_DIR/rastertohbpl1"

# Payload (gzip'd cpio, owner root:wheel) and bill of materials
(cd "$ROOT" && find . -print | cpio -o --format odc --owner 0:0 2>/dev/null | gzip -9) > "$PKG/Payload"
mkbom "$ROOT" "$PKG/Bom"   # owners are set again by scripts/postinstall
mkdir "$PKG/Scripts" && install -m 755 scripts/postinstall "$PKG/Scripts/postinstall"   # flatten packs this directory itself
FILES=$(find "$ROOT" | wc -l | tr -d ' ')
KB=$(du -sk "$ROOT" | cut -f1)
cat > "$PKG/PackageInfo" <<XML
<?xml version="1.0" encoding="utf-8"?>
<pkg-info format-version="2" identifier="$ID" version="$VERSION" install-location="/" auth="root">
    <payload numberOfFiles="$FILES" installKBytes="$KB"/>
    <bom path="./Bom" auth="root"/>
    <scripts>
        <postinstall file="./postinstall"/>
    </scripts>
</pkg-info>
XML
pkgutil --flatten "$PKG" build/driver.pkg
cat > build/distribution.xml <<XML
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
    <title>Dell C1660w HBPLv1 driver</title>
    <license file="LICENSE" mime-type="text/plain"/>
    <options customize="never" require-scripts="false" hostArchitectures="x86_64,arm64"/>
    <choices-outline><line choice="driver"/></choices-outline>
    <choice id="driver" title="Dell C1660w HBPLv1 driver" visible="false">
        <pkg-ref id="$ID"/>
    </choice>
    <pkg-ref id="$ID" version="$VERSION" installKBytes="$KB">#driver.pkg</pkg-ref>
</installer-gui-script>
XML
mkdir build/resources && cp LICENSE build/resources/LICENSE
productbuild --distribution build/distribution.xml --resources build/resources \
    --package-path build "$OUT"

lipo -info "$FILTER_DIR/rastertohbpl1"
echo "Fertig: $OUT"
