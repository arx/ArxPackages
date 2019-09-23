
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

### Pusing existing versions to new distro releases

The Open Build Service can automatically build packages for new distribution releases from the same sources once repositories for those releases have been added. For Launchpad, we need to re-upload the sources for the new Ubuntu releases.

First, update the `ubuntu_versions` array in the `config` file. Then re-run

    $ ./package -p package -v x.y

This should automatically re-run dep.prepare and deb.dispatch steps for new distro releases. Source packages, local builds and packages for existing distro releases will not be touched with this option.

Note that creating debian packages only works for the latest version as the changelog is hardcoded in the package config files in the update-version step.

### Rebuilding Launchpad packages

It's 2019 and Launchpad still does not automatically rebuild packages if dependencies are updated :/

To manually trigger a rebuild of an already released version, run

    $ ./package -p package -v x.y -r series

where series is the Ubuntu release for which you want to rebuild the package. This is not needed for OBS-based builds.
