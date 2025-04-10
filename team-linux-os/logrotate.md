# Linux & OS

## Setup VM
In VM (ubuntu)

### SSH
```
sudo apt install openssh-server
sudo systemctl status ssh
sudo systemctl enable ssh --now
```

### Firewall
```
sudo lsof -i -P -n | grep LISTEN
sudo ufw status
sudo ufw allow ssh
sudo ufw status verbose
```

## Logrotate
```
logrotate --version
```

### Tour
Logrotate main configuration is in `/etc/logrotate.conf`
```
$ cat /etc/logrotate.conf
# see "man logrotate" for details

# global options do not affect preceding include directives

# rotate log files weekly
weekly

# use the adm group by default, since this is the owning group
# of /var/log/.
su root adm

# keep 4 weeks worth of backlogs
rotate 4

# create new (empty) log files after rotating old ones
create

# use date as a suffix of the rotated file
#dateext

# uncomment this if you want your log files compressed
#compress

# packages drop log rotation information into this directory
include /etc/logrotate.d

# system-specific logs may also be configured here.
```

Each entity is in `/etc/logrotate.d`
```
$ ls -la /etc/logrotate.d
total 88
drwxr-xr-x   2 root root  4096 Apr 10 23:10 .
drwxr-xr-x 138 root root 12288 Apr 10 21:21 ..
-rw-r--r--   1 root root   120 Feb  5  2024 alternatives
-rw-r--r--   1 root root   126 Apr 22  2022 apport
-rw-r--r--   1 root root   173 Mar 22  2024 apt
-rw-r--r--   1 root root    91 Jan  5  2024 bootlog
-rw-r--r--   1 root root   130 Oct 14  2019 btmp
-rw-r--r--   1 root root   144 Dec  3 04:09 cloud-init
-rw-r--r--   1 root root   181 Feb 29  2024 cups-daemon
-rw-r--r--   1 root root   112 Feb  5  2024 dpkg
-rw-r--r--   1 root root    94 Aug 18  2022 ppp
-rw-r--r--   1 root root   248 Mar 22  2024 rsyslog
-rw-r--r--   1 root root   132 Sep 11  2020 sane-utils
-rw-r--r--   1 root root   677 Oct  5  2023 speech-dispatcher
-rw-r--r--   1 root root   174 Apr  5  2024 sssd-common
-rw-r--r--   1 root root   270 Apr  2  2024 ubuntu-pro-client
-rw-r--r--   1 root root   209 May 16  2023 ufw
-rw-r--r--   1 root root   235 Feb 13  2024 unattended-upgrades
-rw-r--r--   1 root root   145 Oct 14  2019 wtmp
```

### Write a new Configuration
Write config for apache2 in `/etc/logrotate.d/apache2`
```
/var/log/apache2/*.log {
  daily
  missingok
  rotate 14
  compress
  delaycompress
  notifempty
  create 640 root adm
  sharedscripts
  prerotate
    if [ -d /etc/logrotate.d/httpd-prerotate ]; then
      run-parts /etc/logrotate.d/httpd-prerotate
    fi
  endscript
  postrotate
    if pgrep -f ^/usr/sbin/apache2 > /dev/null; then
      invoke-rc.d apache2 reload 2>&1 | logger -t apache2.logrotate
    fi
  endscript
}
```

### Install apache2
```
sudo apt install apache2
```

