#!/usr/bin/php-cgi
<?php
/* =====================================================================
This file is part of "james"
https://github.com/AnanasPfirsichSaft/james

MIT License

Copyright (c) 2018 AnanasPfirsichSaft

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */
error_reporting(-1);
//date_default_timezone_set('Europe/Berlin');
$config = file_get_contents('/opt/james/james-config');
$host = preg_replace('/[^a-z0-9\-]+/i','',exec('hostname -s'));
$user = preg_replace('/[^a-z0-9\-]+/i','',get_current_user());
$uid = intval(getmyuid());
$in = trim(file_get_contents('php://input'));
$in_proto = 'HTTP/1.0';
$out = '';
$debug = '';
$header = '';
$payload = '';
$flag_urgency = 'normal';
$flag_type = 'info';
$flag_icon = 'default';
$flag_tune = 'default';
$icon_stack = array('dialog-information','dialog-warning','dialog-error');
function exec_tee($cmd){
exec($cmd,$stdout,$rc);
return array('cmd'=>$cmd,'stdout'=>implode(chr(10),$stdout),'rc'=>$rc);
}
	if ( isset($_SERVER['SERVER_PROTOCOL']) ){
		switch ( strtolower($_SERVER['SERVER_PROTOCOL']) ){
		case 'http/2.0':
		$in_proto = 'HTTP/2.0';
		break;
		case 'http/1.1':
		$in_proto = 'HTTP/1.1';
		break;
		case 'http/1.0':
		$in_proto = 'HTTP/1.0';
		break;
		}
	}
	if ( !isset($_SERVER['REQUEST_METHOD']) || $_SERVER['REQUEST_METHOD'] !== 'POST' ){
	header($in_proto.' 405 Method Not Allowed',true,405);
	header('Content-Type: text/plain; charset=utf-8');
	header('Allow: POST');
	echo 'ERROR 1 -- '.date('r').chr(10);
	die();
	}
putenv('HOME=/home/'.$user);
putenv('DISPLAY=:0');
putenv('USER='.$user);
putenv('LOGNAME='.$user);
putenv('PULSE_SERVER=/run/user/'.$uid.'/pulse/native');
exec('ps -u '.$user.' e | grep -Eo "dbus-daemon.*fork.*address=unix:abstract=/tmp/dbus-[a-zA-Z0-9]{10}" | tail -c35',$dbus_id);
$dbus_style = 'env-1';
	if ( is_array($dbus_id) && sizeof($dbus_id) === 0 ){
	$dbus_id = array();
	exec('ps -u '.$user.' e | grep -m1 -Eo "dbus-daemon.*fork.*unix:abstract=/tmp/dbus-[a-zA-Z0-9]{10,},guid=[a-f0-9]{32,}"',$dbus_id);
	$dbus_style = 'env-2';
	}
	if ( is_array($dbus_id) && sizeof($dbus_id) === 0 ){
	exec('ps -u '.$user.' -f | grep -E "dbus-daemon.*fork" | grep -v "accessibility"',$dbus_id);
	$dbus_id = implode("\n",$dbus_id);
	preg_match('/^'.$user.'\s+(\d+).*dbus\-daemon \-\-/m',$dbus_id,$dbus_id2);
	exec('ss -xp | grep -m1 "pid='.$dbus_id2[1].'"',$dbus_id);
	preg_match('/@\/tmp\/dbus\-[a-zA-Z0-9]+/',$dbus_id[0],$dbus_id);
	$dbus_id[0] = 'unix:abstract='.substr($dbus_id[0],1);
	$dbus_style = 'socket';
	unset($dbus_id2);
	}
	if ( is_array($dbus_id) && sizeof($dbus_id) >= 1 && strlen($dbus_id[0]) > 8 ){
	preg_match('/unix:abstract=[a-z0-9,:=\/\-]+/i',$dbus_id[0],$match);
	putenv('DBUS_SESSION_BUS_ADDRESS='.$match[0]);
	unset($match);
	}
