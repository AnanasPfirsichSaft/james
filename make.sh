#!/bin/sh
. ./james-config
USE_DIST='auto'
[ ! -z $JAMES_DIST ] && USE_DIST=$JAMES_DIST
chmod a+x make-cert.sh james-client.sh james-server.cgi >/dev/null
    if [ "$USE_DIST" = 'auto' ]; then
	if [ -f /etc/debian_version ]; then
	USE_DIST='debian'
	fi
    fi
WS_SRC='https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.50.tar.gz'

echo "$(tput bold)JAMES Installation Script$(tput sgr0)"
echo "========================="
echo ""
echo "This little script helps you to setup a webserver to"
echo "get messages. Currently I support lighttpd. I fetch its"
echo "source code, compile it on your machine and setup the"
echo "software to /opt/james. Maybe you have to install some"
echo "packages for this task."
echo ""
echo "First of all I detect some settings of your system."
echo "Press ENTER to continue."
read foo

echo "Your username is $(id -un)"
echo "Your hostname is $(hostname -s)"
echo ""

    if [ ! -d /opt/james ]; then
    echo "$(tput bold)The target directory is not found on your system.$(tput sgr0)"
	if [ ! -x /usr/bin/sudo ]; then
	echo "Please create it yourself with elevated privileges:"
	echo "mkdir /opt/james /var/log/james"
	echo "chown $(id -ur) /opt/james /var/log/james"
	echo "chmod 700 /opt/james /var/log/james"
	exit 1
	fi
    echo "I need you to give your password to create it with"
    echo "elevated privileges. And make you the owner of it."
    echo ""
    sudo mkdir -v /opt/james /var/log/james
    sudo chown -v $(id -ur) /opt/james /var/log/james
    sudo chmod -v 700 /opt/james /var/log/james
    sudo -k
    echo ""
    else
    echo "Maybe it is advisable to make a backup of your"
    echo "target directory before proceeding?"
    echo ""
    fi

echo -n "Would you like to use transport encryption (HTTPS) [Y/n]? "
read usetls
    if [ x$usetls = xy -o x$usetls = xyes ]; then
    echo "Enabling transport encryption (HTTPS)."
    else
    echo "Not enabling transport encryption (HTTPS)."
    fi

echo ""
echo "I will have a look if all required packages are installed to"
echo "your system. Press ENTER to continue."
read foo
confadd=''

    case "$USE_DIST" in
    'debian')
    echo "$(tput bold)Selected distribution family: debian$(tput sgr0)"
	if [ -x /usr/bin/sudo -a ! -e /opt/james/lighttpd ]; then
	echo "Please give your password to install some packages"
	echo "required to compile the webserver source code."
	echo ""
	sudo apt-get install --no-install-recommends build-essential libpcre3-dev php-cgi libnotify-bin vorbis-tools
	    if [ x$usetls = xy -o x$usetls = xyes ]; then
	    sudo apt-get install --no-install-recommends libssl-dev openssl
	    confadd="${confadd}--with-openssl"
	    fi
	sudo -k
	fi
    ;;
    *)
    echo "$(tput setaf 1)Selected distribution is not supported!$(tput sgr0)"
    exit 1
    ;;
    esac

echo ""
echo "Let us get the webserver source code. Press ENTER to continue."
read foo

    if [ -x /usr/bin/wget ]; then
    wget -N "$WS_SRC"
    elif [ -x /usr/bin/curl ]; then
    curl "$WS_SRC"
    else
    echo "$(tput setaf 1)Cannot find wget or curl to download source code!$(tput sgr0)"
    exit 1
    fi

[ "$?" -ne 0 ] && echo "$(tput setaf 1)Source code cannot be downloaded!$(tput sgr0)" exit 1
srcfile=${WS_SRC##*/}
tar --totals --extract --directory=/tmp --file "$srcfile"
OLDPWD=$(pwd)
cd $(find /tmp -maxdepth 1 -type d -name 'lighttpd-*')
[ ! -f ./configure ] && echo "$(tput setaf 1)Source code seems not to be valid!$(tput sgr0)" exit 1
echo ""
echo "The source code has been extracted. I will compile the webserver."
echo "This can take a few minutes. Get a coffee... ;)"
sleep 5
[ -f ./src/lighttpd ] && make distclean
./configure --prefix=/ --without-zlib --without-bzip2 "$confadd"
ret="$?"
sleep 5
    if [ "$ret" -eq 0 ]; then
    make
    sleep 5
	if [ "$?" -eq 0 ]; then
	echo ""
	echo "Compiling was successful. Installing it to /opt/james."
	echo "Press ENTER to continue."
	read foo
	strip src/lighttpd src/.libs/*.so
	cp -v src/lighttpd /opt/james
	cp -v src/.libs/mod_access.so /opt/james
	cp -v src/.libs/mod_accesslog.so /opt/james
	cp -v src/.libs/mod_alias.so /opt/james
	cp -v src/.libs/mod_cgi.so /opt/james
	cp -v src/.libs/mod_dirlisting.so /opt/james
	cp -v src/.libs/mod_indexfile.so /opt/james
	cp -v src/.libs/mod_setenv.so /opt/james
	cp -v src/.libs/mod_staticfile.so /opt/james
	# copy if you want webdav support for public folder
	# cp -v src/.libs/mod_webdav.so /opt/james
	    if [ x$usetls = xy -o x$usetls = xyes ]; then
	    cp -v src/.libs/mod_openssl.so /opt/james
	    fi
	cd $OLDPWD
	    if [ ! -f /opt/james/james-server.service ]; then
	    cp -v james-server.service /opt/james
	    sed -i s/'%USER%'/$(id -un)/ /opt/james/james-server.service
	    fi
	    if [ ! -f /opt/james/server-lighttpd.conf ]; then
	    cp -v server-lighttpd.conf /opt/james
	    sed -i s/'%USER%'/$(id -un)/ /opt/james/server-lighttpd.conf
	    sed -i s/'%JAMES_PORT%'/"$JAMES_PORT"/ /opt/james/server-lighttpd.conf
	    fi
	[ ! -d /opt/james/htdocs ] && mkdir -m0755 -v /opt/james/htdocs && echo "<h1>Ping ... Pong</h1>" > /opt/james/htdocs/index.html
	    if [ ! -f /opt/james/james-config -o $(md5sum ./james-config | cut -c1-32) != $(md5sum /opt/james/james-config | cut -c1-32) ]; then
	    cp -vb james-config /opt/james
	    fi
	cp -v james-server.cgi /opt/james
	chmod -R 644 /opt/james/* 2>/dev/null
	chmod 755 /opt/james/htdocs 2>/dev/null
	chmod 755 /opt/james/lighttpd /opt/james/*.so /opt/james/*.cgi 2>/dev/null
	    if [ ! -f /opt/james/server.pem -a -x /opt/james/mod_openssl.so ]; then
	    sed -i s/'^#	ssl'/'	ssl'/ /opt/james/server-lighttpd.conf
	    sed -i s/'^# mod_openssl'/'server.modules += ( "mod_openssl" )'/ /opt/james/server-lighttpd.conf
	    ./make-cert.sh
	    fi
	else
	echo "$(tput setaf 1)Something went wrong while compiling the source code!$(tput sgr0)"
	exit 1
	fi
    else
    echo "$(tput setaf 1)Something went wrong while configuring the source code!$(tput sgr0)"
    exit 1
    fi