Then apache2 logrotate config is installed.
```
$ ls -la /etc/logrotate.d
total 92
drwxr-xr-x   2 root root  4096 Apr 10 23:27 .
drwxr-xr-x 139 root root 12288 Apr 10 23:27 ..
-rw-r--r--   1 root root   120 Feb  5  2024 alternatives
-rw-r--r--   1 root root   397 Mar 18  2024 apache2
-rw-r--r--   1 root root   423 Apr 10 23:23 apache2.dpkg-old
-rw-r--r--   1 root root   126 Apr 22  2022 apport
-rw-r--r--   1 root root   173 Mar 22  2024 apt
-rw-r--r--   1 root root    91 Jan  5  2024 bootlog
-rw-r--r--   1 root root   130 Oct 14  2019 btmp
-rw-r--r--   1 root root   144 Dec  3 04:09 cloud-init
-rw-r--r--   1 root root   181 Feb 29  2024 cups-daemon
-rw-r--r--   1 root root   112 Feb  5  2024 dpkg
-rw-r--r--   1 root root    94 Aug 18  2022 ppp
-rw-r--r--   1 root root   248 Mar 22  2024 rsyslog
-rw-r--r--   1 root root   132 Sep 11  2020 sane-utils
-rw-r--r--   1 root root   677 Oct  5  2023 speech-dispatcher
-rw-r--r--   1 root root   174 Apr  5  2024 sssd-common
-rw-r--r--   1 root root   270 Apr  2  2024 ubuntu-pro-client
-rw-r--r--   1 root root   209 May 16  2023 ufw
-rw-r--r--   1 root root   235 Feb 13  2024 unattended-upgrades
-rw-r--r--   1 root root   145 Oct 14  2019 wtmp
```

```
$ cat /etc/logrotate.d/apache2
/var/log/apache2/*.log {
        daily
        missingok
        rotate 14
        compress
        delaycompress
        notifempty
        create 640 root adm
        sharedscripts
        prerotate
                if [ -d /etc/logrotate.d/httpd-prerotate ]; then
                        run-parts /etc/logrotate.d/httpd-prerotate
                fi
        endscript
        postrotate
                if pgrep -f ^/usr/sbin/apache2 > /dev/null; then
                        invoke-rc.d apache2 reload 2>&1 | logger -t apache2.logrotate
                fi
        endscript
}
```

### Add some logs
```
sudo service apache2 status
sudo service apache2 start
```

Visit your apache server
- `curl localhost:80`
- or open browser http://localhost:80

Apache2 log directory
```
$ ll /var/log/apache2
total 16
drwxr-x---  2 root adm    4096 Apr 10 23:27 ./
drwxrwxr-x 17 root syslog 4096 Apr 10 23:26 ../
-rw-r-----  1 root adm      81 Apr 10 23:32 access.log
-rw-r-----  1 root adm     279 Apr 10 23:27 error.log
-rw-r-----  1 root adm       0 Apr 10 23:27 other_vhosts_access.log
```

Apache2 logs
```
$ cat /var/log/apache2/access.log
::1 - - [10/Apr/2025:23:32:23 +0900] "GET / HTTP/1.1" 200 10926 "-" "curl/8.5.0

$ tail -f /var/log/apache2/access.log
::1 - - [10/Apr/2025:23:32:23 +0900] "GET / HTTP/1.1" 200 10926 "-" "curl/8.5.0"
```

### Rotate log
```
sudo logrotate --force /etc/logrotate.d/apache2
```

```
$ ll /var/log/apache2
total 20
drwxr-x---  2 root adm    4096 Apr 10 23:37 ./
drwxrwxr-x 17 root syslog 4096 Apr 10 23:26 ../
-rw-r-----  1 root adm       0 Apr 10 23:37 access.log
-rw-r-----  1 root adm      81 Apr 10 23:32 access.log.1
-rw-r-----  1 root adm     279 Apr 10 23:37 error.log
-rw-r-----  1 root adm     585 Apr 10 23:37 error.log.1
-rw-r-----  1 root adm       0 Apr 10 23:27 other_vhosts_access.log
```

```
$ cat /var/log/apache2/access.log.1
::1 - - [10/Apr/2025:23:32:23 +0900] "GET / HTTP/1.1" 200 10926 "-" "curl/8.5.0"
$ cat /var/log/apache2/access.log
$
```


## References

Better Stack Youtube: [Logrotate - Log Management on Linux Servers](https://www.youtube.com/watch?v=-tM6DsYam0c)

Better Stack Guides: [A Complete Guide to Managing Log Files with Logrotate](https://betterstack.com/community/guides/logging/how-to-manage-log-files-with-logrotate-on-ubuntu-20-04/)