preg_match_all('/<([a-z_\-]{3,12})>(.+?)<\/\1>/su',$in,$commands,PREG_SET_ORDER);
	if ( is_array($commands) && sizeof($commands) >= 2 ){
		foreach ( $commands as $args ){
			switch ( strtolower($args[1]) ){
			case 'urg':
				if ( in_array($args[2],array('low','normal','critical'),true) ){
				$flag_urgency = $args[2];
					if ( $args[2] === 'critical' )
					$flag_type = 'warning';
				}
			break;
			case 'ico':
				if ( in_array(basename($args[2]),$icon_stack,true) )
				$flag_icon = basename($args[2]);
				elseif ( file_exists($args[2]) )
				$flag_icon = $args[2];
			break;
			case 'snd':
				if ( file_exists('/usr/share/sounds/freedesktop/stereo/'.basename($args[2]).'.oga') )
				$flag_tune = basename($args[2]);
				elseif ( file_exists($args[2]) )
				$flag_tune = $args[2];
			break;
			case 'hdr':
			$header = str_replace('&amp;','&',$args[2]);
			break;
			case 'msg':
			$payload = str_replace('&amp;','&',$args[2]);
			break;
			}
		}
	}
	if ( $flag_icon === 'default' )
	$flag_icon = 'dialog-information';
	if ( $flag_tune === 'default' )
	$flag_tune = '/usr/share/sounds/freedesktop/stereo/dialog-information.oga';
	if ( strlen($header) >= 4 && strlen($payload) >= 8 ){
	header($in_proto.' 202 Accepted',true,202);
	$out .= 'OK'.chr(10);
	$debug .= chr(9).'#user: '.getenv('USER').'@'.chr(10);
	$debug .= chr(9).'#dbus: '.$dbus_style.' '.getenv('DBUS_SESSION_BUS_ADDRESS').'@'.chr(10);
	$debug .= chr(9).'Header: '.$header.'@'.chr(10);
	$debug .= chr(9).'Payload: '.$payload.'@'.chr(10);
	$debug .= chr(9).chr(9).'Urgency: '.$flag_urgency.'@'.chr(10);
	$debug .= chr(9).chr(9).'Type: '.$flag_type.'@'.chr(10);
	$debug .= chr(9).chr(9).'Icon: '.$flag_icon.'@'.chr(10);
	$debug .= chr(9).chr(9).'Tune: '.$flag_tune.'@'.chr(10);
		if ( strlen($flag_tune) >= 8 && file_exists('/usr/bin/ogg123') && is_executable('/usr/bin/ogg123') ){
		$aout = ( file_exists(getenv('PULSE_SERVER')) ) ? 'pulse' : 'alsa';
		$ret = exec_tee('/usr/bin/ogg123 -q -d '.$aout.' '.$flag_tune.' 2>&1 &');
		$debug .= chr(9).chr(9).chr(9).'shell_exec: '.$ret['cmd'].chr(10);
		$debug .= chr(9).chr(9).chr(9).'ogg123 returned '.$ret['rc'].chr(10);
		}
		if ( file_exists('/usr/bin/notify-send') && is_executable('/usr/bin/notify-send') ){
		$ret = exec_tee('/usr/bin/notify-send --urgency='.$flag_urgency.' --icon='.$flag_icon.' --expire-time=10000 "'.$header.'" "'.$payload.'" 2>&1 &');
		$debug .= chr(9).chr(9).chr(9).'shell_exec: '.$ret['cmd'].chr(10);
		$debug .= chr(9).chr(9).chr(9).'notify-send returned '.$ret['rc'].chr(10);
		}
		if ( $flag_type === 'warning' && file_exists('/usr/bin/zenity') && is_executable('/usr/bin/zenity') ){
		exec('pidof zenity',$return,$null);
			if ( is_array($return) && sizeof($return) === 0 ){
			$ret = exec_tee('/usr/bin/zenity --'.$flag_type.' --width=400 --height=200 --title="'.$header.' ['.date('H:i').'h]" --text="'.$payload.'" 2>&1 &');
			$debug .= chr(9).chr(9).chr(9).'shell_exec: '.$ret['cmd'].chr(10);
			$debug .= chr(9).chr(9).chr(9).'zenity returned '.$ret['rc'].chr(10);
			}
			else
			$debug .= chr(9).chr(9).chr(9).'zenity already running'.chr(10);
		}
		elseif ( $flag_type === 'warning' && file_exists('/usr/bin/kdialog') && is_executable('/usr/bin/kdialog') ){
		exec('pidof kdialog',$return,$null);
			if ( is_array($return) && sizeof($return) === 0 ){
			$kde_flag_type = ( $flag_type === 'info' ) ? 'msgbox' : 'sorry';
			$ret = exec_tee('/usr/bin/kdialog --title="'.$header.' ['.date('H:i').'h]" --'.$kde_flag_type.' "'.$payload.'" 2>&1 &');
			$debug .= chr(9).chr(9).chr(9).'shell_exec: '.$ret['cmd'].chr(10);
			$debug .= chr(9).chr(9).chr(9).'kdialog returned '.$ret['rc'].chr(10);
			}
			else
			$debug .= chr(9).chr(9).chr(9).'kdialog already running'.chr(10);
		}
	$out .= chr(10);
	}
	else{
	header($in_proto.' 503 Service Unavailable',true,503);
	header('Retry-After: 5');
	$out .= 'ERROR 2 -- '.date('r').chr(10);
	}
	if ( strpos($config,'JAMES_LOG=1') > 0 ){
		if ( !file_exists('/var/log/james/server.cgi.log') ){
		touch('/var/log/james/server.cgi.log');
		chmod('/var/log/james/server.cgi.log',0600);
		}
	file_put_contents('/var/log/james/server.cgi.log',date('r').chr(10).chr(9).$in.chr(10).chr(9).$out.$debug.chr(10).str_repeat('*',72).chr(10),FILE_APPEND|LOCK_EX);
	}
header('Content-Type: text/plain; charset=utf-8');
header('Cache-Control: no-cache,no-store,max-age=0,s-maxage=0');
header('Connection: close');
header('Expires: 0');
echo $out;
?>
