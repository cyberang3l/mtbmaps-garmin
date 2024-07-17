#!/bin/bash
set -eu

MAP_NAME="MTB Map Norway"
FINAL_OUT_FNAME="mtbmap-norway.img"

FORCE_FLAG=0
if [[ $# -gt 0 ]] && [[ "${1}" == "force" ]]; then
	FORCE_FLAG=1
fi

BASE_DIR="$(realpath .)"
BUILD_DIR=build
BASE_URL=https://download.geofabrik.de/europe/
MD5_FNAME=norway-latest.osm.pbf.md5
PBF_MD5_URL="${BASE_URL}"/"${MD5_FNAME}"

BASE_MKGMAP_SVN_URL=http://svn.mkgmap.org.uk/
BASE_MKGMAP_DOWNLOAD_URL=https://www.mkgmap.org.uk/download/

echo >&2 "Checking if required OSM tools are installed - if this fails, try 'apt-get install osmctools'"
set -x
# https://wiki.openstreetmap.org/wiki/Osmfilter
which osmfilter
# https://wiki.openstreetmap.org/wiki/Osmconvert#Linux
which osmconvert
# Java required for splitter/mkgmap
which java
set +x

cd "$(dirname "${0}")"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

function download_pbf() {
	echo >&2 "Downloading ${PBF_URL}"
	wget "${PBF_URL}" -O "${PBF_FNAME}"
}

function md5sum_check() {
	echo >&2 "Performing an md5 check"
	md5sum --check "${MD5_FNAME}"
}

function fetch_metadata_date() {
	echo >&2 "Fetching metadata from ${BASE_URL}"
	wget "${BASE_URL}" -O - | grep -w "${MD5_FNAME}" | grep -oP "\d\d\d\d-\d\d-\d\d"
}

function splitter_fname() {
	splitter_svn="${BASE_MKGMAP_SVN_URL}/splitter/"
	rev="$(wget "${splitter_svn}" -O - | grep -oP "title.*Revision \K\d+")"
	splitter_tar="splitter-r${rev}.tar.gz"
	echo "${splitter_tar}"
}

function download_latest_splitter() {
	splitter_tar="$(splitter_fname)"
	wget "${BASE_MKGMAP_DOWNLOAD_URL}/${splitter_tar}" -O "${splitter_tar}"
}

function mkgmap_fname() {
	mkgmap_svn="${BASE_MKGMAP_SVN_URL}/mkgmap/"
	rev="$(wget "${mkgmap_svn}" -O - | grep -oP "title.*Revision \K\d+")"
	mkgmap_tar="mkgmap-r${rev}.tar.gz"
	echo "${mkgmap_tar}"
}

function download_latest_mkgmap() {
	mkgmap_tar="$(mkgmap_fname)"
	wget "${BASE_MKGMAP_DOWNLOAD_URL}/${mkgmap_tar}" -O "${mkgmap_tar}"
}

if [[ ! -d mkgmap ]]; then
	download_latest_mkgmap
	rm -rf mkgmap >/dev/null || true
	mkdir -p mkgmap
	tar xvf "$(mkgmap_fname)" -C mkgmap --strip-components 1
fi

if [[ ! -d splitter ]]; then
	download_latest_splitter
	rm -rf splitter >/dev/null || true
	mkdir -p splitter
	tar xvf "$(splitter_fname)" -C splitter --strip-components 1
fi

wget "${PBF_MD5_URL}" -O "${MD5_FNAME}"

PBF_FNAME="$(awk '{print $2}' "${MD5_FNAME}")"
O5M_FNAME="${PBF_FNAME}.o5m"
OSM_FILTERED_FNAME="${PBF_FNAME}.osm"
O5M_FILTERED_FNAME="${PBF_FNAME}-filtered.o5m"
PBF_URL="${BASE_URL}/${PBF_FNAME}"

if [[ ! -e "${PBF_FNAME}" ]]; then
	download_pbf
elif [[ -e "${PBF_FNAME}" ]]; then
	if [[ ${FORCE_FLAG} -eq 0 ]] && [[ "$(find "${PBF_FNAME}" -mtime 7 -print)" != "" ]]; then
		echo >&2 "${PBF_FNAME} is more than 7 days old!"
		echo >&2 "Run 'make clean' and re-run this script, or run 'make force' to"
		echo >&2 "ignore this check and use the cached file to generate the map"
		exit 1
	fi
fi
md5sum_check

if [[ ! -e metadata_date ]]; then
	fetch_metadata_date >metadata_date
fi
metadata_date="$(cat metadata_date)"

# Check the the style looks OK
java -jar mkgmap/mkgmap.jar --style-file="${BASE_DIR}/mtbmaps" --list-styles
java -jar mkgmap/mkgmap.jar --style-file="${BASE_DIR}/mtbmaps" --check-styles

# Convert the pbf file to o5m format as recommended by osmfilter
# https://wiki.openstreetmap.org/wiki/Osmfilter
if [[ ! -e "${O5M_FNAME}" ]]; then
	osmconvert "${PBF_FNAME}" -o="${O5M_FNAME}"
fi

# Filter only MTB trails
# https://wiki.openstreetmap.org/wiki/No:Mountain_biking#Mest_brukte_tagger_for_terrengsykling
# As long as the mtb:scale tag exists, we keep it
if [[ ! -e "${OSM_FILTERED_FNAME}" ]]; then
	osmfilter "${O5M_FNAME}" --keep="mtb:scale=" >"${OSM_FILTERED_FNAME}"
fi

# Convert back to o5m - makes for much faster processing
if [[ ! -f "${O5M_FILTERED_FNAME}" ]]; then
	osmconvert "${OSM_FILTERED_FNAME}" -o="${O5M_FILTERED_FNAME}"
fi

function semi_cleanup() {
	# Delete files created by splitter and mkgmap
	# If you want to use the latest data, rm -rf the build folder
	# and re-run the script
	rm ./*.typ osmmap.tdb osmmap.img gmapsupp.img areas.poly areas.list densities-out.txt template.args >/dev/null 2>&1 || true
	# Delete the file that is created by splitter and looks like this: 63240001.osm.pbf
	for f in *.osm.pbf *.img; do
		if echo "${f}" | grep -P "^\d+".osm.pbf >/dev/null; then
			rm "${f}" >/dev/null 2>&1 || true
		fi
		if echo "${f}" | grep -P "^\d+".img >/dev/null; then
			rm "${f}" >/dev/null 2>&1 || true
		fi
	done
}

semi_cleanup

java -jar splitter/splitter.jar "${O5M_FILTERED_FNAME}"

# Compile the typfile
test ! -e mtbstyle.typ
java -jar mkgmap/mkgmap.jar --style-file="${BASE_DIR}/mtbmaps" "${BASE_DIR}/mtbmaps/typfile/mtbstyle.txt"
java -jar mkgmap/mkgmap.jar --style-file="${BASE_DIR}/mtbmaps" --gmapsupp -c template.args mtbstyle.typ

# Start with three spaces for better visualisation on the device
MAP_DESC="   OSM data until ${metadata_date//-/}"
echo >&2 "Map generation complete! Renaming to '${MAP_NAME}'"
echo >&2 "Setting map description to '${MAP_DESC}'"
"${BASE_DIR}/rename-garmin-img-map.py" --name "${MAP_NAME}" --description "${MAP_DESC}" gmapsupp.img

mkdir -p "${BASE_DIR}/out"

OUTPUT="${BASE_DIR}/out/${metadata_date//-/}-${FINAL_OUT_FNAME}"
echo >&2 "Moving output to ${OUTPUT}"
mv gmapsupp.img "${OUTPUT}"
