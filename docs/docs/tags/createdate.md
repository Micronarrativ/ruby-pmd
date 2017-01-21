pdfmd/tags/createdate

# Document 
* The tag *createdate* refers to the date and time of a document when it has been created.
* If there is a date on the document, that is probably the value for *createdate*. It is not the date at which the file gets modified.

# Examples
* Invoice from somebody with an invoicedate: that is the *createdate*.
* Receipt from buying from a store: the receipt date is the *createdate*.

# Affects
## Filename
* The value of the createdate metatag is part of the filename. Based on the value of this field, the beginning of the filename string is build up.
* The createdate is taken from the metadata field, all non-digit characters removed and a consecutive string of 8 digits build that represents the date when the document has been created.
* The createdate can contain an accurate time as well, but this is not used in the filename.

# Exif
* The metatag field *Create Date* contains the value that is modified and used for the naming of the file.
* The *Create Date* is separated by colons within the exifdata, but those are stripped away under processing.
