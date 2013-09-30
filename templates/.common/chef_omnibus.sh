#!/bin/bash

# This is the current stable release to default to, with Omnibus patch level (e.g. 10.12.0-1)
# Note that the chef template downloads 'x.y.z' not 'x.y.z-r' which should be a duplicate of the latest -r
use_shell=0

prerelease="false"

# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

# Set the filename for a deb, based on version and machine
deb_filename() {
  filetype="deb"
  if [ "$machine" = "x86_64" ];
  then
    filename="chef_${version}_amd64.deb"
  else
    filename="chef_${version}_i386.deb"
  fi
}

# Set the filename for an rpm, based on version and machine
rpm_filename() {
  filetype="rpm"
  filename="chef-${version}.${machine}.rpm"
}

# Set the filename for a Solaris SVR4 package, based on version and machine
svr4_filename() {
  PATH=/usr/sfw/bin:$PATH
  filetype="solaris"
  filename="chef-${version}.${machine}.solaris"
}

# Set the filename for the sh archive
shell_filename() {
  filetype="sh"
  filename="chef-${version}-${platform}-${platform_version}-${machine}.sh"
}

report_bug() {
  echo "Please file a bug report at http://tickets.opscode.com"
  echo "Project: Chef"
  echo "Component: Packages"
  echo "Label: Omnibus"
  echo "Version: $version"
  echo " "
  echo "Please detail your operating system type, version and any other relevant details"
}

# Get command line arguments
while getopts spv: opt
do
  case "$opt" in
    v)  version="$OPTARG";;
    s)  use_shell=1;;
    p)  prerelease="true";;
    \?)   # unknown flag
      echo >&2 \
      "usage: $0 [-s] [-v version]"
      exit 1;;
  esac
done
shift `expr $OPTIND - 1`

machine=$(printf `uname -m`)

# Retrieve Platform and Platform Version
if [ -f "/etc/lsb-release" ] && grep -q DISTRIB_ID /etc/lsb-release;
then
  platform=$(grep DISTRIB_ID /etc/lsb-release | cut -d "=" -f 2 | tr '[A-Z]' '[a-z]')
  platform_version=$(grep DISTRIB_RELEASE /etc/lsb-release | cut -d "=" -f 2)
elif [ -f "/etc/debian_version" ];
then
  platform="debian"
  platform_version=$(printf `cat /etc/debian_version`)
elif [ -f "/etc/redhat-release" ];
then
  platform=$(sed 's/^\(.\+\) release.*/\1/' /etc/redhat-release | tr '[A-Z]' '[a-z]')
  platform_version=$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release)

  # If /etc/redhat-release exists, we act like RHEL by default
  if [ "$platform" = "fedora" ];
  then
    # Change platform version for use below.
    platform_version="6.0"
  fi
  platform="el"
elif [ -f "/etc/system-release" ];
then
  platform=$(sed 's/^\(.\+\) release.\+/\1/' /etc/system-release | tr '[A-Z]' '[a-z]')
  platform_version=$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/system-release | tr '[A-Z]' '[a-z]')
  # amazon is built off of fedora, so act like RHEL
  if [ "$platform" = "amazon linux ami" ];
  then
    platform="el"
    platform_version="6.0"
  fi
# Apple OS X
elif [ -f "/usr/bin/sw_vers" ];
then
  platform="mac_os_x"
  # Matching the tab-space with sed is error-prone
  platform_version=$(sw_vers | awk '/^ProductVersion:/ { print $2 }')

  major_version=$(echo $platform_version | cut -d. -f1,2)
  case $major_version in
    "10.6") platform_version="10.6" ;;
    "10.7") platform_version="10.7" ;;
    "10.8") platform_version="10.7" ;;
    *) echo "No builds for platform: $major_version"
       report_bug
       exit 1
       ;;
  esac

  # x86_64 Apple hardware often runs 32-bit kernels (see OHAI-63)
  x86_64=$(sysctl -n hw.optional.x86_64)
  if [ $x86_64 -eq 1 ]; then
    machine="x86_64"
  fi
