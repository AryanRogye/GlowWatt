#!/bin/bash

sudo killall -9 remoted
echo "Killed remoted"
sudo killall -9 usbmuxd
echo "Killed usbmuxd"
sudo killall -9 com.apple.CoreDeviceService 2>/dev/null || true
echo "Killed com.apple.CoreDeviceService"

sudo killall -9 Xcode
echo "Killed Xcode"

rm -rf ~/Library/Developer/Xcode/DerivedData/
echo "Cleared Derived Data"
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport
echo "Cleared iOS Device Support"
rm -rf ~/Library/Developer/Xcode/watchOS\ DeviceSupport
echo "Cleared watchOS Device Support"
rm -rf ~/Library/Caches/com.apple.dt.Xcode
echo "Cleared Xcode Cache"
