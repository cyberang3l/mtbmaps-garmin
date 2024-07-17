#!/usr/bin/env python3

import argparse
import io
import sys
from dataclasses import dataclass
from typing import NamedTuple


class MapInfo(NamedTuple):
    name: str
    desc: str


@dataclass
class InfoOffset:
    start: int
    end: int

    @property
    def len(self) -> int:
        return self.end - self.start


# https://wiki.openstreetmap.org/wiki/OSM_Map_On_Garmin#What_if_I_have_an_existing_gmapsupp.img_file?
NAME_OFFSET = InfoOffset(start=0x49, end=0x5c)
DESC_OFFSET = InfoOffset(start=0x65, end=0x82)


class Once(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        if hasattr(self, 'seen'):
            raise argparse.ArgumentError(self, 'only one allowed')
        setattr(self, 'seen', True)
        setattr(namespace, self.dest, values)


parser = argparse.ArgumentParser(
    prog='rename-garmin-img-map.py',
    description='Renaming the map name that is visible in the map selection menu in your Garmin device', formatter_class=argparse.RawTextHelpFormatter)

parser.add_argument('-i', '--info', dest='info', action='store_true',
                    help='Shows the current Garmin img map name')
parser.add_argument('-n', '--name', dest='name', type=str, action=Once,
                    help=("The new name to set on the Garmin img map - Max length is\n"
                          f"{NAME_OFFSET.len} ASCII characters"))
parser.add_argument('-d', '--description', dest='desc', type=str, action=Once,
                    help=("An optional map description that goes in addition to the\n"
                          f"map name - Max length is {DESC_OFFSET.len} ASCII characters"))
parser.add_argument('mapfile', metavar='gmapsupp.img', nargs=1, type=argparse.FileType(mode='r+b'),
                    help=("Path to gmapsupp.img(Garmin IMG map) file to view info\n"
                          "for or rename"))


def read_current_info(f: io.BufferedReader) -> MapInfo:
    # Discard first chars up to the point where the name starts
    f.read(NAME_OFFSET.start)
    # Read the name
    name = f.read(NAME_OFFSET.len)
    # Discard chars up to the point where the description starts
    f.read(DESC_OFFSET.start - NAME_OFFSET.end)
    # Read the description
    desc = f.read(DESC_OFFSET.len)
    return MapInfo(name.decode(), desc.decode())


def get_ascii_bytes(string: str) -> bytes:
    try:
        encoded_string = string.encode('ascii')
        return encoded_string
    except UnicodeEncodeError:
        print(f"Not a valid ASCII string: {string}\n", file=sys.stderr)
        raise


def _set_bytes_in_binary(f: io.BufferedReader, string: str, offset: InfoOffset):
    encoded_str = get_ascii_bytes(string)
    str_len = len(encoded_str)
    if str_len > offset.len:
        raise ValueError(
            f"Map name '{encoded_str}' cannot be longer than {offset.len} characters")

    f.seek(offset.start)
    f.write(encoded_str)
    diff = offset.len - str_len
    if diff > 0:
        f.write(b'\x20' * diff)


def set_map_name(f: io.BufferedReader, new_name: str):
    _set_bytes_in_binary(f, new_name, NAME_OFFSET)


def set_map_desc(f: io.BufferedReader, new_desc: str):
    _set_bytes_in_binary(f, new_desc, DESC_OFFSET)


def main() -> int:
    # If no args provided, show help message
    if len(sys.argv) == 1:
        sys.argv.append('--help')
    args = parser.parse_args()

    mapfile_stream = args.mapfile[0]

    if args.info or args.desc is None and args.name is None:
        info = read_current_info(mapfile_stream)
        print(f"   Map name: {info.name}\n"
              f"Description: {info.desc}"),
        return 0

    if mapfile_stream.name == "<stdin>":
        raise ValueError("Cannot use stdin to change map properties")

    if args.name is not None:
        set_map_name(mapfile_stream, args.name)

    if args.desc is not None:
        set_map_desc(mapfile_stream, args.desc)


if __name__ == "__main__":
    exit(main())
