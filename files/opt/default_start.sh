#!/bin/bash

RemoveBannedMods () {

  [ ! -f "${MC_HOME}/server/banned_mods" ] && return
  for mod in `cat ${MC_HOME}/server/banned_mods`; do
    rm ${MC_HOME}/server/mods/${mod} -v
  done

}

MinecraftServer () {
  Status "Starting Minecraft server..."
  cd ${MC_HOME}/server

  # Environment to be passed to Evacuate
  export MC_SIO # fifo for server i/o
  export MC_PID # server process id
  trap Evacuate HUP INT TERM

  MC_SIO="${MC_HOME}/server/server_fifo"
  mkfifo "${MC_SIO}"
  java -Xms${MINECRAFT_MINHEAP} -Xmx${MINECRAFT_MAXHEAP} ${FML_CONFIRM} -jar ${JARFILE} ${JAVA_OPTS} <> "${MC_SIO}" &
  MC_PID=$!
  Status "Minecraft PID: ${MC_PID}"
  wait
  rm -rf ${MC_SIO}

  Status "Server has shut down."
}

Evacuate () {
  Status "Stopping Minecraft..."
  echo "stop" >> "${MC_SIO}"
  wait ${MC_PID}
  Status "Minecraft has stopped."
}

Status () {
  # Log messages to syslog so they are visible in Console.app
  logger -t Minecraft "$@"
}

die () {
  Status $*
  exit 1
}

JARFILE="$1"
[ -z ${JARFILE} ] && JARFILE="${MC_HOME}/server/forge-${MINECRAFT_VERSION}-${FORGE_VERSION}-${MINECRAFT_VERSION}-universal.jar"
[ -e ${JARFILE} ] || die "No JAR file provided"

if [ ! -z "${FML_CONFIRM}" ]; then
  FML_CONFIRM="-Dfml.queryResult=${FML_CONFIRM}"
else
  FML_CONFIRM=""
fi

RemoveBannedMods

MinecraftServer
