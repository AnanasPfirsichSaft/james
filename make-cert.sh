#!/bin/sh
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
