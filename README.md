# JAMES

## Description

JAMES is a shortcut of a german phrase "Joviale Anwendung zur Meldung Eines
Sachverhalts". Which means JAMES is a jovial man-servant to inform you of
issues. It gets a message transported over HTTP(S) landing on your local running
webserver from any client in connected networks. As long as your packet filter
(router) allows this. Then it forwards this to your linux desktop notification 
subsystem using standard tools.

## Requirements

* [PHP](http://www.php.net/) in CGI mode.

* A webserver like [lighttpd](https://www.lighttpd.net/).

* A http client on console like [wget](https://www.gnu.org/software/wget/) or [curl](http://curl.haxx.se/).

* A notification tool like notify-send.

## Audience

JAMES is intended for users who want to send simple messages from machines in
their network to get notifications on their linux desktop environment. It just
needs a (existing) webserver on your machine ("server") and a simple http tool
on the others ("client").

You are expected to know what a console/shell is and how to drop commands.
Additionally how to edit files should be no problem. Base knowledge on linux
systems (filesystem permissions) is helpful.

## Full Install

I provide a shell script *make.sh* to help you to setup a custom webserver
especially for JAMES. Please ensure that the file is executable. If you
already have installed another webserver, i.e. from your distribution, you can
skip this section. Go to "Minimal Install".

Edit *james-config* to your wishes and run *make.sh* in your shell. It will ask
you some questions, download the webserver source code and setup the base for
JAMES in */opt/james*.

The webserver has been configured. The configuration can be found in
*/opt/james/server-lighttpd.conf*. Basically it listens on port 3333 and uses an
alias "/james" to point to */opt/james/james-server.cgi*. The CGI version of PHP
is delegated to run the server-side script. In the end JAMES can be called at
"http(s)://[yourhost]:3333/james" with any http client capable of the POST
method.

Start the webserver by running
"/opt/james/lighttpd -D -f /opt/james/server-lighttpd.conf -m /opt/james" in
your shell. Open "http(s)://[yourhost]:3333/" in your browser. You should see
"Ping Pong". Append "james" to your URL. JAMES should throw an "ERROR 1",
because you have not given any data yet. Press CTRL+C in the shell to stop the
webserver.

You can start the webserver by hand everytime you want it. Or you put it into
autostart of your favorite desktop environment. If you wish to launch it every
system bootup do "sudo cp /opt/james/james-server.service /etc/systemd/system".
This will require elevated privileges and prepares a service file to start the 
webserver during system startup. Run "sudo systemctl daemon-reload" and
"sudo systemctl start james-server.service". If the webserver runs fine, you can
enable its launch eventually. Replace "start" with "enable" in the last command.

Try to send a message with *james-client.sh* on your console. It should popup on
your desktop. Do
"./james-client.sh [yourhostname] '' 'JAMES Test' 'This is just a test message...'".
Your hostname can be seen at the beginning of *make.sh* output or when executing
"hostname -s" in your shell. If you can see the notification you can copy the
client to your system binaries: "sudo cp james-client.sh /usr/local/bin".

If you want to secure your webserver you can also install an "apparmor profile".
This is a text file telling your operating system exactly what the webserver is
allowed to do. It has to copied with elevated privileges:
"sudo cp apparmor-profile /etc/apparmor.d/james-server". The profile takes
effect on your next system bootup or if you load it directly:
"sudo apparmor_parser -r /etc/apparmor.d/james-server" and
"sudo systemctl restart james-server.service".

## Minimal Install

**WARNING:** This is for experienced users only! An existing webserver is
expected. Please note that JAMES has to detect your user account name
and its dbus socket through environment variables or scanning your
running processes. Hence *james-server.cgi* executed by your webserver
must have access to this data and should be run under your user
account. How to do this depends heavily on your chosen webserver and
is not covered by this manual.

You have to install some programs for JAMES to make notifications. This is
depending on your linux distribution.

* Debian-based: apt-get install vorbis-tools libnotify-bin php-cgi

Then you have to create the directory */opt/james* and copy a to your needs
adjusted *james-config* and *james-server.cgi* into it. Also create
*/var/log/james*. The user your webserver runs with must be able to write here.
Set the permissions accordingly.

Point an alias you want, "/james" by default, in your webserver configuration
to */opt/james/james-server.cgi* and allow to run CGI scripts.

Copy *james-client.sh* to */usr/local/bin* and try to send a message:
"james-client.sh [yourhostname] '' 'JAMES Test' 'This is just a test message...'".

## Update

Please do not override *james-config* without checking and preserving your
changes.

Copy *james-server.cgi* to */opt/james* and optionally *james-client.sh* to
*/usr/local/bin*.

If you want to update your webserver you will have to edit the URL in
*james-config* and run *make.sh* again.

## Uninstall

This is done by disabling and removing the systemd service file and deleting 
two directories.

sudo systemctl stop james-server.service
sudo systemctl disable james-server.service
sudo rm -Rf /opt/james /var/log/james

## License

All files are released to the [MIT License](https://github.com/AnanasPfirsichSaft/james/blob/master/LICENSE).
