The CSV output formatted follows the guidelines mentioned under https://en.wikipedia.org/wiki/Comma-separated_values.

# Field Names

There is no header line defining the fields for the CSV output.

The fields are in the following order:

1. Author
2. Creator
3. CreateDate
4. Title
5. Subject
6. Keywords

# Quotes
Double quotes in fields like 'keywords' are replaced by double double quotes:

'"Keyword1, Keyword2"' => '""Keyword1, Keyword2""'

# Field seperator
The comma is used as a field seperator.

