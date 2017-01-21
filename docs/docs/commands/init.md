pdfmd/command/init

# Description

The *init* command will try to adjust the environment to support pdfmd.

At this moment only the installation of a bash completion file has been integrated.

# Usage

```
$ pdfmd init <parameter>
``` 

# Parameter

``` 
bash_completion     Installs or removes the bash_completion-file for pdfmd. An existing file will be overwritten after a file with the extension `.backup` has been created within the same directory.

-r, --remove        If set the bash completion file will be removed. This does not reinstated or remove any files created as backup.
```

# Hiera

There are no settings in hiera for this command.

# Example

```
# Install the bash completion file
$ pdfmd init bash_completion

# Remove the bash completion file
$ pdfmd init -r bash_completion
```
