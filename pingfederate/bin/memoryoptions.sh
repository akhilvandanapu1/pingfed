#!/bin/bash
#
# Script to generate optimized memory options for PingFederate
#

set -e

if [ "x$PF_HOME" = "x" ]; then
  dn=`dirname $0`
  PF_HOME=`cd $dn/..; pwd`
fi

#Get current date and time
dt=`date "+%Y-%m-%d_%H-%M-%S-%N"`
Y=${dt:0:4}
M=${dt:5:2}
D=${dt:8:2}
H=${dt:11:2}
MN=${dt:14:2}
S=${dt:17:2}
MIL=${dt:20:3}
backupDateTime="$Y-$M-$D_$H-$MN-$S-$MIL"
generatedTime="$Y/$M/$D $H:$MN:$S:$MIL"

#Output Template
#text position is important
file=`cat << TEMPLATE_END
# Auto-generated JVM memory options for PingFederate
#
# Generated: ${generatedTime}
#
# Each non-commented and non-empty line will be added as a Java option when PingFederate is started.
# Comments can be added to this file by starting a line with the # character.
#

#Initial RAM percentage
-XX:InitialRAMPercentage=80.0
#Maximum RAM percentage
-XX:MaxRAMPercentage=80.0
#Use G1GC
-XX:+UseG1GC
TEMPLATE_END`

jvmMemoryOpts="$PF_HOME/bin/jvm-memory.options"
if [ -f "$jvmMemoryOpts" ]; then
  #Make a backup before generating a new file
  cp "$jvmMemoryOpts" "$PF_HOME/bin/jvm-memory_${backupDateTime}.options"
fi

echo "$file" > "$jvmMemoryOpts"
echo
echo "Generated new jvm-memory.options."