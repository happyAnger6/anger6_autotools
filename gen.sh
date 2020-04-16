#!/bin/bash

project_name=

function genExample {
cat > ${project_name}.c <<EOF
#include <stdio.h>
#include <stdlib.h>

int main()
{
	printf("hello the world\r\n");
	return 0;
}
EOF
}

function genMakefileTemplate {
cat > Makefile.template <<EOF
noinst_PROGRAMS=app1 app2 #genarate app but not install
bin_PROGRAMS=app #install app
app1_SOURCES=app1.c #app source files
app2_SOURCES=app2.c
INCLUDES=-I$(top_srdir)/src/include #add include dir
lib_LIBRARIES=libxxx.a #static libraries
lib_LTLIBRARIES=libxxx.la #shared libraries via libtool
include_HEADERS #headers want to be installed
check_PROGRAMS #programs to build for testing
noinst_DIST #items not be installed with packages
EOF

}


function genMakefileAM {
cat > Makefile.am <<EOF
bin_PROGRAMS=${project_name}
${project_name}_SOURCES=${project_name}.c

EOF
}

echo "input your project name:"
read project_name

if [ -e ${project_name} ]
then
	rm -rf ${project_name}
	mkdir -p ${project_name}
fi

bGen=0
echo -n "do you want to generate a example file(Y/N)?:"
read bGenerate
if [ ${bGenerate} == "Y" -o ${bGenerate} == 'y' ]
then
	bGen=1
else
	bGen=0
fi
if [ $bGen -eq 1 ]
then
	genExample
fi

genMakefileAM
genMakefileTemplate

autoscan
sed -e 's/FULL-PACKAGE-NAME/'$project_name'/' \
    -e 's/VERSION/0.1/' \
    -e 's|BUG-REPORT-ADDRESS|/dev/null|' \
    -e '10i\
AM_INIT_AUTOMAKE' \
	< configure.scan > configure.ac

touch NEWS README AUTHORS ChangeLog
autoreconf -iv
./configure
make distcheck


