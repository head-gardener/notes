# Readup

- [Fedora's series on btrfs by Andreas Hartmann](https://fedoramagazine.org/author/hartan/).
- [Archived and obsolet sysadmin's guide to btrfs](https://archive.kernel.org/oldwiki/btrfs.wiki.kernel.org/index.php/SysadminGuide.html#Layout).
- [Blog post on working with btrfs by Josphat Mutai with many examples](https://computingforgeeks.com/working-with-btrfs-filesystem-in-linux/).
- [btrfs rtd](https://btrfs.readthedocs.io/en/latest/index.html).
- [NixOS wiki entry on using btrfs with NixOS](https://nixos.wiki/wiki/Btrfs).

# General

good.

## COW

moo.


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
-  `compression` - subvol compression. See [Compression](#compression).

## Nested vs. flat

There are several basic schemas to layout subvolumes (and snapshots).

All subvols are children of root and later mounted into appropriate directories.
      E.g. you can create all your subvolumes in `/subvolumes` - a directory, with parent `root`, and use `/snapshots` - directory, - for snapshots.Flat


Subvols are located anywhere in file hierarchy - typically in their desired locations.Nested

Comparison:
- **management**: easier with flat, because layout is directyl visible and explicit.
- **mounting**: with flat all subvolumes need to be mounted separately, with nested no explicit mounting is needed.
- **mount** options: with flat options don't propagate from fs and need to be specified separately, but also can be modified per subvolume. With nested options propagate from fs.
-  **visibility**: ?
- **snapshots**: neither way will or include nested subvols in snapshots, so care should be taken. See [snapshots](#snapshots).

## Subvolume ID's

Displayed by `doas btrfs subvolume list <path>`.
  Start at 256 and increase by 1 for every new subvol. FS root always has subvol name `/` and id 5. When a btrfs partition is mounted without an explicit subvolume, `subvolid=5` is assumed.
  `list` shows top level id, most often it's 5 - root.

## Snapshots

Snapshots are a diff vcs on a fs level.

See [COW](#cow) for how this is possible.
  Subvol snapshot won't contain children - so with subvols `/` and `/home` snapshoting `/` won't copy `/home`.
  Snapshots are created with `btrfs subvolume snapshot <opts> <from> <to>`.
  Benefit of snapshots over simple copying is COW - small changes to files will cause small changes to diks usage. This can be verified with `compsize`.Snapshot is a subvolume with added content: it holds references to current and/or past versions of files (inodes).


## Backups

Storing snapshots on a single fs is convenient but not really secure - fs failure will cascade to snapshots. Remedying this requries efficiently exchanging information about snapshots between btrfs (or between btrfs and non-btrfs) file systems.
To **back up** a subvolume
- **create** a ro snapshot with `btrfs subvolume snapshot -r <subvol> <snapshot>`.
- **transfer** it with `btrfs send <snapshot> | btrfs receive <dest>`
- for **non-btrfs** destinations you can store snapshots in files - `btrfs send -f <snapshot>.btrfs <snapshot>`.
  To utilize shared nodes between sent snapshots
- send **incremental stream** with `btrfs send -p <parent> <snapshot>`.
  To **restore** a subvolume from a snapshot
- **receive** the snapshot with `btrfs send <snapshot> | btrfs receive <dest>`,
- **recreate** a rw subvol from a snapshot with `btrfs subvolume snapshot <snapshot> <subvol>`.

## Compression

Can only be applied on a **filesystem-wide** level.
  blah blah.
