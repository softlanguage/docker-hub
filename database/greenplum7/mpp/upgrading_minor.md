#### Upgrading from 7.x to a Newer 7.x Release
> https://techdocs.broadcom.com/us/en/vmware-tanzu/data-solutions/tanzu-greenplum/7/greenplum-database/install_guide-upgrading_minor.html

- gp7 upgrade steps [ZYB-GP7]

```sh
# [gpadmin] stop
gpstop -M fast

# [root] install, need --allowerasing (autoremove early installed version) 
dnf install ./greenplum-db-7.3.3-el8-x86_64.rpm --allowerasing

# [gpadmin] start instance
gpstart
gpstate
```

- An upgrade from Greenplum Database 7.x to a newer 7.x release involves stopping Greenplum Database, updating the Greenplum Database software binaries, and restarting Greenplum Database. If you are using Greenplum Database extension packages there are additional requirements. See Prerequisites in the previous section.

Log in to your Greenplum Database master host as the Greenplum administrative user:

```sh
$ su - gpadmin
```

Perform a smart shutdown of your Greenplum Database 7.x system (there can be no active connections to the database). This example uses the -a option to deactivate confirmation prompts:

```sh
$ gpstop -a
```

Copy the new Greenplum Database software installation package to the gpadmin user's home directory on each coordinator, standby coordinator, and segment host.

If you used yum to install Greenplum Database to the default location, run these commands on each host to upgrade to the new software release.

```sh
$ sudo yum upgrade ./greenplum-db-<version>-<platform>.rpm
# --allowerasing will auto remove installed early version
$ sudo dnf install ./greenplum-db-7.3.3-el8-x86_64.rpm --allowerasing 
```

- The yum command installs the new Greenplum Database software files into a version-specific directory under /usr/local and updates the symbolic link /usr/local/greenplum-db to point to the new installation directory.

If you used rpm to install Greenplum Database to a non-default location, run rpm on each host to upgrade to the new software release and specify the same custom installation directory with the --prefix option. For example:

```sh
$ sudo rpm -U ./greenplum-db-<version>-<platform>.rpm --prefix=<directory>
```

- The rpm command installs the new Greenplum Database software files into a version-specific directory under the <directory> you specify, and updates the symbolic link <directory>/greenplum-db to point to the new installation directory.

Update the permissions for the new installation. For example, run this command to change the user and group of the installed files to gpadmin.

```sh
$ sudo chown -R gpadmin:gpadmin /usr/local/greenplum*
```

- If needed, update the greenplum_path.sh file on the coordinator and standby coordinator hosts for use with your specific installation. These are some examples.

- If Greenplum Database uses LDAP authentication, edit the greenplum_path.sh file to add the line:
```sh
export LDAPCONF=/etc/openldap/ldap.conf
```

- If Greenplum Database uses PL/Java, you might need to set or update the environment variables JAVA_HOME and LD_LIBRARY_PATH in greenplum_path.sh.

- When comparing the previous and new greenplum_path.sh files, be aware that installing some Greenplum Database extensions also updates the greenplum_path.sh file. The greenplum_path.sh from the previous release might contain updates that were the result of installing those extensions.

Edit the environment of the (gpadmin) user and make sure you are sourcing the greenplum_path.sh file for the new installation. For example change the following line in the .bashrc or your chosen profile file:

- source /usr/local/greenplum-db-<current_version>/greenplum_path.sh
to:

- source /usr/local/greenplum-db-<new_version>/greenplum_path.sh
Or if you are sourcing a symbolic link (/usr/local/greenplum-db) in your profile files, update the link to point to the newly installed version. For example:
```sh
$ sudo rm /usr/local/greenplum-db
$ sudo ln -s /usr/local/greenplum-db-<new_version> /usr/local/greenplum-db
# Source the environment file you just edited. For example:
$ source ~/.bashrc
# After all segment hosts have been upgraded, log in as the gpadmin user and start your Greenplum Database system:

# su - gpadmin
$ gpstart
```

- For Greenplum Database, use the gppkg utility to re-install Greenplum Database extensions. If you were previously using any Greenplum Database extensions such as PL/R, PL/Java, or PostGIS, download the corresponding packages from Broadcom Support Portal, and install using this utility. See the extension documentation for details.

- Also copy any files that are used by the extensions (such as JAR files, shared object files, and libraries) from the previous version installation directory to the new version installation directory on the master and segment host systems.

- If you configured PXF in your previous Greenplum Database installation, you will need to install PXF in your new Greenplum installation, and you may be required to re-initialize or register the PXF service after you upgrade Greenplum Database. Refer to the Step 2 PXF upgrade procedure for instructions.

- If you configured GPSS in your previous installation, you will be required to perform some upgrade actions, and you must re-restart the GPSS service instances and jobs. Refer to Step 2 of the GPSS upgrade procedure for instructions.

- After upgrading Greenplum Database, ensure that all features work as expected. For example, test that backup and restore perform as expected, and Greenplum Database features such as user-defined functions, and extensions such as MADlib and PostGIS perform as expected.