#! /usr/bin/env python

import sys
import crypt, getpass

try:
    cleartext = getpass.getpass()
    ciphertext = crypt.crypt(cleartext, crypt.METHOD_SHA512)
    if crypt.crypt(cleartext, ciphertext) != ciphertext:
        raise ValueError('Error in generating password')
    print ciphertext


    sys.exit(0)
except Exception as e:
    print e
