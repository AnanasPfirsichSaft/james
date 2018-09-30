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
. /opt/james/james-config
    if [ $# -ne 4 ]; then
    echo "usage: $0 [target] [flags] [title] [message]"
    echo "multiple targets separated by space are allowed"
    echo "	'host1 host2 host3'"
    echo "additional flags in single quotes:"
    echo "Show Icon - defaults to 'dialog-information'"
    echo "	<ico>[dialog-(information|warning|error)|full path]</ico>"
    echo "Play Tune - defaults to 'dialog-information'"
    echo "	<snd>[dialog-(information|warning|error)|full path]</snd>"
    echo "Urgency - defaults to 'normal'"
    echo "	<urg>(low|normal|critical)</urg>"
    exit 1
    fi
tmp=$(mktemp '/tmp/james-XXXXXXXXXX')
[ $? -ne 0 ] && echo "$(tput setaf 1)temporary file could not be created$(tput sgr0)" && exit 1
chmod 600 "$tmp"
echo "$2<hdr>$3</hdr><msg>$4</msg>" > "$tmp"
    for rcv in "$1"; do
	if [ -x /usr/bin/wget ]; then
	argadd=''
	[ "$JAMES_SCHEME" = 'https' ] && argadd="${argadd} --no-check-certificate"
	wget --no-http-keep-alive --tries=2 --timeout=8 --post-file="$tmp" \
	-O /dev/null${argadd} "${JAMES_SCHEME}://${rcv}:${JAMES_PORT}/james"
	elif [ -x /usr/bin/curl ]; then
	argadd=''
	[ "$JAMES_SCHEME" = 'https' ] && argadd="$argadd --insecure"
	curl --silent --no-keepalive --retry 2 --max-time 8 --data-binary "@$tmp" \
	-o /dev/null${argadd} "${JAMES_SCHEME}://${rcv}:${JAMES_PORT}/james"
	fi
    done
rm -f "$tmp"
