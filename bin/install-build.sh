#!/usr/bin/env bash
#
# Install package dependencies.  Only necessary on a machine not previously configured for MARTe2
#
# Original repository : https://github.com/AdamVStephen/MARTe2-sigtools

#set -x
# Guard against unset variable expansion
set -u
SCRIPT="$0"
SCRIPT_DIR="$(dirname "$(realpath "$SCRIPT")")"
SETENV_SCRIPT_PATH="$SCRIPT_DIR/setenv.sh"

if [ -f "$SETENV_SCRIPT_PATH" ]
then
  # shellcheck disable=SC1090 # path is being constructed known correct
  source "$SETENV_SCRIPT_PATH"
else
  echo "$SETENV_SCRIPT_PATH not found.  Bailing out"
  exit 54
fi

# Placate shell-check and ensure env is as expected.
export MARTe2_PROJECT_ROOT=${MARTe2_PROJECT_ROOT:-/fatalerror}
if [ ! -d "${MARTe2_PROJECT_ROOT}" ]
then
	echo "Non existent MARTe2_PROJECT_ROOT : bail"
	exit 54
fi

# Import common shell functions
# shellcheck disable=SC1090 # path is being constructed known correct
source "${SCRIPT_DIR}/utils.sh"

# Look up tables of known good combinations of branches and OS versions
#

export DEFAULT_CORE_SHA="develop"

declare -A core_branch=( 
	["centos7"]="99c7d76af4" 
	["debian11"]="" 
	["ubuntu18.04"]="" 
	["ubuntu20.04"]="" 
)

export DEFAULT_COMPONENTS_SHA="develop"

declare -A components_branch=( 
	["centos7"]="00a08ac"  
	["ubuntu18.04"]="" 
	["ubuntu20.04"]="" 
	["debian11"]="" 
)

export DEFAULT_DEMOS_SHA="develop"

declare -A demos_branch=( 
	["centos7"]="ayr"  
	["ubuntu18.04"]="ayr" 
	["ubuntu20.04"]="ayr" 
	["debian11"]="ayr" 
	)

build_marte() {
  core_sha=$1
  components_sha=$2
  demos_sha=$3
  #echo "build marte for $core_sha and $components_sha"
  cd "${MARTe2_PROJECT_ROOT}"/MARTe2-dev && git checkout "$core_sha" && make -f Makefile.linux 2>&1 | tee "build.$core_sha.$(date +%s).log"
  cd "${MARTe2_PROJECT_ROOT}"/MARTe2-components && git checkout "$components_sha" && make -f Makefile.linux 2>&1 | tee "build.$components_sha.$(date +%s).log"
  #cd "${MARTe2_PROJECT_ROOT}/MARTe2-demos-sigtools" && git checkout "$demos_sha" && make -f Makefile.linux 2>&1 | tee "build.$demos_sha.$(date +%s).log"
  cd "${MARTe2_PROJECT_ROOT}/"MARTe2-demos-sigtools && git checkout "$demos_sha" 2>&1 | tee "build.$demos_sha.$(date +%s).log"

  # Build demos-padova manually pending resolving optional MDSPLUS support
  #cd ${MARTe2_PROJECT_ROOT}/MARTe2-demos-padova && make -f Makefile.x86-linux 2>&1 | tee "build.$(date +%s)log"
  #cd ${MARTe2_PROJECT_ROOT}/MARTe2-demos-padova && make -f Makefile.x86-linux 2>&1 | tee "build.$(date +%s)log"
}

usage() {
  echo "$SCRIPT [core sha] [components sha]"
  exit 54 
}

#echo "Called with $# arguments"
this_distro=$(get_distro)
#echo "This distro is $this_distro"


case $# in
  0) echo "Defaults null"
	export CORE_SHA=${core_branch[$this_distro]:=$DEFAULT_CORE_SHA}
	export COMPONENTS_SHA=${components_branch[$this_distro]:=$DEFAULT_COMPONENTS_SHA}
	export DEMOS_SHA=${demos_branch[$this_distro]:=$DEFAULT_DEMOS_SHA}
  ;;
  1) echo "Defaults core sha"
	export CORE_SHA=$1
	export COMPONENTS_SHA=${components_branch[$this_distro]:=$DEFAULT_COMPONENTS_SHA}
	export DEMOS_SHA=${demos_branch[$this_distro]:=$DEFAULT_DEMOS_SHA}
  ;;
  2) echo "core and components sha"
	export CORE_SHA=$1
	export COMPONENTS_SHA=$2
	export DEMOS_SHA=${demos_branch[$this_distro]:=$DEFAULT_DEMOS_SHA}
  ;;
  3) echo "core and components sha"
	export CORE_SHA=$1
	export COMPONENTS_SHA=$2
	export DEMOS_SHA=$3
  ;;
  **) echo "Defaults non-null"
	usage
  ;;
esac

build_marte "$CORE_SHA" "$COMPONENTS_SHA" "$DEMOS_SHA"

exit 0
