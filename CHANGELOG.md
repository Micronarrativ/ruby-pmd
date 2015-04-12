# Version 1.6.2
- Invalid Byte character in Rename command

# Version 1.6.1
- Bugfix with the sorting command and the logging
- Added additional log messages for sorting.
- Removed ampersand from target directory when sorting
- Changed the parameter 'logfilepath' to 'logfile' for the command 'sort'. Now it should be identical in all commands.
- Fixed command 'explain'. That was only working from inside the git repository, but not elsewhere.
- Added installation instructions for Fedora/Ubuntu/CentOS to README.md

# Version 1.6.0
- Added command 'config'
- Added dependency 'yaml'
- Added logging to command 'rename'
- Bugfix for comand 'rename' with settings in Hiera.
- Added Batchmode for command 'edit'
- Bugfix: value '00' not longer accepted for a month in 'createdate'
- Added logging to command 'edit'
- Bugfix: Removing the ampersand (&) from authornames as well now.

# Version 1.5.0
- Added option 'dryrun' to command 'sort'.
- Added option 'logfilepath' to command 'sort'
- Added more Hiera support to command 'sort'.
- Added logfilepath to command 'sort'.
- Added logentry for the answer of the interaction with the command 'sort' (parameter -i).
- Bugfix: logic for parameters was not working correctly.
- Change: Default value for logging is not 'false'.
- Bugfix: Entry in Logfile shows now if the file is moved or copied.
- Bugfix: Error message when logging and the logfile did not exist yet. File is now created correctly when necessary.
- Added Hiera support to command 'rename'.
- Command 'rename': Changed hiera parameter 'destination' to 'outputdir'.
- Added Tests for 'sort','rename' and 'show'

# Version 1.4.3
- Bugfix: Commata in author field showed up in the filename after renaming.

# Version 1.4.2
- Only changed the Date of the Gem

# Version 1.4.1
- Bugfix: When in interactive sorting, choosing the default and 'y' did not have the same effect.
- Renamed paramter '--:all-keywords' to '--allkeywords' (rename method).
- Bugfix: Method 'rename', Renaming a file puts it in the input directory, not in the current working directory.
- Bugfix: Method 'show', Listing single tags works now.
- Moved 'explain'-text into separate files.
- Moved commands into separate files under './lib/pdfmd'.
- Bugfix: Method 'show', Paramter '-t' is now case insensitive
- Added option 'outputdir' to command 'rename'.

# Version 1.4.0
- Added Hiera support for 'sort' command to define some standards (less typing)
- Added interactive parameter to 'sort' command
- Updated documentation

# Version 1.3.2
- Moved the script to right place in the GEM (/bin)
- Readme Updated
- Moved Changelog into separate file

# Version 1.3.1
- Corrected Email address (Gemspec)
- Corrected website address (Gemspec)
- No changes to script

# Version 1.3
- Small bugfix about special characters in filenames (author).
- Bugfix for the tag 'createdate' written as 'CreateDate' which did not 
  take the date then.
- Removed inactive code.
- Added paramter 'version'

# Version 1.2
- Small bugfix with the sort function and the logfile being created.

# Version 1.1
- Added Function to sort pdf documents into a directory structure based on
  the author of the document.
- Added dependency 'pathname'
- Added dependency 'logger'
- Added dependency 'i18n'
- Added method 'sort'
- Changing a tag will now output the old value in the edit dialog.
- Updated documentation and descriptions of methods

# Version 1.0
- Added documentation in long description of the commands
- Added method "explain" for further information

# Version 0.9
- Added 'rename' option to edit metatags
- Fixed some output strings

# Version 0.x
- All other stuff
