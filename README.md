# release functions

utility functions for release

## Usage

```bash
# release.sh

. release-functions.sh

release_prepare(){
  : # pre git commit hook
}
release_main(){
  bundle exec cap <STAGE_NAME> deploy RELEASE_TAG=$release_commit
}
release_utility_release "$@"
```

```bash
./release.sh    # minor release
./release.sh -m # major release
./release.sh -p # patch release
./release.sh -b # beta release => minor 999 version's patch release
```

## Installation

```bash
clone https://github.com/sanzen-sekai/release-functions.git
PATH=$PATH:/path/to/release-functions/bin
```

## Configuration

```bash
release_prefix(){
  : # release_prefix=PREFIX
  # use in commit message : "release:${release_prefix}version-0.0.0"
}
```

```bash
release_usage(){
  # custom usage message
  echo "usage: ./release.sh [-m] [-p] [-b] [-f]"
}
```
