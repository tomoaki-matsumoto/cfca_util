#! /usr/bin/expect

# exp_internal 1

set VPN /opt/cisco/anyconnect/bin/vpn
set HOST vpn.cfca.nao.ac.jp
set USER "xxxxx"
set PASSWD "xxxx"

set timeout 5

spawn env LANG=C $VPN connect $HOST
expect {
    "Connect Anyway?" {
	send -- "y\n"
	exp_continue
    }
    "Username:" {
	send -- "${USER}\n"
	exp_continue
    }
    "Password:" {
	send -- "${PASSWD}\n"
	exp_continue
    }
}



