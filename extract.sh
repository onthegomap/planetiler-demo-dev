#!/usr/bin/env bash
set -eux

indb="output.mbtiles"
outdir="mbtiles"

sqlite3 "$indb" 'pragma journal_mode = delete; pragma page_size = 1024; vacuum;'

rm -rf "$outdir"
mkdir -p "$outdir"

bytes="$(gstat --printf="%s" "$indb")"
prefix="$(date +%s)"
serverChunkSize=$((50 * 1024 * 1024))
suffixLength=3
gsplit "$indb" --bytes=$serverChunkSize "$outdir/$prefix-PART-" --suffix-length=$suffixLength --numeric-suffixes

# write a json config
echo '
{
    "serverMode": "chunked",
    "requestChunkSize": "1024",
    "databaseLengthBytes": '$bytes',
    "serverChunkSize": '$serverChunkSize',
    "urlPrefix": "'$prefix'-PART-",
    "suffixLength": '$suffixLength'
}
' > "$outdir/config.json"