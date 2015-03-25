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
