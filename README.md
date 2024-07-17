# MTBMaps Garmin

A project to assist with autogeneration of vectorized mtbmaps overlays
for Garmin devices and allows for maximum map tuning.

The generated map overlay is inspired by [mtbmap.no](https://mtbmap.no/info),
but comes with a few differences that make the map much easier to read on a
Garmin Edge 1050, which is the only device I've used to try the map so far.

The key differences are:
* This map is not plotting MTB trails in the Extreme II, Extreme II
  and Impossible categories as I never dare to cycle in such trails.
* The remaining categories (easy, intermediate, advanced, expert)
  that are plotted, appear on the GPS device as much thicker
  lines, and are easier to see even on max zoom levels.
* The following colours are used for drawing the trails:
  - Easy trails: Green
  - Intermediate trails: Blue
  - Advanced trails: Red
  - Expert trails: Black
  - All of the above are highlighted with yellow if they are "recommended"
    trails (`class:bicycle:mtb` OSM tag values of 1 and 2)
  - All of the above are highlighted with an orange/pink color if they are
    "highly recommended" trails (`class:bicycle:mtb` OSM tag values of 3)
  - All of the above get a pale colour (lighter green, lighter blue, light
    pink, and light shade of gray) when they are not recommended
    (`class:bicycle:mtb` OSM tag values < 0)
* Some extra features that I do not commit to them, but were nice to see
  while building this map:
  - The size of the entire Norway is 5.5MBs vs ca 18MB for the same Garmin
    map that is provided by mtbmap.no
  - For some reason (I can only speculate why), this loading and rendering
    much faster than the one provided by mtbmap.no

## How to use

All you should need to do is run the `build-maps.sh` script, and you should
hopefully get a gmapsupp file called `YYYY-MM-DD-mtbmap-norway-vangelis.img`
in the `out` directory. All you need to do then is to copy this file in the
`Garmin` directory of your device. You will end up with the file:
`Garmin/YYYY-MM-DD-mtbmap-norway-vangelis.img`.

## Useful map development resources:

* QMapShack to visualize the maps during the map development process:
  https://github.com/Maproom/qmapshack/releases
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
