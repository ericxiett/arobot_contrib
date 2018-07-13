#!/bin/bash

set -e

echo "####################################"
echo "#  Welcome to build indeploy rpms  #"
echo "####################################"

BASEPATH=$(cd `dirname $0`; pwd)
DEP_PATH=$BASEPATH/build_dep

echo "Install rpmbuild tools..."
yum install -y yum-utils rpm-build centos-release-openstack-newton

# Modify macro for rpm
sed -i 's/.el7.centos/.el7/' /etc/rpm/macros.dist

echo "Start to build ironic rpms..."

rm -rf $BASEPATH/rpms/ironic/* | /bin/true

IRONIC_DEP=$DEP_PATH/ironic
IRONIC_VER=6.2.1
IRONIC_SRC=$BASEPATH/ironic-$IRONIC_VER
tar -cvf $IRONIC_DEP/ironic-$IRONIC_VER.tar.gz ironic-$IRONIC_VER

mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp $IRONIC_DEP/* ~/rpmbuild/SOURCES
cp $IRONIC_DEP/openstack-ironic.spec ~/rpmbuild/SPECS

# Need to add newton repository
cat << EOF > /etc/yum.repos.d/newton.repo
[newton]
name=newton
baseurl=https://buildlogs.centos.org/centos/7/cloud/x86_64/openstack-newton/
gpgcheck=0
enabled=1

EOF

yum-builddep ~/rpmbuild/SPECS/openstack-ironic.spec -y

rpmbuild -bb ~/rpmbuild/SPECS/openstack-ironic.spec

mkdir -p rpms/ironic
cp ~/rpmbuild/RPMS/noarch/*.el7.noarch.rpm $BASEPATH/rpms/ironic

rm -rf $IRONIC_DEP/ironic-$IRONIC_VER.tar.gz
rm -rf ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

echo "Start to build ironic-inspector rpms..."

rm -rf $BASEPATH/rpms/ironic-inspector/* | /bin/true

IRONIC_INSPECTOR_DEP=$DEP_PATH/ironic-inspector
IRONIC_INSPECTOR_VER=4.2.0
IRONIC_INSPECTOR_SRC=$BASEPATH/ironic-inspector-$IRONIC_INSPECTOR_VER
tar -cvf $IRONIC_INSPECTOR_DEP/ironic-inspector-$IRONIC_INSPECTOR_VER.tar.gz ironic-inspector-$IRONIC_INSPECTOR_VER

mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp $IRONIC_INSPECTOR_DEP/* ~/rpmbuild/SOURCES
cp $IRONIC_INSPECTOR_DEP/openstack-ironic-inspector.spec ~/rpmbuild/SPECS

yum-builddep ~/rpmbuild/SPECS/openstack-ironic-inspector.spec -y

rpmbuild -bb ~/rpmbuild/SPECS/openstack-ironic-inspector.spec

mkdir -p rpms/ironic-inspector
cp ~/rpmbuild/RPMS/noarch/*.el7.noarch.rpm $BASEPATH/rpms/ironic-inspector

rm -rf $IRONIC_INSPECTOR_DEP/ironic-inspector-$IRONIC_INSPECTOR_VER.tar.gz
rm -rf ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

