#!/usr/bin/env bash

DIRNAME=$(dirname "$0")/..
DIRNAME=$(cd "$DIRNAME" && pwd)
# Set DIRNAME_ESC - this is DIRNAME but with spaces that are replaced with %20
DIRNAME_ESC=${DIRNAME// /%20}
DEFAULT_DIR="$DIRNAME/server/default"

# Check for run.properties
runprops="$DIRNAME/bin/run.properties"
if [ ! -f "$runprops" ]; then
  warn "Missing run.properties; using defaults."
  runprops=""
fi

CLASSPATH="$CLASSPATH:$DIRNAME/bin/pf-consoleutils.jar"
CLASSPATH="$CLASSPATH:$DEFAULT_DIR/lib/*"
CLASSPATH="$CLASSPATH:$DIRNAME/lib/*"
CLASSPATH="$CLASSPATH:$DEFAULT_DIR/conf/"

# Setup the JVM
if [ "x$JAVA" = "x" ]; then
  if [ "x$JAVA_HOME" != "x" ]; then
    JAVA="$JAVA_HOME/bin/java"
  else
    JAVA="java"
    echo "JAVA_HOME is not set.  Unexpected results may occur."
    echo "Set JAVA_HOME to the directory of your local JDK to avoid this message."
  fi
fi

JAVA_OPTS=""
JAVA_VERSION=$("$JAVA" -version 2>&1 | grep "version" | head -n 1 | cut -d\" -f 2)
JAVA_MAJOR_VERSION=$(echo ${JAVA_VERSION/_/.} | cut -d. -f 1)
# java 17 support
if [[ $JAVA_MAJOR_VERSION -eq "17" ]]; then
  JAVA_OPTS="$JAVA_OPTS --add-opens=java.base/java.lang=ALL-UNNAMED"
  JAVA_OPTS="$JAVA_OPTS --add-opens=java.base/java.util=ALL-UNNAMED"
  JAVA_OPTS="$JAVA_OPTS --add-exports=java.base/sun.security.x509=ALL-UNNAMED"
  JAVA_OPTS="$JAVA_OPTS --add-exports=java.base/sun.security.util=ALL-UNNAMED"
  JAVA_OPTS="$JAVA_OPTS --add-exports=java.naming/com.sun.jndi.ldap=ALL-UNNAMED"
  JAVA_OPTS="$JAVA_OPTS --add-exports=java.base/sun.net.util=ALL-UNNAMED"
  JAVA_OPTS="$JAVA_OPTS --add-exports=java.base/sun.security.pkcs=ALL-UNNAMED"
  JAVA_OPTS="$JAVA_OPTS --add-exports=java.base/sun.security.pkcs10=ALL-UNNAMED"
fi

"$JAVA" \
  $JAVA_OPTS \
  -cp "$CLASSPATH" \
  -Dlog4j.configurationFile="file:///$DIRNAME_ESC/bin/clusterkey.log4j2.xml" \
  -Drun.properties="$runprops" \
  -Dpf.server.default.dir="$DEFAULT_DIR" \
  com.pingidentity.console.GenerateClusterKey "$@"
