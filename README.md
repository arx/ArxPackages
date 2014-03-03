
# packaging for innoextract and Arx Libertatis

## Dependencies

* Bash
* Gentoo Crossdev prefixes and toolchains for the desired targets
* A bunch of other tools

## Run

To build version `x.y` of package `package`, run:

    $ ./package -p package -v x.y

You can also specify the git ref (commit, branch or tag) to use:

    $ ./package -p package -v x.y -c master

It is possible to build only one target package type (e.g. source):

    $ ./package -p package -v x.y -t source

To run an individual build step (e.g. source.build), use:

    $ ./package -p package -v x.y run source build

You can also directly run some of the relper scrips:

    $ ./package -p package -v x.y changelog # Add changelog entry
    $ ./package -p package -v x.y finalize  # Generate checksums and README
