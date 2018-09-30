#!/bin/sh
# =====================================================================
# This file is part of "james"
# https://github.com/AnanasPfirsichSaft/james
#
# MIT License
#
# Copyright (c) 2018 AnanasPfirsichSaft
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
echo ""
echo "I need to create a so called x509 certificate to enable"
echo "the transport encryption you want. You can confirm most"
echo "questions by pressing ENTER. When you are asked for the"
echo "'Common Name' or FQDN, please type $(hostname)."
echo ""
echo "$(tput bold)If you already have an existing certificate or do not"
echo "want to change your current, type NO.$(tput sgr0)"
echo ""
echo -n "Shall I generate a certificate [Y/n]? "
read docert

    if [ x$docert = xn -o x$docert = xno ]; then
    echo "Not generating a certificate."
    else
    openssl req -new -x509 -keyout /opt/james/server.pem -out /opt/james/server.pem -days 365 -nodes
    echo ""
    echo "It is a self-signed certificate and is valid for one year."
    echo "You can renew it by running 'make-cert.sh' again."
    echo "The cert may create a warning that is is 'unsafe'. You can ignore"
    echo "that or get a signed cert from a trusted CA like 'Let's Encrypt'."
    echo ""
    echo "At last I have to create a file to enhance your encryption."
    echo "Press ENTER to continue."
    read foo
    openssl dhparam -out /opt/james/dh.pem -outform PEM -2 2048
    fi
