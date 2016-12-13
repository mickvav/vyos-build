#!/bin/bash

NTHREADS=2

for i in packages/*; do if [ -d $i ]; then git submodule update --init $i; fi; done

if [ ! -f packages/linux-image-*-vyos_*.deb ]; then 
   echo "Rebuilding kernel"
   (cd packages/vyos-kernel;LOCALVERSION= make-kpkg --rootcmd fakeroot --initrd --append_to_version -amd64-vyos --revision=4.4.6-1+vyos1+current1 kernel_source kernel_debug kernel_headers kernel_manual kernel_doc kernel_image)
fi;

for i in packages/*; do
  if [ "$i" = packages/xtables-addons ]; then
     if [ -f packages/xtables-addons-common*.deb ]; then
        echo "xtables-addons already built."
     else
        (cd "$i"; dpkg-vuildpackage -b -d -j$NTHREADS )
     fi
  else
   if [ -d "$i" ]; then
    for package_name in `cat $i/debian/control| grep Package| awk '{print $2;};'`; do
      if [ -d "$i" -a ! "$i" = "packages/vyos-kernel" -a ! -f "$package_name*.deb" ]; then
        echo "Rebuilding $i"
        (cd "$i"; dpkg-buildpackage -d -j$NTHREADS )
      fi
    done
   fi
  fi
done
