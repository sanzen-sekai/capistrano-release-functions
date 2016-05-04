# release functions

utility functions for release

## Usage

```bash
# release.sh

. release-functions.sh

release_<PROJECT_NAME>(){
	RELEASE_TAG=$release_commit bundle exec cap <STAGE_NAME> deploy
}
release_utility_release release_<PROJECT_NAME> "$@"
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
