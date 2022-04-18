:: example AWS S3 remote storage mounting using rclone with optimized parameters
::
:: data is then available for local use without moving off remote storage
::
:: https://rclone.org/
:: https://rclone.org/commands/rclone_mount/
rclone mount --no-checksum --transfers 64 --no-checksum --network-mode --vfs-write-back 5m --vfs-cache-mode full --file-perms 0777 --dir-perms 0777 remote:rech-dropbox/path-to-data-toplevel-folder Y:
