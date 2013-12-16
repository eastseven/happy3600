#!/bin/sh

svn_url=https://10.10.10.10/svn/happy3600/mobilek/server/GameServer/branch/Server_language-dev-pata
svn_user=dongqi
svn_password=123456

project=GameServer
rm -rf $project
mkdir $project
cd $project

svn checkout --username $svn_user --password $svn_password $svn_url/conf conf
svn checkout --username $svn_user --password $svn_password $svn_url/language language
svn checkout --username $svn_user --password $svn_password $svn_url/src src
svn cat --username $svn_user --password $svn_password $svn_url/build.properties > build.properties
svn cat --username $svn_user --password $svn_password $svn_url/build.xml > build.xml
svn cat --username $svn_user --password $svn_password $svn_url/startserver.sh > startserver