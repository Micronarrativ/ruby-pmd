pdfmd/tags/author

# Document
* The *author* is defined as the creator of the document, not necessary of the file.
* You get an invoice from you power distributor: there's the value for author field right there.

# Examples

* Invoice from somebody : That somebody is the author
* Receipt for buy from a store: The store is the author

# Affects
## Filename
* The value of the author metatag is part of the filename. Based on the value of this field, the string for the filename is built up.

## Sorting directory
* When sorting documents into a destination, the author value is evaluated in order to create a subdirectory.
* Spaces and special characters are being replaced. The author is converted to lowercase characters.

# Exif
* The corresponding metatag field in a pdf document is: *author*

