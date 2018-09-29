#!/bin/sh
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
