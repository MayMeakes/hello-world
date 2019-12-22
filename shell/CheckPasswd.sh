#!/bin/bash
#Date:2019-06-24
#Author: Meiguiwei
#Description: check password
#node setting
# ip:login_user:login_passwd:
set node "10.77.20.153:root:sisesise     
    192.168.1.1:root:mypassword1
    192.168.1.2:root:mypassword2
    192.168.1.3:root:mypassword3
    192.168.1.4:root:mypassword4"



foreach node $nodeinfo {
    set host_info [split $node ":"]
    set ssh_ip              [lindex $host_info 0]
    set ssh_loginName       [lindex $host_info 1]
    set ssh_loginPasswd     [lindex $host_info 2]


    send_user "=======================begin...=====================/n"
    #ssh into the host    
    spawn /usr/bin/ssh -D $port  $ssh_loginName@$ssh_ip
    expect {
    "*yes/no*" {
         send "yes/r";
         expect "*assword*";
         send "$ssh_loginPasswd/r"
         } 
    "*assword*" {
         send "$ssh_loginPasswd/r"
         } 
    }   

 

    expect "*#"

    send "ls/r"