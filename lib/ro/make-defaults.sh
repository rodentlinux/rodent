# Generic defaults
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
CFLAGS='-O2 -pipe -ggdb'
CXXFLAGS='-O2 -pipe -ggdb'
LDFLAGS='-Wl,-O1,--sort-common,--as-needed,-z,relro'

# Architecture specific defaults
case $arch in
armv7hl)
  host='armv7hl-unknown-linux-gnueabi'
  ;;
rpi)
  host='armv6kz-rpi-linux-gnueabi'
  ;;
x86_64)
  host='x86_64-rodent-linux-gnu'
  ;;
quark)
  host='i586-quark-linux-gnu'
  ;;
mips|mipsel)
  host="${arch}-linux-gnu"
  ;;
*)
  echo "Unknown architecture '$arch'"
  exit 1
  ;;
esac
