#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8 spelllang=en
#===============================================================================
#
#          FILE: psae.sh
#
#   DESCRIPTION: Executes the specified Application Engine program on a remote node
#
#===============================================================================

#set -e                          # Exit immediately on error
#set -o nounset                  # Treat unset variables as an error

# TODO: figure out how to pass optional variables to the script
# TODO: re-introduce the psconfig.sh script
# TODO: clean up this mess

database_type=${1}
database_name=${2}
process_scheduler_domain=${3}
app_username=${4}
app_password=${5}
appengine_program=${6}
runcontrol_id=${7}
process_instance=${8}
debug_flag=${9}
trace=${10}
toolstracesql=${11}
toolstracepc=${12}

# TODO: eliminate unnecessary global variables
required_environment_variables=( PS_HOME PS_CFG_HOME PS_APP_HOME PS_PIA_HOME PS_CUST_HOME TUXDIR )
optional_environment_variables=( JAVA_HOME PS_FILEDIR PS_SERVDIR ORACLE_HOME ORACLE_BASE TNS_ADMIN AGENT_HOME )

function echoinfo() {
  local GC="\033[1;32m"
  local EC="\033[0m"
  printf "${GC} INFO${EC}: %s\n" "$@";
}

function echoerror() {
  local RC="\033[1;31m"
  local EC="\033[0m"
  printf "${RC} ERROR${EC}: %s\n" "$@" 1>&2;
}

function set_required_environment_variables () {
  echoinfo "Setting required environment variables"
  for var in ${required_environment_variables[@]}; do
    rd_node_var=$( printenv RD_NODE_${var} )
    export $var=$rd_node_var
  done
}

function set_optional_environment_variables () {
  echoinfo "Setting optional environment variables"
  for var in ${optional_environment_variables[@]}; do
    if [[ `printenv RD_NODE_${var}` ]]; then
      rd_node_var=RD_NODE_${var}
      export $var=$( printenv $rd_node_var )
    fi
  done
}

function set_ps_server_cfg () {
  echoinfo "Setting PS_SERVER_CFG"
  export PS_SERVER_CFG=$PS_CFG_HOME/appserv/prcs/$process_scheduler_domain/psprcs.cfg
}

function check_variables () {
  echoinfo "Checking variables"
  for var in ${required_environment_variables[@]}; do
    if [[ `printenv ${var}` = '' ]]; then
      echoerror "${var} is not set.  Please make sure this is set before continuing."
      exit 1
    fi
  done
}

function update_path () {
  echoinfo "Updating PATH"
  export PATH=$TUXDIR/bin:$PATH
  export PATH=$PS_HOME/bin:$PATH
  [[ -n $ORACLE_HOME ]] && export PATH=$ORACLE_HOME/bin:$PATH
  [[ -n $AGENT_HOME ]] && export PATH=$AGENT_HOME/bin:$PATH
}

function update_ld_library_path () {
  echoinfo "Updating LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH=$PS_HOME/verity/linux/_ilnx21/bin:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/optbin:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/bin/sqr/ORA/bin:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/bin/interfacedrivers:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/bin:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/jre/lib/amd64:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$PS_HOME/jre/lib/amd64/native_threads:$LD_LIBRARY_PATH
  export LD_LIBRARY_PATH=$TUXDIR/lib:$LD_LIBRARY_PATH
  [[ -n $JAVA_HOME ]] && export LD_LIBRARY_PATH=$JAVA_HOME/lib:$LD_LIBRARY_PATH
  [[ -n $ORACLE_HOME ]] && export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
}

function source_psconfig () {
  echoinfo "Sourcing psconfig"
  cd "$PS_HOME" && source "$PS_HOME"/psconfig.sh && cd - > /dev/null 2>&1 # Source psconfig.sh
}

function toggle_flags() {
  echoinfo "Updating flags"
  if [[ $debug_flag == 'true' ]]; then
    debug_flag='Y'
  elif [[ $debug_flag == 'false' ]]; then
    debug_flag='N'
  fi

  if [[ $toolstracesql == 'true' ]]; then
    toolstracesql='Y'
  elif [[ $toolstracesql == 'false' ]]; then
    toolstracesql='N'
  fi

  if [[ $toolstracepc == 'true' ]]; then
    toolstracepc='Y'
  elif [[ $toolstracepc == 'false' ]]; then
    toolstracepc='N'
  fi
}

function execute_appengine() {
  echoinfo "Executing AppEngine"
  psae -CT "$database_type" -CD "$database_name" -CO "$app_username" -CP "$app_password" -AI "$appengine_program" -R "$runcontrol_id" -I "$process_instance" -DEBUG "$debug_flag" -TRACE "$trace" -TOOLSTRACESQL "$toolstracesql" -TOOLSTRACEPC "$toolstracepc"
}

#######################
# Setup the environment
#######################
set_required_environment_variables
check_variables
source_psconfig
set_optional_environment_variables
update_path
update_ld_library_path
set_ps_server_cfg
toggle_flags
execute_appengine
