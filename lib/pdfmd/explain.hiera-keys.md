Keys in Hiera can be defined in order to overwrite the default renaming behaviour.

The default support is since version 1.8.1 only for the english language and will replace words in the meta-tag field 'keywords' with abbreviations.

The following default abbreviations will be used:

* 'off': 'Offer', 'Offernumber'
* 'inv': 'Invoice', 'Invoicenumber'
* 'con': 'Contract'
* 'ord': 'Order', 'Ordernumber'
* 'rec': 'Receipt', 'Receiptnumber'
* 'man': 'Manual'

# Example

Using the string 'Offernumber 1111' will result in the string 'off1111' in the filename, unless the number of keywords is higher than the maximum number of keywords to use.  
The matching is case-insensitive. 'offernumber 1111' and 'Offernumber 1111' will result in the same replacement.

In order to overwrite the default you need to configure hiera and define a hash 'keys' with the abbreviation as sub-key and the string to replace as value. The value can either be defined as string or as array.

The following example mirrors the default replacement in the Hiera configuration:

``` YAML
pdfmd::config:
  rename:
    keys:
      'off': ['Offer', 'Offernumber']
      inv  : ['Invoice', 'Invoicenumber']
      con  : Contract
      ord  : ['Order', 'Ordernumber']
      rec  : ['Receipt', 'Receiptnumber']
      man  : Manual
```

Warning: Keys like 'off' need to be set in apostrophe, otherwise the key will be interpreted as 'false' instead.

