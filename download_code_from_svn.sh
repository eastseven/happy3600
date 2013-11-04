#!/bin/sh


project_gs=gameserver
project_lib=gameserver_libs
project_lk=gameserver_lk_agip

svn_username=dongqi
svn_password=123456

rm -rf $project_gs
rm -rf $project_lk
rm -rf $project_lib

svn --username $svn_username --password $svn_password checkout https://10.10.10.10/svn/happy3600/mobilek/server/GameServer/Server_language $project_gs
svn --username $svn_username --password $svn_password checkout https://10.10.10.10/svn/happy3600/mobilek/server/GameServer/ServerLibs $project_lib
svn --username $svn_username --password $svn_password checkout https://10.10.10.10/svn/happy3600/mobilek/server/LK_AGIP/Project $project_lk
