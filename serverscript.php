<?php
echo "Corbenik/Skeith CFW Updater Server Script"."<br>";
echo "<title>Corbenik/Skeith CFW Updater Server Script</title>";
//Download new build
echo "\r\nDownloading latest build..."."<br>";
file_put_contents("../corbenikupdater/skeith.zep", file_get_contents("https://github.com/chaoskagami/skeith/raw/master/rel/release.zip"));
echo "\r\nDownloading latest build (no chain)..."."<br>";
file_put_contents("../corbenikupdater/skeith-nochain.zep", file_get_contents("https://github.com/chaoskagami/skeith/raw/master/rel/release.zip"));
echo "\r\nDownloading SHA-512 hashes..."."<br>";
file_put_contents("../corbenikupdater/skeith-nochain.sha512", file_get_contents("https://github.com/chaoskagami/skeith/raw/master/rel/release.zip.sha512"));
file_put_contents("../corbenikupdater/skeith.sha512", file_get_contents("https://github.com/chaoskagami/skeith/raw/master/rel/release.zip.sha512"));
echo "\r\nDone! http://gs2012.xyz"."<br>";
?>