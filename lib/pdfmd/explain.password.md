Passwords might be needed to access password protected files.

If a password is needed is automatically detected. If a password is required, the processing will stop and the user asked for a password,

A password can also be specified via Hiera:

``` YAML
pdfmd::config:
  default:
    password: xxxxxxxxx
```

The password request towards the user is only triggered when no password in Hiera had been found.

