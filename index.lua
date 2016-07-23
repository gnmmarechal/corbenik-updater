--Corbenik/Skeith CFW Updater
--Author: gnmmarechal
--Runs on Lua Player Plus 3DS

-- Run updated index.lua: If a file is available on the server, that file will be downloaded and used instead.
-- Skipped if useupdate = 0
isupdate = 1


if (not System.doesFileExist("/skeith/firmware/native") and System.doesFileExist("/corbenik-updater/useskeith")) then -- Stops people without Skeith from using the wrong updater.
	System.deleteFile("/corbenik-updater/useskeith")
end
if (not System.doesFileExist("/skeith/lib/firmware/native") and System.doesFileExist("/corbenik-updater/useskeith")) then -- Stops people without Skeith from using the wrong updater.
	System.deleteFile("/corbenik-updater/useskeith")
end
if not System.doesFileExist("/corbenik/firmware/native") and System.doesFileExist("/skeith/firmware/native") then --If Corbenik isn't found but Skeith is, force Skeith updater.
	skeithstream = io.open("/corbenik-updater/useskeith",FCREATE)
	io.write(skeithstream,0,"SkeithCFW", 9)
	io.close(skeithstream)
end
if not System.doesFileExist("/corbenik/lib/firmware/native") and System.doesFileExist("/skeith/lib/firmware/native") then --If Corbenik isn't found but Skeith is, force Skeith updater. (new structure)
	skeithstream = io.open("/corbenik-updater/useskeith",FCREATE)
	io.write(skeithstream,0,"SkeithCFW", 9)
	io.close(skeithstream)
end
useupdate = 0
updateserverlua = "http://gs2012.xyz/3ds/corbenikupdater/updatedindex.lua"
skeithupdateserverlua = "http://gs2012.xyz/3ds/skeithupdater/updatedindex.lua"
System.createDirectory("/corbenik-updater")
System.createDirectory("/skeith-updater")
--[[
if System.doesFileExist("/skeith-updater/updatedindex.lua") then
	System.deleteFile("/skeith-updater/updatedindex.lua")
end
if System.doesFileExist("/corbenik-updater/updatedindex.lua") then
	System.deleteFile("/corbenik-updater/updatedindex.lua")
end
--]]
if not Network.isWifiEnabled() then --Checks for Wi-Fi
	error("Failed to connect to the network.")
end
if (not System.doesFileExist("/corbenik/firmware/native") and (not System.doesFileExist("/skeith/firmware/native"))) and (not System.doesFileExist("/corbenik/lib/firmware/native")) and (not System.doesFileExist("/skeith/lib/firmware/native")) then -- Avoids people without Corbenik or Skeith on their SD Card from using the updater.
	error("Corbenik/Skeith CFW not found. Please install one or both.")
end
--Switches to Skeith script if setting is found.

if System.doesFileExist("/corbenik-updater/useskeith") then -- Checks if it should switch to Skeith AND if Corbenik exists. If not, it'll default to Skeith.
	skeithusage = 1
	if System.doesFileExist("/skeith-updater/updatedindex.lua") then
		System.deleteFile("/skeith-updater/updatedindex.lua")
	end
	Network.downloadFile(skeithupdateserverlua, "/skeith-updater/updatedindex.lua")
	dofile("/skeith-updater/updatedindex.lua")
	System.exit()	
else
	skeithusage = 0

end

--[[
if System.doesFileExist("romfs:/skeithindex.lua") and skeithusage == 1 then
elseif not System.doesFileExist("romfs:/skeithindex.lua") and skeithusage == 1 then
	if System.doesFileExist("/skeith-updater/updatedindex.lua") then
		System.deleteFile("/skeith-updater/updatedindex.lua")
	end
	Network.downloadFile(skeithupdateserverlua, "/skeith-updater/updatedindex.lua")
	dofile("/skeith-updater/updatedindex.lua")
	System.exit()	
end
--]]
--[[
-- Update script
if isupdate == 0 then
	coremajor = 0
	coreminor = 3
	corerev = 0
	coreversionstring = coremajor.."."..coreminor.."."..corerev
end
--]]
if System.doesFileExist("/corbenik-updater/useupdate") then
	if isupdate == 0 then
		useupdate = 1
	else
		useupdate = 0
	end
else
	useupdate = 0
