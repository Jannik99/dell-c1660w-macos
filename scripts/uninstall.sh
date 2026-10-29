#!/bin/bash
# Removes the filter and the PPD. Print queues that use them are removed first.
set -euo pipefail
PPD="/Library/Printers/PPDs/Contents/Resources/Dell C1660w HBPLv1.ppd"
for q in $(lpstat -v 2>/dev/null | awk '{print $3}' | tr -d ':'); do
    if grep -q 'rastertohbpl1' "/etc/cups/ppd/$q.ppd" 2>/dev/null; then
        echo "Removing queue $q"; sudo lpadmin -x "$q"
    fi
done
sudo rm -f "$PPD"
sudo rm -rf /Library/Printers/HBPLv1
sudo pkgutil --forget io.github.hbpl1-macos.driver >/dev/null 2>&1 || true
echo "Removed."
