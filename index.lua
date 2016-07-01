--Corbenik CFW Updater
--Author: gnmmarechal
--Runs on Lua Player Plus 3DS

-- Run updated index.lua: If a file is available on the server, that file will be downloaded and used instead.
-- Skipped if useupdate = 0
isupdate = 1
if System.doesFileExist("/corbenik-updater/usebgm") then
	usebgm = 1
else
	usebgm = 0
end
useupdate = 0
updateserverlua = "http://gs2012.xyz/3ds/corbenikupdater/updatedindex.lua"
System.createDirectory("/corbenik-updater")
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
if usebgm == 1 then
	Sound.init()
	if System.doesFileExist("romfs:/bgm.wav") then
		bgm = Sound.openWav("romfs:/bgm.wav",false)
		Sound.play(bgm,LOOP)
	end
	if System.doesFileExist("/3ds/corbenikupdater/bgm.wav") then
		bgm = Sound.openWav("/3ds/corbenik-updater/bgm.wav",false)
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

--App details
versionmajor = 0
versionminor = 4
versionrev = 2
versionstring = versionmajor.."."..versionminor.."."..versionrev
versionrelno = 3
selfname = "corbenikupdater"
selfpath = consolehbdir..selfname.."/"
selfexepath = selfpath..selfname..".3dsx" -- This is for the 3DSX version only
selfstring = "Corbenik CFW Updater v."..versionstring
selfauthor = "gnmmarechal"

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

--Update-check functions


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
	end
end

--System functions
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
	if System.doesFileExist(nightlyfile) then
		servergetzippath = servergetnightlyzippath
		usenightly = 1	
	else
		usenightly = 0
	end
	if not System.doesFileExist(cfwpath.."/firmware/native") then
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
	
end

function installfilechecker()	
	if newinstall == 1 then
		if not System.doesFileExist("/corbenik-updater/firmware.bin") then
		
		end
	end
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
		Screen.debugPrint(0,80,"Rinnegatamante (LPP-3DS)", white, BOTTOM_SCREEN)
		Screen.debugPrint(0,100,"Crystal the Glaceon (Testing)", white, BOTTOM_SCREEN)
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
	installnew()
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
