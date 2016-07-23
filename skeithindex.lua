--Skeith CFW Updater (Merged from https://github.com/gnmmarechal/skeith-updater into Corbenik Updater)
--Author: gnmmarechal
--Runs on Lua Player Plus 3DS

-- Run updated index.lua: If a file is available on the server, that file will be downloaded and used instead.
-- Skipped if useupdate = 0
isupdate = 1 -- This isn't to be changed on the Skeith script.

useupdate = 0
updateserverlua = "http://gs2012.xyz/3ds/skeithupdater/updatedindex.lua"
System.createDirectory("/skeith-updater")

if System.doesFileExist("/skeith-updater/useupdate") or System.doesFileExist("/corbenik-updater/useupdate") then
	if isupdate == 0 then
		useupdate = 1
	else
		useupdate = 0
	end
else
	useupdate = 0
end
if (Network.isWifiEnabled()) and useupdate == 1 then
	if System.doesFileExist("/skeith-updater/updatedindex.lua") then
		System.deleteFile("/skeith-updater/updatedindex.lua")
	end
	Network.downloadFile(updateserverlua, "/skeith-updater/updatedindex.lua")
	dofile("/skeith-updater/updatedindex.lua")
	System.exit()
end	
--End
if (not System.doesFileExist("/skeith/firmware/native")) and (not System.doesFileExist("/skeith/lib/firmware/native")) then -- Stops people without Skeith from using the wrong updater.
	error("Skeith CFW Missing.")
end
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
	if System.doesFileExist("/3ds/skeithupdater/bgm.wav") then
		bgm = Sound.openWav("/3ds/skeithupdater/bgm.wav",false)
		Sound.play(bgm,LOOP)
	end
	if System.doesFileExist("/skeith-updater/bgm.wav") then
		bgm = Sound.openWav("/skeith-updater/bgm.wav",false)
		Sound.play(bgm,LOOP)
	elseif System.doesFileExist("/skeith-updater/bgm.ogg") then
		bgm = Sound.openOgg("/skeith-updater/bgm.ogg",false)	
		Sound.play(bgm,LOOP)
	elseif System.doesFileExist("/skeith-updater/bgm.aiff") then
		bgm = Sound.openAiff("/skeith-updater/bgm.aiff",false)
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
MAX_RAM_ALLOCATION = 10485760

--App details
versionmajor = 0
versionminor = 6
versionrev = 0
versionstring = versionmajor.."."..versionminor.."."..versionrev
versionrelno = 1
selfname = "skeithupdater"
selfpath = consolehbdir..selfname.."/"
selfexepath = selfpath..selfname..".3dsx" -- This is for the 3DSX version only
selfstring = "Skeith CFW Updater v."..versionstring
selfauthor = "gnmmarechal"
newstructure = 1

--Affected app details
appname = "Skeith CFW"
appinstallname = "skeith"
appinstallpath = root
downloadedzip = root..appinstallname..".zip"
cfwpath = appinstallpath..appinstallname
config = root..appinstallname.."-updater.cfg"
usechainpayload = root..appinstallname.."-updater/nochain"

--Server strings (some vars are declared by functions after reading the strings from the server)
serverpath = "http://gs2012.xyz/3ds/"..selfname.."/"
servergetnochainzippath = serverpath.."latest-skeith.txt" --This is wrong
servergetchainzippath = serverpath.."latest-skeith-nochain.txt" --This is wrong. The nochain txt downloads the chainloader=1 release. This is because I set these variables wrong, but, to avoid re-releasing, ended up switching the values on the server instead.


-- Colours
white = Color.new(255,255,255)
green = Color.new(0,240,32)
red = Color.new(255,0,0)
yellow = Color.new(255,255,0)

--Update-check functions

--Variables
serverhashbaseurl = "http://gs2012.xyz/3ds/corbenikupdater/"
serverhashext = ".sha512"

--Hash URLs for the various versions
serverhashurlstable = "skeith"
serverhashurlstablenochain = "skeith-nochain"



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
	else
		servergetzippath = servergetchainzippath
	end
	if (not System.doesFileExist(cfwpath.."/firmware/native")) and (not System.doesFileExist(cfwpath.."/lib/firmware/native")) then
		usenightly = 0
		error("File not found. Please properly install Skeith CFW.") --TO ADD: Copy required files from the Corbenik directory if it exists.
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
	
end

function installfilechecker()	
	if newinstall == 1 then
		if not System.doesFileExist("/skeith-updater/firmware.bin") then
		
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
	else -- Reverse migration function?
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
		System.renameDirectory(cfwpath.."/var", cfwpath.."/cache")		
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
		System.deleteFile(downloadedzip)
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
		Screen.debugPrint(0,20,"Latest CFW: ".."NIGHTLY", green, BOTTOM_SCREEN)
--		Screen.debugPrint(0,20,"Core Version: "..coreversionstring, white, BOTTOM_SCREEN)
		Screen.debugPrint(0,40,"Author: gnmmarechal", white, BOTTOM_SCREEN)
		Screen.debugPrint(0,60,"Special Thanks:", white, BOTTOM_SCREEN)
		Screen.debugPrint(0,80,"Rinnegatamante (LPP/Help)", white, BOTTOM_SCREEN)
		Screen.debugPrint(0,100,"Crystal the Glaceon (Testing C-UP)", white, BOTTOM_SCREEN)
		Screen.debugPrint(0,120,"chaoskagami (Corbenik CFW)", white, BOTTOM_SCREEN)
--		Screen.debugPrint(0,160,"Portugal Euro 2016!!!!", red, BOTTOM_SCREEN)
--		Screen.debugPrint(0,180,"Portugal Euro 2016!!!!", yellow, BOTTOM_SCREEN)
--		Screen.debugPrint(0,200,"Portugal Euro 2016!!!!", green, BOTTOM_SCREEN)
	else
		Screen.debugPrint(0,20,"Internet connection failed.", red, BOTTOM_SCREEN)
	end
	
end

function firstscreen() -- scr == 1
	head()
	Screen.debugPrint(0,40,"Welcome to Skeith CFW Updater!", white, TOP_SCREEN)
	Screen.debugPrint(0,100,"Please select an option:", white, TOP_SCREEN)
	Screen.debugPrint(0,120,"A) Clean Update (Recommended)", white, TOP_SCREEN)
	Screen.debugPrint(0,140,"X) Dirty Update (Keep Config)", white, TOP_SCREEN)
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
		isnightly = 1
		keepconfig = 1
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
