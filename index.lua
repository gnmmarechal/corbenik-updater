--Corbenik CFW Updater
--Author: gnmmarechal
--Runs on Lua Player Plus 3DS

--Some variables
System.currentDirectory("/")
root = System.currentDirectory()
consolehbdir = root.."3ds/"
consoleerror = 0
scr = 1
oldpad = Controls.read()
debugmode = 1

--App details
versionmajor = 0
versionminor = 1
versionrev = 0
versionstring = versionmajor.."."..versionminor.."."..versionrev
versionrelno = 1
selfname = "corbenikupdater"
selfpath = consolehbdir..selfname.."/"
selfexepath = selfpath..selfname..".3dsx"
selfstring = "Corbenik CFW Updater v."..versionstring
selfauthor = "gnmmarechal"

--Affected app details
appname = "Corbenik CFW"
appinstallname = "corbenik"
appinstallpath = root
downloadedzip = root..appinstallname..".zip"
cfwpath = appinstallpath..appinstallname
config = root..appinstallname.."-updater.cfg"

--Server strings (some vars are declared by functions after reading the strings from the server)
serverpath = "http://gs2012.xyz/3ds/"..selfname.."/"
servergetzippath = serverpath.."latest.txt"
servergetzipver = serverpath.."version.txt"


-- Colours
white = Color.new(255,255,255)
green = Color.new(0,240,32)
red = Color.new(255,0,0)

-- Server/network functions
function iswifion()
	if (Network.isWifiEnabled()) then
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
		serversmdhpath = Network.requestString(servergetsmdhpath)
		serverver = Network.requestString(servergetzipver)
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
		Screen.clear(TOP_SCREEN)
		scr = newscr
	end	
end

function nextscr(skrin)
	
	inputscr(skrin, KEY_A)
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
	if System.doesFileExist(config) then
		configstream = io.open(config,FREAD)
		armpayloadpath = io.read(configstream,0,io.size(config))
	else
		armpayloadpath = root.."arm9loaderhax.bin"
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
		System.extractZIP(downloadedzip,appinstallpath)
		System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/firmware",cfwpath.."/firmware")
		System.renameDirectory(root..appinstallname.."-BACKUP-"..h..m..s..day_value..day..month..year.."/keys",cfwpath.."/keys")
	end
	debugWrite(0,120,"DONE! Press A/B to exit!", green, TOP_SCREEN)
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
	Screen.debugPrint(0,40,"An error has ocurred.", white, TOP_SCREEN)
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
		--Screen.debugPrint(0,20,"Latest 3DSX: "..serverjenkinsver, green, BOTTOM_SCREEN) -- This is pretty much useless now, as builds are automated.
		Screen.debugPrint(0,20,"Author: gnmmarechal", white, BOTTOM_SCREEN)
		Screen.debugPrint(0,40,"Special Thanks: Rinnegatamante", white, BOTTOM_SCREEN)
	else
		Screen.debugPrint(0,20,"Internet connection failed.", red, BOTTOM_SCREEN)
	end
	
end

function firstscreen() -- scr == 1
	head()
	Screen.debugPrint(0,40,"Welcome to Corbenik CFW Updater!", white, TOP_SCREEN)
	Screen.debugPrint(0,100,"Please select an option:", white, TOP_SCREEN)
	Screen.debugPrint(0,120,"A) Update to latest stable build", white, TOP_SCREEN)
	Screen.debugPrint(0,140,"B) Quit to HBL", white, TOP_SCREEN)
	inputscr(2, KEY_A)
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

runoncevars()
iswifion()
servergetVars()
precleanup()
precheck()

while true do
	clear()
	pad = Controls.read()
	bottomscreen(iswifion())
	if scr == 2 then
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