# MTBMaps Garmin

A project to assist with autogeneration of vectorized MTB map overlays
for Garmin devices and allows for maximum map tuning. Note that this is an
overlay and you still need a base map to use it. See the
[How to use](#how-to-use) section below for more information.

The generated map overlay is inspired by [mtbmap.no](https://mtbmap.no/info),
but comes with a few differences that make the map much easier to read on a
Garmin Edge 1050, which is the only device I've used to try the map so far.

The key differences versus the mtbmap.no Garmin version are:
* The trails appear on the GPS device as much thicker lines, and are easier
  to see even on max zoom levels.
* The following colours are used for drawing the trails:
  - Easy trails: Green
  - Intermediate trails: Blue
  - Advanced trails: Red
  - Expert trails: Black
  - Extreme trails I and II: Dark pale yellow surrounded by black
  - Impossible trails: Dark pale red surrounded by black
  - All of the trail categories, with the exception of extreme and impossible
    trails, are highlighted with yellow if they are "recommended"
    trails (`class:bicycle:mtb` OSM tag values of 1 and 2)
  - All of the trail categories, with the exception of extreme and impossible
    trails, are highlighted with an orange/pink color if they are
    "highly recommended" trails (`class:bicycle:mtb` OSM tag values of 3)
  - All of the trail categories, with the exception of extreme and impossible
    trails, that are always dark pale coloured, get a pale colour (lighter
    green, lighter blue, light pink, and light shade of gray) when they are
    not recommended (`class:bicycle:mtb` OSM tag values < 0)
* Some extra features that I do not commit to them, but were nice to see
  while building this map:
  - The size of the entire Norway is 5.6MBs vs ca 18MB for the same Garmin
    map that is provided by mtbmap.no
  - For some reason (I can only speculate why), the loading and rendering
    of the overlay map built by this script is much faster than the one
    provided by mtbmap.no

# Sample screenshots

![2024-07-17-21-12-25](https://github.com/user-attachments/assets/67ae94d9-2dfe-45e5-8881-0f174b365592)
![2024-07-17-21-13-37](https://github.com/user-attachments/assets/17f43103-eb47-4409-94af-532f3898e22d)
![2024-07-17-21-14-25](https://github.com/user-attachments/assets/77425603-d0e7-4f04-b87b-e9d71128b573)
![2024-07-17-21-14-41](https://github.com/user-attachments/assets/bb01ad19-7387-4653-a74a-0bb18f924de1)


# How to use

1. (optional step if you don't have a base map) Go to http://frikart.no/garmin/velgkart.html
   and download `Topo Summer II` and install it on your device (read the
   installation manual at frikart.no)
2. Generate the MTB map overlay by running the `make` command after you clone
   this repository. If everything works, you should find a gmapsupp file named
   `YYYY-MM-DD-mtbmap-norway.img` in the `out` directory. All you need to do
   is to copy this file in the `Garmin` directory of your device.
3. Start your device, go to:
   `Menu → Settings → Activity Profiles → select profile → Navigation → Configure Maps`
4. For simplicity, disable all maps
5. Enable only the `OSM Topo Summer II` (or the base map of you choice) and
   the `MTB Map Norway` maps

# Useful map development resources:

* QMapShack to visualize the maps during the map development process:
  https://github.com/Maproom/qmapshack/releases
  - Note that the rendering on the device is surprisingly different when
    compared to the QMapShack rendering, so always load the map on
    the device to ensure it looks as it is intended to look before you "ship it"
  - When testing changes in the map style, compile with `make qmapshack`
    to get a result that resembles closer what you will see on the device
* mkgmap docs:
  - https://www.mkgmap.org.uk/doc/index.html
  - https://www.mkgmap.org.uk/doc/pdf/style-manual.pdf
  - https://www.mkgmap.org.uk/doc/typ-compiler
* Geofabrik website that contains OSM data per-country for download:
  https://download.geofabrik.de/europe.html
* OpenStreetMap wiki with information about different tags that are
  required to build the map:
  - https://wiki.openstreetmap.org/wiki/No:Mountain_biking#Mest_brukte_tagger_for_terrengsykling
  - https://wiki.openstreetmap.org/wiki/No:Mountain_biking#Utfyllende_beskrivelse_av_vanskelighetsgrad_/_mtb:scale
  - https://wiki.openstreetmap.org/wiki/No:Mountain_biking#Karteksempler
  - https://wiki.openstreetmap.org/wiki/Key:highway#Highway
* [mtbmap.no](https://mtbmap.no/info) - the map style that inspired this project