elif [ -f "/etc/release" ];
then
  platform="solaris2"
  machine=$(/usr/bin/uname -p)
  platform_version=$(/usr/bin/uname -r)
elif [ -f "/etc/SuSE-release" ];
then
  if grep -q 'Enterprise' /etc/SuSE-release;
  then
      platform="sles"
      platform_version=$(awk '/^VERSION/ {V = $3}; /^PATCHLEVEL/ {P = $3}; END {print V "." P}' /etc/SuSE-release)
  else
      platform="suse"
      platform_version=$(awk '/^VERSION =/ { print $3 }' /etc/SuSE-release)
  fi
fi

if [ "x$platform" = "x" ];
then
  echo "Unable to determine platform version!"
  report_bug
  exit 1
fi

# Mangle $platform_version to pull the correct build
# for various platforms
major_version=$(echo $platform_version | cut -d. -f1)
case $platform in
  "el")
    case $major_version in
      "5") platform_version="5" ;;
      "6") platform_version="6" ;;
    esac
    ;;
  "debian")
    case $major_version in
      "5") platform_version="6";;
      "6") platform_version="6";;
    esac
    ;;
esac

if [ "x$platform_version" = "x" ];
then
  echo "Unable to determine platform version!"
  report_bug
  exit 1
fi

if [ $use_shell = 1 ];
then
  shell_filename
else
  case $platform in
    "ubuntu") deb_filename ;;
    "debian") deb_filename ;;
    "el") rpm_filename ;;
    "suse") rpm_filename ;;
    "sles") rpm_filename ;;
    "fedora") rpm_filename ;;
    "solaris2") svr4_filename ;;
    *) shell_filename ;;
  esac
fi

echo "Downloading Chef $version for ${platform}..."

url="http://www.opscode.com/chef/download?v=${version}&prerelease=${prerelease}&p=${platform}&pv=${platform_version}&m=${machine}"
tmp_dir=$(mktemp -d -t tmp.XXXXXXXX || echo "/tmp")

if exists wget;
then
  downloader="wget"
  wget -O "$tmp_dir/$filename" $url 2>/tmp/stderr
elif exists curl;
then
  downloader="curl"
  curl -L $url > "$tmp_dir/$filename"
else
  echo "Cannot find wget or curl - cannot install Chef!"
  exit 5
fi

# Check to see if we got a 404 or an empty file

unable_to_retrieve_package() {
  echo "Unable to retrieve a valid package!"
  report_bug
  echo "URL: $url"
  exit 1
}

if [ "$downloader" = "curl" ]
then
  #do curl stuff
  grep "The specified key does not exist." "$tmp_dir/$filename" 2>&1 >/dev/null
  if [ $? -eq 0 ] || [ ! -s "$tmp_dir/$filename" ]
  then
    unable_to_retrieve_package
  fi
elif [ "$downloader" = "wget" ]
then
  #do wget stuff
  grep "ERROR 404" /tmp/stderr 2>&1 >/dev/null
  if [ $? -eq 0 ] || [ ! -s "$tmp_dir/$filename" ]
  then
    unable_to_retrieve_package
  fi
fi

echo "Installing Chef $version"
case "$filetype" in
  "rpm") rpm -Uvh "$tmp_dir/$filename" ;;
  "deb") dpkg -i "$tmp_dir/$filename" ;;
  "solaris") echo "conflict=nocheck" > /tmp/nocheck
	     echo "action=nocheck" >> /tmp/nocheck
	     pkgadd -n -d "$tmp_dir/$filename" -a /tmp/nocheck chef
	     ;;
  "sh" ) bash "$tmp_dir/$filename" ;;
esac

if [ "$tmp_dir" != "/tmp" ];
then
  rm -r "$tmp_dir"
fi

if [ $? -ne 0 ];
then
  echo "Installation failed"
  report_bug
  exit 1
fi
