##homebrew-caccurl

>Uses [Homebrew](http://brew.sh/) to build and install cURL (version  7.39.0) with PKCS11 Engine to allow for use with [DoD Common Access Cards (CAC)](http://www.cac.mil/).  

>  It also has various dependencies that will be installed including PKCS11 and [cackey](https://github.com/Conservatory/CACKey), which is included as a brew forumula.


> Heavily inspired by the brew install of [gitcac](https://github.com/xandris/homebrew-gitcac) - thanks @xandris!

##quickstart

> Assumes you have [homebrew](http://brew.sh/) installed and xcode command line tools

```

git clone https://540co/homebrew-caccurl
cd homebrew-caccurl
brew install caccurl.rb
exec bash -l

```

The installer may prompt you for your password a couple of times to run privileged actions. This is necessary to install CACKey and alter the system $PATH.

##install validation

Make sure that `curl` is in your PATH:

```

$ which git
/usr/local/bin/git

```

Verfiy that curl has OpenSSL configured correctly:
```

$ curl --engine list
Build-time engines:
  dynamic
  pkcs11
  
```

##testing install with CAC protected site
```
curl -L --engine pkcs11 --key-type ENG --cert-type ENG https://[url_to_your_favorite_cac_protected_site.mil]
PKCS#11 token PIN: ****

<your results>

```

##other fun configurations

### what if I don't want to have to enter my PIN?
> Do this at your own risk - and ensure your machine is secure in other ways.  There is definitely a policy somewhere that says you shouldn't do this - but it may be the best way when writing a script to hit many different CAC enabled endpoints at a time.

**Edit `/System/Library/OpenSSL/openssl.cnf` and add `PIN = 00000000` to the `[pkcs11_section]` where `00000000` is your PIN number.**

```

#
# OpenSSL example configuration file.
# This is mostly being used for generation of certificate requests.
#

# This definition stops the following lines choking if HOME isn't
# defined.
HOME                    = .
RANDFILE                = $ENV::HOME/.rnd

# Extra OBJECT IDENTIFIER info:
#oid_file               = $ENV::HOME/.oid
oid_section             = new_oids

openssl_conf            = openssl_def

[openssl_def]
engines = engine_section

[engine_section]
pkcs11 = pkcs11_section

[pkcs11_section]
engine_id = pkcs11
dynamic_path = /usr/local/lib/engines/engine_pkcs11.so
#MODULE_PATH = /usr/local/lib/opensc-pkcs11.so
MODULE_PATH = /usr/lib/pkcs11/cackey.dylib
init = 1
PIN = 00000000

# To use this configuration file with the "-extfile" option of the
# "openssl x509" utility, name here the section containing the
# X.509v3 extensions to use:
# extensions            =
# (Alternatively, use a configuration file that has only
# X.509v3 extensions in its main [= default] section.)

...(etc)...
```

##issues
- still working to determine how to handle picking which "cert" (email, PIV) you would like to use 