end
if (Network.isWifiEnabled()) and useupdate == 1 then
	if System.doesFileExist("/corbenik-updater/updatedindex.lua") then
		System.deleteFile("/corbenik-updater/updatedindex.lua")
	end
	Network.downloadFile(updateserverlua, "/corbenik-updater/updatedindex.lua")
	dofile("/corbenik-updater/updatedindex.lua")
	System.exit()
end	
--End

--Sound init for BGM :)
if System.doesFileExist("/corbenik-updater/usebgm") or System.doesFileExist("/skeith-updater/usebgm") then
	if System.doesFileExist("/3ds/dspfirm.cdc") then --csnd seems glitchy. I'll disable BGM for older releases of lpp.
		usebgm = 1
	else
		usebgm = 0
	end
else
	usebgm = 0
end
if usebgm == 1 then 
	Sound.init()
	if System.doesFileExist("romfs:/bgm.wav") then
		bgm = Sound.openWav("romfs:/bgm.wav",false)
		Sound.play(bgm,LOOP)
	end
	if System.doesFileExist("/3ds/corbenikupdater/bgm.wav") then
		bgm = Sound.openWav("/3ds/corbenikupdater/bgm.wav",false)
		Sound.play(bgm,LOOP)
	end
	if System.doesFileExist("/corbenik-updater/bgm.wav") then
		bgm = Sound.openWav("/corbenik-updater/bgm.wav",false)
		Sound.play(bgm,LOOP)
	elseif System.doesFileExist("/corbenik-updater/bgm.ogg") then
		bgm = Sound.openOgg("/corbenik-updater/bgm.ogg",false)	
		Sound.play(bgm,LOOP)
	elseif System.doesFileExist("/corbenik-updater/bgm.aiff") then
		bgm = Sound.openAiff("/corbenik-updater/bgm.aiff",false)
		Sound.play(bgm,LOOP)
	end	
end

--Some variables
System.currentDirectory("/")
root = System.currentDirectory()
consolehbdir = root.."3ds/"
consoleerror = 0
scr = 1
oldpad = Controls.read()
debugmode = 1
updatechecked = 0
setnight = 0
MAX_RAM_ALLOCATION = 10485760

--App details
versionmajor = 0
versionminor = 6
versionrev = 0
versionstring = versionmajor.."."..versionminor.."."..versionrev
versionrelno = 3
selfname = "corbenikupdater"
selfpath = consolehbdir..selfname.."/"
selfexepath = selfpath..selfname..".3dsx" -- This is for the 3DSX version only
selfstring = "Corbenik CFW Updater v."..versionstring
selfauthor = "gnmmarechal"
newstructure = 1 -- By default 0 for the current stable doesn't use it, but the next nightly might use it.

--Affected app details
appname = "Corbenik CFW"
appinstallname = "corbenik"
appinstallpath = root
downloadedzip = root..appinstallname..".zip"
cfwpath = appinstallpath..appinstallname
config = root..appinstallname.."-updater.cfg"
usechainpayload = root..appinstallname.."-updater/nochain"
nightlyfile = root..appinstallname.."-updater/usenightly"

--Server strings (some vars are declared by functions after reading the strings from the server)
serverpath = "http://gs2012.xyz/3ds/"..selfname.."/"
servergetnochainzippath = serverpath.."latest.txt"
servergetchainzippath = serverpath.."chainlatest.txt"
servergetnightlyzippath = serverpath.."latest-nightly.txt" 
servergetzipver = serverpath.."version.txt"
servergetziprel = serverpath.."rel.cfg"


-- Colours
white = Color.new(255,255,255)
green = Color.new(0,240,32)
red = Color.new(255,0,0)
yellow = Color.new(255,255,0)

--Update-check functions

--Variables
serverhashbaseurl = "http://gs2012.xyz/3ds/corbenikupdater/"
serverhashext = ".sha512"
localhashdl = root..appinstallname.."-updater/newhash.sha512"
localcurrenthash = root..appinstallname.."-updater/currenthash.sha512"


--Hash URLs for the various versions
serverhashurlstable = "latest-chain"
serverhashurlstablenochain = "latest"
serverhashurlnightly = "latest-nightly"
nightlyhash = 0

