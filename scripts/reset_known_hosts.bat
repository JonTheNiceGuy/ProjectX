@echo off
REM ###########################################################################
REM #
REM # For use when forwarding x11 windows over ssh from guest to host
REM #
REM # This script resets certificate entries in known_hosts so that when a
REM # vagrant VM is destroyed the VMs key is also destroyed.
REM #
REM # WARNING: FRAGILE
REM #
REM # Dependencies:
REM #   Only for use with Cygwin 64
REM #
REM ###########################################################################
findstr /v /i "192.168.100.1" C:\cygwin64\home\HigginbottomM\.ssh\known_hosts > C:\cygwin64\home\HigginbottomM\.ssh\known_hosts_temp
del /q C:\cygwin64\home\HigginbottomM\.ssh\known_hosts
move /Y  C:\cygwin64\home\HigginbottomM\.ssh\known_hosts_temp C:\cygwin64\home\HigginbottomM\.ssh\known_hosts
echo 192.168.100.1 entries removed from C:\cygwin64\home\HigginbottomM\.ssh\known_hosts