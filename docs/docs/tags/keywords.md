pdfmd/tags/keywords

# Document
* The tag *keywords* refers to any other key word that might be related to a document.
* Keywords can contain specialised tags like customernumbers, invoicenumber and other reoccuring numbers. that can be configured to get special treatment.
* Keywords can be treated as free-text field and play a minor role in the naming part.
* The order of keywords defines which keywords are more likely to show up in the naming of the file.

# Examples

* Invoice with a customer number and an invoice number: The customer number should go into the *keywords*. The product the invoice is for as well.
* Receipt with for a product: the product should go into the keywords field.
* Defined abbreviations like "customernumber" => "cnb" can be replaced and the filename be shortened.

# Affects
## Filename

* The last part of the filename (before the extension) is generate from the keywords.
* Defined strings can be replaced with abbreviations in Hiera.
* The number of keywords in the filename is limited to 3 (default) and can be re-defined.

## Exif

* From the exif data of a pdf document the keywords are stored in the tag *Keywords* as a comma separated string.
* *keywords* are stored as entered and are not altered in the metatag field.
