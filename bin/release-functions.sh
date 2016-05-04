#!/bin/bash

release_utility_release(){
	local is_major
	local is_patch
	local is_beta
	local last
	local version
	local confirm
	local release_commit
	local release_prefix
	local release_branch
	local release_command

	release_command=$1; shift

	while getopts bmph OPT; do
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
			h)
				echo "usage: ./build.sh [-m] [-p] [-b]"
				exit 1
				;;
		esac
	done

	release_commit=$(git log -1 --format="%H")
	release_utility_check_status

	release_prefix="release:version-"
	last=$(git log --format="%s" --grep="$release_prefix" | head -1)
	last=${last#$release_prefix}
	release_utility_next_version

	release_branch=$(git symbolic-ref --short HEAD)

	echo "branch:  $release_branch"
	echo "version: $version"
	read -p "OK? [y/n] " confirm
	case "$confirm" in
		y*)
			echo "version: $version release start..."
			git commit --allow-empty -m "$release_prefix$version"
			git push origin $release_branch
			$release_command
			;;
		*)
			echo "abort"
			exit
			;;
	esac
}
release_utility_check_status(){
	if [ -n "$(git status --short)" ]; then
		echo "commit されていない変更が残っています"
		echo "commit か stash してください"
		exit 1
	fi

	if [ -z "$(git log --remotes="origin" --format="%H" | grep $release_commit)" ]; then
		echo "ローカルの HEAD ($release_commit) が origin に push されていません"
		exit 1
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
				major=0
				minor=1
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
