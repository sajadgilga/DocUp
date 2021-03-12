'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "962e44cc5e0655a448ca55bf111f8880",
"assets/assets/homeBack.png": "762589a307c09a07fb89410b43393914",
"assets/assets/account/brands-and-logotypes.png": "97ddf8e2f160dc05461bc6eb1dc52c33",
"assets/assets/account/brands-and-logotypes@2x.png": "72b17dff9fde5c5adf6730276affe417",
"assets/assets/account/brands-and-logotypes@3x.png": "77540d1fc6486ed76b19fb47f7635a12",
"assets/assets/account/instagram.png": "4a8c23476a7c20c5bee2a752a6f96e9e",
"assets/assets/account/logo%2520(1).png": "a97974909e3612411934fbb9d611a40f",
"assets/assets/account/logo%2520(1)@2x.png": "6aa231016d1168276a2b8d0fe5c46f2f",
"assets/assets/account/logo%2520(1)@3x.png": "6120c716eef2650d2edf828d7cd2d7f5",
"assets/assets/avatar.png": "616fcc9ddf4239162b015afc00c52364",
"assets/assets/backgroundHome.png": "08bfcb81f0f657e1d0156f4252486ec3",
"assets/assets/calendarCheck.svg": "c994d4bcac51798d03e1b47c21b47b78",
"assets/assets/capsule.svg": "1154ed34c85e11b44ce1942e00c54849",
"assets/assets/chatBox.svg": "0fbffe3cbcade0c6349c40a8aa785c58",
"assets/assets/chatSendBtn.svg": "90ff3b47a41883232fbfcebcbae7bf6b",
"assets/assets/clinicPanel.svg": "282dc1ee57d3d26e722afc89393228a8",
"assets/assets/cloud.svg": "4b7a493582c1940188ffc563694c1cbb",
"assets/assets/doctor.svg": "45713cd7e388c66f367b059ae93fbc66",
"assets/assets/doctorAvatar.svg": "3cbf920642105438b155b3c3d67814a7",
"assets/assets/docUpHomeDoctor.svg": "be4053e443b13cf85f6a23c19715ed10",
"assets/assets/docUpHomePatient.svg": "f1fc71a429ae67cb3725e0b396b35b10",
"assets/assets/down_arrow.svg": "c421cb32be929c9b7c0512d17888a26f",
"assets/assets/firstPanel.svg": "282dc1ee57d3d26e722afc89393228a8",
"assets/assets/Group%25202910.png": "82fbdc3d00a14cbde102f9e4ca190b9e",
"assets/assets/Group%25202910.svg": "15a630069aeb809b517b9a4c1cf1630d",
"assets/assets/hand1.jpg": "d0e63a993580aab07a44fbe34e4775bb",
"assets/assets/home/Layer%25202.png": "62f79544d410d847feaba0558b9ad49c",
"assets/assets/home/Layer%25202@2x.png": "96d145292da9a7d7345522e5f14d5e22",
"assets/assets/home/Layer%25202@3x.png": "999df98794297490c043c10425c17ed0",
"assets/assets/home/Layer%25202_2.png": "822d6e778cb7719e86746f81a9836954",
"assets/assets/home/Layer%25202_2@2x.png": "8085650b7e1d053aab42443a04f78223",
"assets/assets/home/Layer%25202_2@3x.png": "52589ce8ba70c20eb854b623bf2488be",
"assets/assets/home/request.png": "d8834ac42d120d775e90f23d1c7dd4de",
"assets/assets/home/request@2x.png": "629fb68c8d259da52ffb47d1c98f68c1",
"assets/assets/home/request@3x.png": "de64dd06605689a7b1bb41698d82b104",
"assets/assets/home/video-conference.png": "2b59a271d9643462536b467c4685aa10",
"assets/assets/home/video-conference@2x.png": "ff86e964ba0dba96fc4c82c8e20d453a",
"assets/assets/home/video-conference@3x.png": "8870f965df11a7422b2a9c98764ee4dc",
"assets/assets/home/video-conference_2.png": "0cb0ea3545e9b9fcb006c7bf9b11b4ce",
"assets/assets/home/video-conference_2@2x.png": "21a194193cd22e778b0f0f82c4b95b9e",
"assets/assets/home/video-conference_2@3x.png": "f1383d302436df4a6e3c6d2989134b57",
"assets/assets/img1.png": "eac5c4c5a91c62d951c86d10ede3fcc3",
"assets/assets/img2.png": "f15b6e1f5cdc2c1e57e19cebf66b194e",
"assets/assets/img3.png": "fb50a39d1a6534538f59c679687bd23a",
"assets/assets/IRANSans.ttf": "43e733e043864039bdc0fe495658ce36",
"assets/assets/lion.jpg": "4c46f4b743aa8792e6076bbbbfd15509",
"assets/assets/loading.gif": "b8a8756187ecee98032838cfa6cd0ff6",
"assets/assets/location.png": "c6ad19e4d7f2d121cd57d9dc88898d8c",
"assets/assets/logoCircle.png": "294bb0397cca6a85e51d0b97f7a4d649",
"assets/assets/logoRec.png": "8399ccf0f0880013853f2dbd13a2b117",
"assets/assets/logoTransparent.png": "2ef778d0ba524672d0a7b0ec3eeeff3f",
"assets/assets/logoTransparentNeuronio.png": "0fbbc0190ed25d341db1427537491fea",
"assets/assets/neuronio-512x512.png": "0fbbc0190ed25d341db1427537491fea",
"assets/assets/noronioClinic/brain%2520(1).png": "8025b213a60859c004cefaabf9009ac1",
"assets/assets/noronioClinic/brain%2520(1)@2x.png": "dd92741deea356ab7c8d6ed029c8e184",
"assets/assets/noronioClinic/brain%2520(1)@3x.png": "3757e7065182bd29f8ca8bba209f6c87",
"assets/assets/noronioClinic/brain.png": "64c99fac716ec617c24b42a672e7a3f4",
"assets/assets/noronioClinic/brain@2x.png": "16a3c64973baca292563beabcaf4ca1d",
"assets/assets/noronioClinic/brain@3x.png": "613648ab277d2de86c006729caa788c8",
"assets/assets/noronioClinic/cognitive.png": "14b2bd8543d466bacc4c32d21c890ccf",
"assets/assets/noronioClinic/cognitive@2x.png": "bbe184d4a3519cf4e9849abe7cad1ef2",
"assets/assets/noronioClinic/cognitive@3x.png": "c7285814222f70bbadaa84fd595289de",
"assets/assets/noronioClinic/doctor%2520(1).png": "d886e141f081bee042235eeb9168958f",
"assets/assets/noronioClinic/doctor%2520(1)@2x.png": "9ebb48cbbea8ce844efb1a052e701837",
"assets/assets/noronioClinic/doctor%2520(1)@3x.png": "117fa2f52016dc264509e7cd238fdfb7",
"assets/assets/noronioClinic/mobile-game.png": "fddb0b5138276f5c58fee3d82feeb6da",
"assets/assets/noronioClinic/mobile-game@2x.png": "1a07fc62a493795a159cc95f274f0f91",
"assets/assets/noronioClinic/mobile-game@3x.png": "4970d9db49de529e7adb14211aa81077",
"assets/assets/occasions/MothersDay.jpg": "0771acad9fa49fc50033e4f70c8b1cc6",
"assets/assets/ointment.svg": "82554fd8eca15003a63e9e8ab4a74230",
"assets/assets/onCallIcon.svg": "3cbf920642105438b155b3c3d67814a7",
"assets/assets/panel/appointment.png": "5e547583c49238d68d1e10f2f1f46873",
"assets/assets/panel/appointment@2x.png": "7fb2e61e2b261bb193c0b1ec17643353",
"assets/assets/panel/appointment@3x.png": "47aa914236aa41b65d57edf08f284866",
"assets/assets/panel/doctor.png": "b78befa250be2c2576eaabf213a0f446",
"assets/assets/panel/doctor@2x.png": "782f892a89070aa5071a6a6dd5273234",
"assets/assets/panel/doctor@3x.png": "0afe644108016274c6d90c2b4ef59449",
"assets/assets/panel/Icon%2520awesome-user-md.png": "3d398006076db723034b577aa392e137",
"assets/assets/panel/Icon%2520awesome-user-md@2x.png": "bda11922682e7b40b2aa5f3e1b1a399d",
"assets/assets/panel/Icon%2520awesome-user-md@3x.png": "779c837f24163050f8e3b7f6fb91e918",
"assets/assets/panel/patient.png": "96d4e1674103032fa9bd3b5eada9b1f3",
"assets/assets/panel/patient@2x.png": "07695e98beef297eaaa146083bbf180e",
"assets/assets/panel/patient@3x.png": "07844b4c5e069d48b00e672332fe7e42",
"assets/assets/panelIcon.svg": "b94028d10409d2150dd531161a3f31a1",
"assets/assets/panelMenu.svg": "62e52d3ed8463c488cc0ea5e682bfdbd",
"assets/assets/profileIcon.svg": "b5e71334d201d18293daedbe7b376213",
"assets/assets/search.svg": "ef3895cb8045971ec3f1d6090731a92e",
"assets/assets/servicesIcon.svg": "af2dec75bb7cbf7dc7ec9df4b8b12935",
"assets/assets/startPage/Group%25201850.png": "038f7261c743970602af95560ddd885a",
"assets/assets/startPage/Group%25201851.png": "60afd4cbdb3a42030a99dbcad35dbed7",
"assets/assets/startPage/Group%25202911.png": "4afccbad1014b404310ca95852879ed0",
"assets/assets/startPage/Group%25202912.png": "59dd40362f0c6a7b91da4729c9db2b8c",
"assets/assets/startPage/Group%25202913.png": "e33a2949ce19be99dfd2e70ac82a509f",
"assets/assets/syrup.svg": "0198528ee83cecc75824e18fdde6b0bd",
"assets/assets/team.svg": "71e4e95ca3c4dc8f78a168f40e163b4b",
"assets/assets/uploadpic.png": "2ffee82466bd0f03d32e41ea43db53d5",
"assets/assets/uploadPicTestImage.png": "7664be839f803732bdaf1390ebfa3782",
"assets/assets/visitLists/doctor.png": "fc3d69def331c2aa63452fa98fab5e5d",
"assets/assets/visitLists/doctor@2x.png": "c1f306ea6c9411f746d772101ec536ce",
"assets/assets/visitLists/doctor@3x.png": "b268ae5f47f6f52a1653a5f90b8b8327",
"assets/assets/visitLists/doctor_4@3x.png": "08420c8c9f066f5e5f3c1426c20cec93",
"assets/assets/visitLists/file@2x.png": "4ab8e8c262fd188fe373542258b20fa3",
"assets/assets/visitLists/file@3x.png": "eeb628ed85828251a48fe5af1e8bf4b5",
"assets/assets/whatsapp.svg": "be56419d11afe26fc463234cd2284d5e",
"assets/FontManifest.json": "f9a0c348a6c911705f81a97f6ba25c0b",
"assets/fonts/MaterialIcons-Regular.otf": "1288c9e28052e028aba623321f7826ac",
"assets/NOTICES": "aac7d3b2d3ecc320015fcb0f7bf2ef06",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/packages/flutter_credit_card/font/halter.ttf": "4e081134892cd40793ffe67fdc3bed4e",
"assets/packages/flutter_credit_card/icons/amex.png": "dad771da6513cec63005d2ef1271189f",
"assets/packages/flutter_credit_card/icons/discover.png": "ea70c496dfa0169f6a3e59412472d6c1",
"assets/packages/flutter_credit_card/icons/mastercard.png": "7e386dc6c169e7164bd6f88bffb733c7",
"assets/packages/flutter_credit_card/icons/visa.png": "9db6b8c16d9afbb27b29ec0596be128b",
"assets/packages/flutter_markdown/assets/logo.png": "67642a0b80f3d50277c44cde8f450e50",
"assets/packages/progress_dialog/assets/double_ring_loading_io.gif": "e5b006904226dc824fdb6b8027f7d930",
"assets/packages/wakelock_web/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"index.html": "9e668d4266c4d0eb53efe9506bb3179e",
"/": "9e668d4266c4d0eb53efe9506bb3179e",
"main.dart.js": "dcdc9a62da3e56099233601e3446d97f",
"manifest.json": "c60912e613523bd18435f26569e04e88",
"version.json": "09b6104b519cad582aa25693de0efe87"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value + '?revision=' + RESOURCES[value], {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey in Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
