shell='/usr/bin/sh'
nologin='/usr/bin/nologin'
home='/home/%n'

user root 0 0 root /root shell
group root 0
members root root
group utmp 20
group users 100
user nobody 65534 65534 'Unmapped user'
group nobody 65534
members nobody nobody
