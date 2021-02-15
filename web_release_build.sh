#!/bin/sh
flutter build web --release;

rm -r build/web/icons;
rm build/web/manifest.json;
rm build/web/favicon.png;

cp -r web_b/icons build/web/icons;
cp -r web_b/manifest.json build/web/manifest.json;
cp -r web_b/favicon.png build/web/favicon.png;

