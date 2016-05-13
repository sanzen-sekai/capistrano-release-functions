#!/bin/bash

release_utility_release(){
  local is_major
  local is_patch
  local is_beta
  local is_force
  local last
  local version
  local confirm
  local release_commit
  local release_prefix
  local release_version_prefix
  local release_branch
  local release_command

  release_command=$1; shift

  while getopts fbmph OPT; do
    case $OPT in
      m)
        is_major=1
        ;;
      p)
        is_patch=1
        ;;
      b)
        is_beta=1
        ;;
      f)
        is_force=1
        ;;
      h)
        release_usage
        exit 1
        ;;
    esac
  done

  release_commit=$(git log -1 --format="%H")
  release_utility_check_status

  release_prefix
  release_version_prefix="release:${release_prefix}version-"
  last=$(git log --format="%s" --grep="$release_version_prefix" | head -1)
  last=${last#$release_version_prefix}
  release_utility_next_version

  release_branch=$(git symbolic-ref --short HEAD)

  echo "branch:  $release_branch"
  echo "version: $version"
  read -p "OK? [y/n] " confirm
  case "$confirm" in
    y*)
      echo "version: $version release start..."
      release_prepare
      git commit --allow-empty -m "$release_version_prefix$version"
      git push origin $release_branch
      release_main
      ;;
    *)
      echo "abort"
      exit 1
      ;;
  esac
}
release_usage(){
  echo "usage: ./release.sh [-m] [-p] [-b] [-f]"
}
release_prefix(){
  : # release_prefix=PREFIX
}
release_prepare(){
  : # prepare
}
release_main(){
  echo "override release_main function"
}
release_utility_check_status(){
  if [ -z "$(git log --remotes="origin" --format="%H" | grep $release_commit)" ]; then
    echo "ローカルの HEAD ($release_commit) が origin に push されていません"
    exit 1
  fi

  if [ -n "$(git status --short)" ]; then
    if [ -z "$is_force" ]; then
      echo "commit されていない変更が残っています"
      echo "もしこのままリリースしてしまいたいなら -f を指定してください"
      exit 1
    fi
  fi
}
release_utility_next_version(){
  local major
  local minor
  local patch
  local tip

  if [ -z "$last" ]; then
    if [ -n "$is_major" ]; then
      major=1
    else
      if [ -n "$is_patch" ]; then
        major=0
        minor=0
        patch=1
      else
        if [ -n "$is_beta" ]; then
          major=0
          minor=999
          patch=1
        else
          major=0
          minor=1
        fi
      fi
    fi
  else
    major=${last%%.*}

    if [ -n "$is_major" ]; then
      major=$(( $major+1 ))
      minor=
      patch=
      tip=
    else
      case "$last" in
        *.*)
          tip=${last#*.}
          ;;
        *)
          tip=
          ;;
      esac
      case "$tip" in
        *.*)
          minor=${tip%%.*}
          tip=${tip#*.}
          case "$tip" in
            *.*)
              patch=${tip%%.*}
              tip=${tip#*.}
              ;;
            *)
              patch=$tip
              tip=
              ;;
          esac
          ;;
        *)
          minor=$tip
          tip=
          ;;
      esac

      if [ -n "$is_beta" ]; then
        minor=999

        if [ -z "$patch" ]; then
          patch=1
        else
          patch=$(( $patch+1 ))
        fi
      else
        if [ -n "$is_patch" ]; then
          if [ -z "$patch" ]; then
            patch=1
          else
            patch=$(( $patch+1 ))
          fi
        else
          patch=
          if [ -z "$minor" ]; then
            minor=1
          else
            minor=$(( $minor+1 ))
          fi
        fi
      fi
    fi
  fi

  if [ "$minor" = 1000 ]; then
    major=$(( $major+1 ))
    minor=
    patch=
    tip=
  fi

  version=$major
  if [ -n "$minor" ]; then
    version=$version.$minor
  fi
  if [ -n "$patch" ]; then
    version=$version.$patch
  fi
  if [ -n "$tip" ]; then
    version=$version.$tip
  fi
}
