# Parsed only when the layer meta-trowl is present: conf/layer.conf of meta-agl-bsp
# globs <collection name>/recipes*/*/*.bbappend for every layer collection in the build.
#
# `trowl scan` runs debugfs (e2fsprogs) to read ext4 images. The class trowl puts only <component>/usr/bin and usr/sbin of the
# native components on the scan PATH, but e2fsprogs installs debugfs to /sbin. Until meta-trowl fixes that PATH, trowl-native
# ships a wrapper in usr/bin that runs the debugfs of e2fsprogs-native. The wrapper finds it relative to its own location
# (<components>/<arch>/trowl-native/usr/bin -> <components>/<arch>/e2fsprogs-native), so no absolute path ends up in sstate.
do_install:append:class-native() {
    install -d ${D}${bindir}
    cat > ${D}${bindir}/debugfs <<'EOF'
#!/bin/sh
comp="$(cd "$(dirname "$0")/../../.." && pwd)"
for d in sbin usr/sbin bin usr/bin; do
    [ -x "$comp/e2fsprogs-native/$d/debugfs" ] && exec "$comp/e2fsprogs-native/$d/debugfs" "$@"
done
echo "debugfs of e2fsprogs-native not found below $comp" >&2
exit 127
EOF
    chmod 755 ${D}${bindir}/debugfs
}
