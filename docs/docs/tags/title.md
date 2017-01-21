pdfmd/tags/title

# Document
* The *title* describes the general type of the document.
* Can be chosen freely. Some titles are treated special when assigning the filename.

# Examples
* Invoice
* Manual
* Contract
* Order

# Affects
## Filename
* One part of the generated filename is created from the metatag field *title*. When the title matches one of the defined abbreviations, the following is going to happen:

  1. The title part of the filename is being replaced with the assigned abbreviation.
  2. The value of the subject is directly added to the abbreviation string in the filename.

## Exif
* The *title* is stored in the metatag *title* within the exif information of a PDF document.
