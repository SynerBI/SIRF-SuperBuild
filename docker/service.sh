#!/usr/bin/env bash

## Usage:
# service.sh [<DEBUG_LEVEL> [<JUPYTER_PORT> [<DOWNLOAD_DATA] ] ]
#
# Arguments:
#   <DEBUG_LEVEL>   : [default: 0]
#   <JUPYTER_PORT>  : [default: 8888]
#   <DOWNLOAD_DATA> : [default: 0]
##

[ -f .bashrc ] && . .bashrc
this=$(dirname "${BASH_SOURCE[0]}")
DEBUG="${1:-0}"
JUPYTER_PORT="${2:-8888}"
DOWNLOAD_DATA="${3:-0}"

stop_service()
{
  echo "stopping jobs"
  for i in $(jobs -p); do kill -n 15 $i; done 2>/dev/null

  if [ "$DEBUG" != 0 ]; then
    if [ -f gadgetron.log ]; then
      echo "----------- Last 70 lines of gadgetron.log"
      tail -n 70 gadgetron.log
    fi
  fi

  exit 0
}

pushd $SIRF_PATH/../..

# start gadgetron
GCONFIG=./INSTALL/share/gadgetron/config/gadgetron.xml
[ -f "$GCONFIG" ] || cp "$GCONFIG".example "$GCONFIG"
[ -f ./INSTALL/bin/gadgetron ] \
  && ./INSTALL/bin/gadgetron >& gadgetron.log&

# start jupyter
if [ ! -f ~/.jupyter/jupyter_notebook_config.py ]; then
  jupyter notebook --generate-config
  echo "c.NotebookApp.password = u'sha1:cbf03843d2bb:8729d2fbec60cacf6485758752789cd9989e756c'" \
  >> ~/.jupyter/jupyter_notebook_config.py
fi

# download the SIRF-Exercises data if requested
if [ "$DOWNLOAD_DATA" != 0 ]; then
  pushd /devel
  [ -d SIRF-Exercises ] || cp -a $SIRF_PATH/../../../SIRF-Exercises .
  which unzip || sudo apt-get install -yqq unzip
  for i in SIRF-Exercises/scripts/download_*.sh; do ./$i $PWD; done
  popd
fi

# serve a master notebook
jupyter notebook --ip 0.0.0.0 --port $JUPYTER_PORT --no-browser \
  --notebook-dir /devel/ &

# serve 10 notebooks
[ -f $this/service.multi.sh ] \
  && $this/service.multi.sh 10 $[JUPYTER_PORT + 2] &

popd

trap "stop_service" SIGTERM
trap "stop_service" SIGINT
wait
