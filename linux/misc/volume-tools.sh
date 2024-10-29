# luks aliases

lopen() {
  DEV_PARTITION=$1
  LUKS_PARTITION=$2
  sudo cryptsetup luksOpen /dev/${DEV_PARTITION} ${LUKS_PARTITION}
}

lclose() {
  LUKS_PARTITION=$1
  sudo cryptsetup luksClose ${LUKS_PARTITION}
}

# mount aliases

smount() {
  DEV_PARTITION=$1
  MNT_MOUNTPOINT=$2
  sudo mount /dev/${DEV_PARTITION} /mnt/${MNT_MOUNTPOINT}
}

sumount() {
  MNT_MOUNTPOINT=$1
  sudo umount /mnt/${MNT_MOUNTPOINT}
}