function sethashurl(mode)
	if mode == 0 then --nochain
		serverhashurl = serverhashbaseurl..serverhashurlstablenochain..serverhashext
	elseif mode == 1 then
		serverhashurl = serverhashbaseurl..serverhashurlstable..serverhashext
	elseif mode == 2 then
		serverhashurl = serverhashbaseurl..serverhashurlnightly..serverhashext
		nightlyhash = 1
	end
end

function comparehash()
	Network.downloadFile(serverhashurl,localhashdl)
	if System.doesFileExist(localcurrenthash) then
		localhashstream = io.open(localcurrenthash, FREAD)
		localshahash = io.read(localhashstream,0,128)
		io.close(localhashstream)
	else
		localhashstream = io.open(localcurrenthash, FCREATE)
		io.write(localhashstream, 0, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 128)
		System.deleteFile(localhashdl)
		io.close(localhashstream)
		comparehash()
	end
	serverhashstream = io.open(localhashdl, FREAD)
	servershahash = io.read(serverhashstream, 0,128)
	io.close(serverhashstream)
	if servershahash == localshahash then
		updated = 1
		forcehashupdate = 0
	else
		updated = 0
		forcehashupdate = 1
	end
end

function updatehash()
	if System.doesFileExist(localcurrenthash) then
		System.deleteFile(localcurrenthash)
	end
	if System.doesFileExist(localhashdl) then
		System.deleteFile(localhashdl)
	end
	Network.downloadFile(serverhashurl,localcurrenthash)
end

--Old stuff

function checkupdate() --Checks for new version of Corbenik CFW -- Apparently broken
	if updatechecked == 0 then
		if System.doesFileExist("/corbenikupdater/cfw-rel.cfg") then
			relstream = io.open("/corbenikupdater/cfw-rel.cfg",FREAD)
			localrel = io.read(relstream,0,io.size(relstream))
			if tonumber(localrel) >= tonumber(serverrel) then
				updated = 1
			end
			updatechecked = 1
		else
			System.createDirectory("/corbenikupdater")
			Network.downloadFile(servergetziprel, "/corbenikupdater/cfw-rel.cfg")
			updatechecked = 1
		end
	end
end

-- Server/network functions
function iswifion()
	if (Network.isWifiEnabled()) or updated == 1 then
		return 1
	else
		consoleerror = 1
		scr = 0
		return 0
	end	
end


function servergetVars()
	if iswifion() == 1 then
		serverzippath = Network.requestString(servergetzippath)
		serverver = Network.requestString(servergetzipver)
		serverrel = Network.requestString(servergetziprel)
		if 	usenightly == 1 then
			servernightlyzippath = Network.requestString(servergetnightlyzippath)
		end
	end
end

--System functions
function fileCopy(input, output)
		inp = io.open(input,FREAD)
	if System.doesFileExist(output) then
		System.deleteFile(output)
	end
	out = io.open(output,FCREATE)
	size = io.size(inp)
	index = 0
	while (index+(MAX_RAM_ALLOCATION/2) < size) do
		io.write(out,index,io.read(inp,index,MAX_RAM_ALLOCATION/2),(MAX_RAM_ALLOCATION/2))
		index = index + (MAX_RAM_ALLOCATION/2)
	end
	if index < size then
		io.write(out,index,io.read(inp,index,size-index),(size-index))
	end
	io.close(inp)
	io.close(out)
end
function clear()

	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
end 

function flip()
	Screen.flip()
	Screen.waitVblankStart()
	oldpad = pad
end
function waitloop()
	loop = 0
end
function quit()
	if bgm == nil then
	
	else
		Sound.close(bgm)
	end
	Sound.term()
	System.exit()
end

function runoncevars()
	checkedicon = 0
end
updated = 0
skipped = 0
--Input functions
function inputscr(newscr, inputkey)
	if Controls.check(pad,inputkey) and not Controls.check(oldpad,inputkey) then
		if newscr == -1 then
			quit()
		end
		if newscr == -4 then
			if bgm == nil then
			else
				Sound.close(bgm)
			end
			Sound.term()
			System.reboot()
		end
		Screen.clear(TOP_SCREEN)
		scr = newscr
	end	
end

function nextscr(skrin)
	
	inputscr(skrin, KEY_A)
end

function checkreboot()
	inputscr(-4, KEY_A)
end
function checkquit()
	inputscr(-1, KEY_B)
end

function checkrestart()
	inputscr(-3, KEY_R)
end

function endquit()
	inputscr(-1, KEY_A)
end

