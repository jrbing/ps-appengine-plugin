ps-appengine-plugin
===================

A Rundeck script plugin for executing PeopleSoft Application Engine programs on a remote server.

_NOTE: this currently only works for for UNIX/LINUX_

Installation
------------

Copy the [ps-appengine-plugin.zip file][latest_release] to your `$RDECK_BASE/libext` directory and restart the Rundeck service.

    mv ps-appengine-plugin.zip $RDECK_BASE/libext

You should now have an additional "PS AppEngine" option when configuring jobs.


Configuration
-------------

The following node variables must be set in order for the plugin to work.

* PS\_HOME 
* PS\_CFG\_HOME 
* PS\_APP\_HOME 
* PS\_PIA\_HOME 
* PS\_CUST\_HOME 
* TUXDIR

Depending on your configuration, you may also need to set the following as well.

* JAVA_HOME
* COBDIR
* PS_FILEDIR
* PS_SERVDIR
* ORACLE_HOME
* ORACLE_BASE
* TNS_ADMIN
* AGENT_HOME

For example, here's how a [yaml resource file][yaml_resource_model_source] might be setup.

```yaml
hrlinuxappserver01:
  tags: 'app,web,prcs'
  osName: Linux
  osFamily: unix
  username: psoft
  osArch: amd64
  description: HRDEMO Appserver Environment
  nodename: hrlinuxappserver01
  hostname: hrlinuxappserver01
  osName: Linux
  ps_home: '/opt/psoft/pt854'
  ps_cfg_home: '/opt/psoft/pt854cfg'
  ps_app_home: '/opt/psoft/hcm92'
  ps_pia_home: '/opt/psoft/pt854cfg'
  ps_cust_home: '/opt/psoft/hcm92custom'
  tuxdir: '/opt/oracle/middleware/tuxedo12c'
  java_home: '/usr/lib/jvm/java-1.7.0'
  oracle_home: '/opt/oracle/product/12.1.0/client'
  oracle_base: '/opt/oracle'
  cobdir: '/opt/microfocus/netexpress'
  appserver_domain: hrdemo
  prcs_domain: hrdemo 
  pia_domain: hrdemo
```

Also, it should be noted that this is a Rundeck [script plugin][script_plugin_instructions] and works by passing the node variables as environment variables over SSH.  In order for the plugin to have access to the configured node variables, you'll need to make sure that the ssh server process on the target system is [configured for this][ssh_environment_variable_configuration].


Usage
-----

To use the plugin, simply select the "PS Webserver" node step type when adding a step to a workflow.  Then enter in the PIA domain that you would like to administer, and select the action you would like to perform from the drop-down list.  The actions are pretty straightforward, but here's a quick run down of what each does:

* status: Returns the status of the domain
* start: Starts the specified domain
* stop: Shuts down the specified domain
* purge: Deletes the webserver cache files
* restart: Stops the domain and then starts it
* bounce: Performs the following - stop, purge, start

[yaml_resource_model_source]: http://rundeck.org/docs/administration/managing-node-sources.html#resource-model-source
[ssh_environment_variable_configuration]: http://rundeck.org/docs/plugins-user-guide/ssh-plugins.html#passing-environment-variables-through-remote-command
[script_plugin_instructions]: http://rundeck.org/docs/developer/plugin-development.html#script-plugin-development
[environment_variable_setup]: http://rundeck.org/docs/plugins-user-guide/ssh-plugins.html#passing-environment-variables-through-remote-command
[latest_release]: https://github.com/jrbing/ps-web-plugin/releases/latest


License
-------

Copyright © 2016 JR Bing

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


Notes
-----

* env variables
* example syntax
    psae -CTdbtype -CSserver -CDdatabase_name -COoprid -CPoprpswd?
    -Rrun_control_id -AIprogram_id -Iprocess_instance -DEBUG (Y|N)?
    -DR (Y|N) -TRACEtracevalue -DBFLAGSflagsvalue -TOOLSTRACESQLvalue?
    -TOOLSTRACEPCvalue -OTouttype -OFoutformat -FPfilepath
* arguments
    -CT Specify the type of database to which you are connecting. Values are ORACLE,MICROSFT,SYBASE,INFORMIX,DB2UNIX, andDB2ODBC.
    -CS Required for Sybase and Informix. For platforms that require a server name as part of their signon, enter the appropriate server name. This option affects Sybase, Informix, and Microsoft SQL Server. However, for Microsoft SQL Server, this option is valid but not required.
    -CD Enter the name of the database to which the program will connect.
    -CO Enter the user ID of the person who is running the program.
    -CP Enter the password associated with the specified user ID.
    -R Enter the run control ID to use for this run of the program.
    -AI Specify the Application Engine program to run.
    -I Required for restart, enter the process instance for the program run. The default is 0, which means Application Engine uses the next available process instance.
    -DEBUG This parameter controls the Debug utility. Enter Y to indicate that you want the program to run in debugging mode or enterN to indicate that you do not.
    -DR This parameter controls restart disabling. Enter Y to disable restart or enterN to enable restart.
    -TRACE To enable tracing from the command line, enter this parameter and a specific trace value. The value you enter is the sum of the specific traces that you want to enable. Traces and values are:
        1: Initiates the Application Engine step trace.
        2: Initiates the Application Engine SQL trace.
        128:: Initiates the Application Engine timings file trace, which is similar to the COBOL timings trace.
        256: Includes the PeopleCode detail timings in the 128 trace.
        1024: Initiates the Application Engine timings table trace, which stores the results in database tables.
        2048: Initiates the database optimizer explain, writing the results to the trace file. This option is supported only on Oracle, Informix, and Microsoft SQL Server.
        4096: Initiates the database optimizer explain, storing the results in the Explain Plan table of the current database. This option is supported only on Oracle, DB2, and Microsoft SQL Server.
    -DBFLAGS To disable %UpdateStats meta-SQL construct, enter 1.
    -TOOLSTRACESQL Enable a SQL trace.
    -TOOLSTRACEPC Enable a PeopleCode trace.
    -OT (Optional) Initialize the PeopleCode meta-variable %OutDestType (numeric).
        PeopleCode example of %OutDestType:
        &ProcessRqst.OutDestType = %OutDestType ;
    -OF (Optional) Initialize the PeopleCode meta-variable %OutDestFormat (numeric).
        PeopleCode example of %OutDestFormat:
        Query.RunToFile(Record QryPromptRecord, %OutDestFormat);
    -FP (Optional) Initialize the PeopleCode meta-variable %FilePath (string).
        PeopleCode example of %FilePath:
