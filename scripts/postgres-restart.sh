# after a crash
# https://coderwall.com/p/zf-fww

rm /usr/local/var/postgres/postmaster.pid
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start


# http://stackoverflow.com/questions/7975556/how-to-start-postgresql-server-on-mac-os-x
# start

# pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start


# stop

# pg_ctl -D /usr/local/var/postgres stop -s -m fast




# if fails

# http://stackoverflow.com/questions/13573204/psql-could-not-connect-to-server-no-such-file-or-directory-mac-os-x
# rm /usr/local/var/postgres/postmaster.pid