--Installer functions
function precleanup()
	if System.doesFileExist(downloadedzip) then
		System.deleteFile(downloadedzip)
	end
end

function precheck()
	if System.getModel() == 2 or System.getModel() == 4 then
		System.setCpuSpeed(NEW_3DS_CLOCK)
		newconsole = 1
	else
		newconsole = 0
	end	
	if System.doesFileExist(usechainpayload) then
		servergetzippath = servergetnochainzippath
		sethashurl(0)
	else
		servergetzippath = servergetchainzippath
		sethashurl(1)
	end
	if System.doesFileExist(nightlyfile) then
		servergetzippathnight = servergetnightlyzippath
		usenightly = 1
		sethashurl(2)
	else
		usenightly = 0
	end
	if (not System.doesFileExist(cfwpath.."/firmware/native")) or (not System.doesFileExist(cfwpath.."/lib/firmware/native")) then
		usenightly = 0
		if System.doesFileExist(usechainpayload) then
			servergetzippath = servergetnochainzippath
		else
			servergetzippath = servergetchainzippath
		end
		newinstall = 1
	else
		newinstall = 0
	end
	if System.doesFileExist(config) then
		configstream = io.open(config,FREAD)
		armpayloadpath = io.read(configstream,0,io.size(configstream))
	else
		armpayloadpath = root.."arm9loaderhax.bin"
		if System.doesFileExist("/arm9loaderhax_si.bin") then
			setconfigstream = io.open(config,FCREATE)
			io.write(setconfigstream,0,"/arm9loaderhax_si.bin", 21)
			io.close(setconfigstream)
			precheck() --Calls itself again after setting the payload path to arm9loaderhax_si.bin.
		end
	end
	if nightlyhash == 0 then
		comparehash()
	end	
	
end

function installfilechecker()	
	if newinstall == 1 then
		if not System.doesFileExist("/corbenik-updater/firmware.bin") then
		
		end
	end
end
--Data migration function (to upgrade to the new directory structure while keeping the data)
function migrate()
	if migrationon == 1 then
		if keepconfig == 1 then --Moving Config
			if System.doesFileExist(cfwpath.."/config/main.conf") then
				System.renameDirectory(cfwpath.."/config", cfwpath.."/etc")
			end
		end	
		--Moving firmwares
		if (System.doesFileExist(cfwpath.."/firmware/native")) or (System.doesFileExist(cfwpath.."/firmware/agb")) or (System.doesFileExist(cfw.."/firmware/twl")) then
			System.createDirectory(cfwpath.."/lib")
			System.renameDirectory(cfwpath.."/firmware", cfwpath.."/lib/firmware")
		end
		--Moving keys
		if (System.doesFileExist(cfwpath.."/keys/native.key")) or (System.doesFileExist(cfwpath.."/keys/agb.key")) or (System.doesFileExist(cfwpath.."/keys/twl.key")) or (System.doesFileExist(cfwpath.."/keys/agb.cetk")) or (System.doesFileExist(cfwpath.."/keys/twl.cetk")) or (System.doesFileExist(cfwpath.."/keys/11key96.key")) then
			System.createDirectory(cfwpath.."/share")
			System.renameDirectory(cfwpath.."/keys", cfwpath.."/share/keys")
		end
		--Moving splash screens
		if (System.doesFileExist(cfwpath.."/bits/top.bin")) then
			System.createDirectory(cfwpath.."/share")
			System.renameFile(cfwpath.."/bits/top.bin", cfwpath.."/share/top.bin")
		end
		if (System.doesFileExist(cfwpath.."/bits/bottom.bin")) then
			System.createDirectory(cfwpath.."/share")
			System.renameFile(cfwpath.."/bits/bottom.bin", cfwpath.."/share/bottom.bin")
		end
		--Moving termfont.bin
		if (System.doesFileExist(cfwpath.."/bits/termfont.bin")) then
			System.createDirectory(cfwpath.."/share")
			System.renameFile(cfwpath.."/bits/termfont.bin", cfwpath.."/share/termfont.bin")		
		end
		--Moving cache
		System.createDirectory(cfwpath.."/var")
		System.renameDirectory(cfwpath.."/cache", cfwpath.."/var/cache")
		--Moving chain payloads
			System.createDirectory(cfwpath.."/chain")
			System.renameDirectory(cfwpath.."/chain", cfwpath.."/boot")
	else -- Reverse migration function
		if keepconfig == 1 then --Moving Config
			if System.doesFileExist(cfwpath.."/etc/main.conf") then
				System.renameDirectory(cfwpath.."/etc", cfwpath.."/config")
			end
		end	
		--Moving firmwares
		if (System.doesFileExist(cfwpath.."/lib/firmware/native")) or (System.doesFileExist(cfwpath.."/lib/firmware/agb")) or (System.doesFileExist(cfw.."/lib/firmware/twl")) then
			System.renameDirectory(cfwpath.."/lib/firmware", cfwpath.."/firmware")
		end
		--Moving keys
		if (System.doesFileExist(cfwpath.."/share/keys/native.key")) or (System.doesFileExist(cfwpath.."/share/keys/agb.key")) or (System.doesFileExist(cfwpath.."/share/keys/twl.key")) or (System.doesFileExist(cfwpath.."/share/keys/agb.cetk")) or (System.doesFileExist(cfwpath.."/share/keys/twl.cetk")) or (System.doesFileExist(cfwpath.."/share/keys/11key96.key")) then
			System.renameDirectory(cfwpath.."/share/keys", cfwpath.."/keys")
		end
		--Moving splash screens
		if (System.doesFileExist(cfwpath.."/libexec/top.bin")) then
			System.createDirectory(cfwpath.."/bits")
			System.renameFile(cfwpath.."/libexec/top.bin", cfwpath.."/bits/top.bin")
		end
		if (System.doesFileExist(cfwpath.."/libexec/bottom.bin")) then
			System.createDirectory(cfwpath.."/bits")
			System.renameFile(cfwpath.."/libexec/bottom.bin", cfwpath.."/bits/bottom.bin")
		end
		--Moving cache
		System.renameDirectory(cfwpath.."/var/cache", cfwpath.."/cache")
		--Moving chain payloads
			System.createDirectory(cfwpath.."/boot")
			System.renameDirectory(cfwpath.."/boot", cfwpath.."/chain")
	end
