# General

good.


# Subvols

Like directories, but can be manipulated like file systems, have snapshots and such.
This stuff is kinda like bind mounts,

## Commands:

- `findmnt` - display info about mounts.
- `btrfs subvolume create <path>` - create a subvol.
  `path` should be non existent.
- `btrfs subvolume list <path>` - show subvols in the fs containing `path`.
    - `-o` - show subvols below `path`.
- `rm -r <vol>` or `doas btrfs subvolume delete <vol>` - delete subvol.
- `umount <subvol>` - unmount subvol after it has been mounted to a different path.
- `mount -o subvol=<path>,<opts> <drive> <path>` - mount subvol. `subvol` is how `fstab` nows where to mount what.

## Options

- `subvol` - subvol path.
- `subvolid` - subvol id.
-  `compression` - subvol compression. Can only be applied on a **filesystem-wide** level.

## Nested vs. flat

There are several basic schemas to layout subvolumes (and snapshots).

All subvols are children of root and later mounted into appropriate directories.Flat


Subvols are located anywhere in file hierarchy - typically in their desired locations.Nested



## Subvolume ID's

Displayed by `doas btrfs subvolume list <path>`.
Start at 256 and increase by 1 for every new subvol. FS root always has subvol name `/` and id 5. When a btrfs partition is mounted without an explicit subvolume, `subvolid=5` is assumed.
`list` shows top level id, most often it's 5 - root.

## Snapshots

Snapshots are ...
Subvol snapshot won't contain children - so with subvols `/` and `/home` snapshoting `/` won't copy `/home`.
