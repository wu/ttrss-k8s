#!/bin/sh

set -e

# Call the image's init script which in turn calls the s6 supervisor then.
/init
