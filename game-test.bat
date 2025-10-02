@echo off

set "GameFilter=1024-65535"
set "DIR=%~dp0"

cd /d "%~dp0"

%DIR%\app\winws.exe --wf-tcp=%GameFilter% --wf-udp=%GameFilter% ^

--filter-tcp=443,%GameFilter% --ipset="%DIR%\ipset\ipset-games.txt" --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fooling=md5sig --dpi-desync-fake-tls="%DIR%\app\tls_clienthello_www_google_com.bin" --new ^
--filter-udp=%GameFilter% --ipset="%DIR%\ipset\ipset-games.txt" --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=12 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp="%DIR%\app\quic_initial_www_google_com.bin" --dpi-desync-cutoff=n3


exit