end

function installnewunixstructure()
	headflip = 1
	migrationon = 1
	head()
	debugWrite(0,60,"Downloading ZIP...", white, TOP_SCREEN)
	if updated == 0 then
		Network.downloadFile(serverzippath, downloadedzip)
	end
	debugWrite(0,80,"Backing up old files...", red, TOP_SCREEN)
	if updated == 0 then
		migrate()
		h,m,s = System.getTime()
		day_value,day,month,year = System.getDate()
		System.renameDirectory(cfwpath,root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year)
		System.renameFile(armpayloadpath,armpayloadpath.."-BACKUP-"..h..m..s..day_value..day..month..year)
	end
	debugWrite(0,100,"Extracting to path...", white, TOP_SCREEN)
	if updated == 0 then
		System.renameFile("/arm9loaderhax.bin", "/arm9loaderhax".."-BACKUP-"..h..m..s..day_value..day..month..year..".bin")
		System.renameFile("/arm9loaderhax_si.bin", "/arm9loaderhax_si".."-BACKUP-"..h..m..s..day_value..day..month..year..".bin")
		System.extractZIP(downloadedzip,appinstallpath)
		System.deleteFile("/arm9loaderhax.bin")
		System.extractFromZIP(downloadedzip,"arm9loaderhax.bin",armpayloadpath)
		if not System.doesFileExist("/arm9loaderhax.bin") and not System.doesFileExist("/arm9loaderhax_si.bin") then
			System.renameFile("/arm9loaderhax_si".."-BACKUP-"..h..m..s..day_value..day..month..year..".bin", "/arm9loaderhax_si.bin")
			System.renameFile("/arm9loaderhax".."-BACKUP-"..h..m..s..day_value..day..month..year..".bin", "/arm9loaderhax.bin")
		end
		System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/lib/firmware",cfwpath.."/lib/firmware")
		System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/share/keys",cfwpath.."/share/keys")
		if keepconfig == 1 then
			System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/etc",cfwpath.."/etc")
			System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/var/cache",cfwpath.."/var/cache")
			System.createDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/etc")
			fileCopy(cfwpath.."/etc".."/main.conf",root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/etc".."/main.conf")
		end
		if System.doesFileExist(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/libexec/top.bin") then
			System.renameFile(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/libexec/top.bin", cfwpath.."/libexec/top.bin")
		end
		if System.doesFileExist(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/libexec/bottom.bin") then
			System.renameFile(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/libexec/bottom.bin", cfwpath.."/libexec/bottom.bin")
		end
		System.createDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/boot")
		System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/boot",cfwpath.."/boot")
		if isnightly == 1 then
			System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/share/locale/emu",cfwpath.."/share/locale/emu")
			System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/bin",cfwpath.."/bin")
		end
		System.deleteFile(downloadedzip)
		if nightlyhash == 0 then
			updatehash()
		end
	end
	debugWrite(0,120,"DONE! Press A to reboot, B to quit!", green, TOP_SCREEN)
	updated = 1
end

function installnew()
	headflip = 1
	head()
	debugWrite(0,60,"Downloading ZIP...", white, TOP_SCREEN)
	if updated == 0 then
		Network.downloadFile(serverzippath, downloadedzip)
	end
	debugWrite(0,80,"Backing up old files...", red, TOP_SCREEN)
	if updated == 0 then
		migrate()
		h,m,s = System.getTime()
		day_value,day,month,year = System.getDate()
		System.renameDirectory(cfwpath,root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year)
		System.renameFile(armpayloadpath,armpayloadpath.."-BACKUP-"..h..m..s..day_value..day..month..year)
	end
	debugWrite(0,100,"Extracting to path...", white, TOP_SCREEN)
	if updated == 0 then
		System.renameFile("/arm9loaderhax.bin", "/arm9loaderhax".."-BACKUP-"..h..m..s..day_value..day..month..year..".bin")
		System.renameFile("/arm9loaderhax_si.bin", "/arm9loaderhax_si".."-BACKUP-"..h..m..s..day_value..day..month..year..".bin")
		System.extractZIP(downloadedzip,appinstallpath)
		System.deleteFile("/arm9loaderhax.bin")
		System.extractFromZIP(downloadedzip,"arm9loaderhax.bin",armpayloadpath)
		if not System.doesFileExist("/arm9loaderhax.bin") and not System.doesFileExist("/arm9loaderhax_si.bin") then
			System.renameFile("/arm9loaderhax_si".."-BACKUP-"..h..m..s..day_value..day..month..year..".bin", "/arm9loaderhax_si.bin")
			System.renameFile("/arm9loaderhax".."-BACKUP-"..h..m..s..day_value..day..month..year..".bin", "/arm9loaderhax.bin")
		end
		System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/firmware",cfwpath.."/firmware")
		System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/keys",cfwpath.."/keys")
		if keepconfig == 1 then
			System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/config",cfwpath.."/config")
			System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/cache",cfwpath.."/cache")
			System.createDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/config")
			fileCopy(cfwpath.."/config".."/main.conf",root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/config".."/main.conf")
		end
		if System.doesFileExist(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/bits/top.bin") then
			System.renameFile(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/bits/top.bin", cfwpath.."/bits/top.bin")
		end
		if System.doesFileExist(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/bits/bottom.bin") then
			System.renameFile(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/bits/bottom.bin", cfwpath.."/bits/bottom.bin")
		end
		System.createDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/chain")
		System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/chain",cfwpath.."/chain")
		if isnightly == 1 then
			System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/locale",cfwpath.."/locale")
			System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/contrib",cfwpath.."/contrib")
		end
		System.deleteFile(downloadedzip)
		if nightlyhash == 0 then
			updatehash()
		end
	end
	debugWrite(0,120,"DONE! Press A to reboot, B to quit!", green, TOP_SCREEN)
	updated = 1
end

--UI Screens

function head() -- Head of all screens
	if headflip == 1 then
		debugWrite(0,0,selfstring, white, TOP_SCREEN)
		debugWrite(0,20,"==============================", red, TOP_SCREEN)	
	end
	Screen.debugPrint(0,0,selfstring, white, TOP_SCREEN)
	Screen.debugPrint(0,20,"==============================", red, TOP_SCREEN)	
end

function errorscreen() --scr == 0
	head()
	Screen.debugPrint(0,40,"An error has occurred.", white, TOP_SCREEN)
	Screen.debugPrint(0,60,"Please refer to the documentation.", white, TOP_SCREEN)
	Screen.debugPrint(0,80,"Error code: "..consoleerror, red, TOP_SCREEN)
	Screen.debugPrint(0,100,"Press A/B to quit.", white, TOP_SCREEN)
	checkquit()
	endquit()
end

function lowhead()
	Screen.debugPrint(0,0,selfstring, white, BOTTOM_SCREEN)
end

function bottomscreen(no) -- if no = 1, the original, regular screen will show. If not, an error-screen will come up.
	lowhead()
	if no == 1 then	
		Screen.debugPrint(0,20,"Latest CFW: "..serverver, green, BOTTOM_SCREEN)
--		Screen.debugPrint(0,20,"Core Version: "..coreversionstring, white, BOTTOM_SCREEN)
		Screen.debugPrint(0,40,"Author: gnmmarechal", white, BOTTOM_SCREEN)
		Screen.debugPrint(0,60,"Special Thanks:", white, BOTTOM_SCREEN)
		Screen.debugPrint(0,80,"Rinnegatamante (LPP-3DS/Help)", white, BOTTOM_SCREEN)
		Screen.debugPrint(0,100,"Crystal the Glaceon (Testing)", white, BOTTOM_SCREEN)
		Screen.debugPrint(0,120,"chaoskagami (Corbenik CFW)", white, BOTTOM_SCREEN)
--		Screen.debugPrint(0,160,"Portugal Euro 2016!!!!", red, BOTTOM_SCREEN)
--		Screen.debugPrint(0,180,"Portugal Euro 2016!!!!", yellow, BOTTOM_SCREEN)
--		Screen.debugPrint(0,200,"Portugal Euro 2016!!!!", green, BOTTOM_SCREEN)
		--Screen.debugPrint(0,120,Sound.getService(), white, BOTTOM_SCREEN) -- Displays used audio-service
	else
		Screen.debugPrint(0,20,"Internet connection failed.", red, BOTTOM_SCREEN)
	end
	
end

function firstscreen() -- scr == 1
	head()
	Screen.debugPrint(0,40,"Welcome to Corbenik CFW Updater!", white, TOP_SCREEN)
	Screen.debugPrint(0,100,"Please select an option:", white, TOP_SCREEN)
	Screen.debugPrint(0,120,"A) Clean Update (Recommended)", white, TOP_SCREEN)
	Screen.debugPrint(0,140,"X) Dirty Update (Keep Config)", white, TOP_SCREEN)
	if usenightly == 1 then
		Screen.debugPrint(0,160,"Y) Nightly Update (Keep Config)", white, TOP_SCREEN)	
	end
	Screen.debugPrint(0,180,"B) Quit", white, TOP_SCREEN)
	inputscr(2, KEY_A)
	inputscr(4, KEY_X)
	inputscr(5, KEY_Y)
	if debugmode == 1 then
		inputscr(-2, KEY_L)
	end
	checkquit()
end

function installer() --scr == 2 / scr == 4
	head()
	debugWrite(0,40,"Started Installation...", white, TOP_SCREEN)
	if newstructure == 1 then
		installnewunixstructure()
	else
		installnew()
	end
	checkquit()
	checkreboot()
	checkrestart()
end



--Prints text

function debugWrite(x,y,text,color,display)
	if updated == 1 or downloadcompleted == 1 then
		Screen.debugPrint(x,y,text,color,display)
	else
		i = 0
	
		while i < 2 do
			Screen.refresh()
			Screen.debugPrint(x,y,text,color,display)
			Screen.waitVblankStart()
			Screen.flip()
			i = i + 1
		
		end
	end
end
--Main loop

--checkupdate()
runoncevars()
iswifion()
precheck()
servergetVars()
precleanup()


while true do
	clear()

	pad = Controls.read()
	bottomscreen(iswifion())
	if scr == 5 and usenightly == 1 then
		serverzippath = servernightlyzippath
		isnightly = 1
		keepconfig = 1
		--newstructure = 1 -- This will be used when a nighly supporting the new structure comes out. Till then, it won't work as it'll try to migrate data.
		installer()
	end	
	if scr == 4 then
		isnightly = 0
		keepconfig = 1
		installer()
	end
	if scr == 2 then
		isnightly = 0
		keepconfig = 0
		installer()
	end	
	if scr == 0 then
		errorscreen()
	end
	if scr == 1 then
		firstscreen()
	end

	if scr == -2 then
		error("Debug Break")
	end
	if scr == -3 then
		error("Program ended")
	end

	iswifion()
	flip()
end