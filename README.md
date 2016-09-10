# release functions

utility functions for release

## Requirements

* https://github.com/sanzen-sekai/version-functions

## Usage

```bash
# release.sh
. release-functions.sh
release_main "$@"
```

```bash
./release.sh <stage> [major|minor|patch|beta|exact] [version]
```

or specify stage in release.sh

```bash
# release.sh
. release-functions.sh
stage=production
release_main "$@"
```

```bash
./release.sh [major|minor|patch|beta|exact] [version]
```

## Installation

```bash
clone https://github.com/sanzen-sekai/release-functions.git
PATH=$PATH:/path/to/release-functions/bin
```

## Options

```bash
# release.sh
. release-functions.sh

release_pre(){
  # pre release
  # if you want cancel, return non-zero value
  echo $version # => release version
}
release_post(){
  # post release
  # if release failed, this function not execute
  echo $version # => release version
}
release_deploy(){
  bundle exec cap $stage deploy RELEASE_TAG=$release_commit
}

release_main "$@"
```
