# Version 2.5.0
- Adding stat export formats.
- Bugfix, Abbreviations in keywords are not replaced anymore.
- Bugfix, Files in the destination directory are now ignored while sorting and 
  not used in the author-collision calculation any more.
- Buxfix, Sorting now also works with directories as input.
- Command 'stat': Added parameter to disable the percentage output.
- Bugfix, Removing output of debugging and empty lines.
- Changing edit separation sign from ':' to '='.

# Version 2.4.2
- Bugfix, overwriting hiera settings with commandline parameters were not working.

# Version 2.4.1
- Bugfix, Setup of bash_completion did not find the source file.

# Version 2.4.0
- Adding new parameter: init.
- Setup of bash_completion-file.

# Version 2.3.5
- Bugfix, Setting the date manually ('pdfmd edit -t date:xxxxxxx') updated the wrong meta field.

# Version 2.3.4
- Fixing skipping of uppercase extension documents

# Version 2.3.2
- Fixing automatic close of the pdf viewer.

# Version 2.3.1
- Fixing log typos.
- Fixing Issue #4, 'Input files with spaces in filename'.
- Suppressing errors from the PDF viewer.
- Setting old document date when no date is provided by user.

# Version 2.3.0
- Adding hiera parameter 'dest_create' to command `sort`.

# Version 2.2.0
- Adding parameter 'typo' to command `sort`.

# Version 2.1.6
- Modified command `sort` to also support shell file extension.

# Version 2.1.5
- Bugfix: #3, Kommata in Subject field showing up in the filename, Removing double underscore

# Version 2.1.4
- Bugfix: #2, trailing underscore in Author tag

# Version 2.1.3
- Bugfix: #1, Hyphen in Author tag

# Version 2.1.2
- Bugfix: Removed double occurence of '__' in keywords.

# Version 2.1.1
- Bugfix: Renaming and Keyword Check

# Version 2.1.0
- Added command 'clean' to delete values for Metatags
- Added multiple file support for commands 'clean', 'edit', 'rename', 'show'
- Bugfix: Renaming
- Bugfix: Sorting
- Added abort when renaming a file with incomplete metadata.

# Version 2.0.0
- Rewritten the gem using classes.
- Shorter Code (optimizing)
- Introduced a log-level in hiera
- Set default log-file to current working directory.
- Command 'rename': Parameter 'keywords' changed to 'nrkeywords'.
- Command 'rename': Checking if filename is unchanged and avoiding error message from system now.
- Command 'edit': Order of input values when changing all tags has been changed.
- Command 'edit': Replaced Tag separator '=' with ':'. See `pdfmd help edit` for details.
- Command 'sort': Added parameter 'overwrite'. See `pdfmd help sort` for details.
- Command 'edit': Added Hiera parameter 'opendoc' and 'pdfviewer'.
- Command 'stat': Added command to show some primitive statistics for a directory.
- Defaults for the Thor commands have mostly changed. No defaults there anymore, but in the class itself.
- Longer help texts take out into separate files for more structured code.
- Changed multiple log messages in all commands.
- Added parameter '-r' which shows the revision of the gem.
- Bug: Renaming files with a '/' in the metadatafield 'author'.
- Bug: Renaming files with spaces in the metadatafield 'subject'.
- Collected Todos in `TODO.mkd`.

# Version 1.9.1
- Removed some inactive Code

# Version 1.9.0
- Added explain 'hiera-keys'
- Added parameter to command 'config'
- Added single file sort support for command 'sort'
- Bugfix: Fixed to run commands without Hiera.
- Bugfix: Logfile parameter was not correctly recognized when renaming.
- Bugfix: Renaming dry-run ran into an error in developement mode.
- Key-abbreviations are now configureable from Hiera.
- Keywords matching the document type will now be listed first in the document name if the subject is meaningful.
- Simplyfied the renaming command code.
- Updated Documentation
- Updated Tests

# Version 1.8.0
- Added Support for password protected pdf files in command 'show' and 'edit'
- Cleaned up renaming key-string and added all string for NO,EN an DE language.
- Cleaned the output of `pdfmd config`.
- Removed some TODOs
- Bugfix in the rename command
- Updated Tests
- Removed special characters in subject when used in the filename (bug)

# Version 1.7.0
- Rename option in command 'edit' on the Shell now overwrites the hiera setting.
- The command 'show' supports multiple output formats.
- Added hiera support for parameter 'format' and 'tag' for the command 'show'.
- Added parameter 'includepdf' with Hiera for command 'show'.

# Version 1.6.3
- Added hiera option 'rename' for command 'edit'

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
