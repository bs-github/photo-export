-- Calculate name of the folder to store this image in
on getAlbumName(theFile)
	tell application "Finder"
		set theFileDate to (the creation date of theFile)
	end tell
	set theYear to year of theFileDate
	set theMonth to month of theFileDate
	set tmpname to (theYear * 100 + theMonth) as text
	set theAlbumname to text 1 thru 4 of tmpname & "-" & text 5 thru 6 of tmpname
	return theAlbumname
end getAlbumName

-- Only import files passing this test
on checkName(theFile)
	tell application "Finder"
		set theName to name of theFile
	end tell
	if theName ends with ".jpg" or theName ends with ".png" or theName ends with ".cr2" or theName ends with ".jpeg" or theName ends with ".mov" or theName ends with ".mp4" then
		return true
	else
		return false
	end if
end checkName

-- Launch Photos application, which might take some time...try to wait until ready
set appname to "Photos"
tell application appname to launch
tell application "System Events"
	repeat until visible of process appname is false
		set visible of process appname to false
	end repeat
end tell

-- Ask user from what folder to import images
tell application "Finder"
	set importFolder to choose folder with prompt "Folder with photos to import"
	set destinationFolder to choose folder with prompt "Folder to move photos to after import"
	set theFiles to every file of importFolder
end tell

-- Check what albums are needed
set albumNameList to {}
set fileList to {}
repeat with i from 1 to number of items in theFiles
	set this_item to item i of theFiles
	if checkName(this_item) then
		set theAlbumname to getAlbumName(this_item)
		if albumNameList does not contain theAlbumname then
			set the end of albumNameList to theAlbumname
		end if
	end if
end repeat

-- Import the actual photos, one album at a time
repeat with j from 1 to number of items in albumNameList
	-- Build a list with all photos to import in this album
	set theAlbum to item j of albumNameList
	set imageList to {}
	repeat with i from 1 to number of items in theFiles
		set this_item to item i of theFiles as alias
		if checkName(this_item) then
			set theAlbumname to getAlbumName(this_item)
			if theAlbumname is theAlbum then
				set the end of imageList to this_item
				set the end of fileList to this_item
			end if
		end if
	end repeat
	-- Tell Photos to import the actual images
	tell application "Photos"
		try
			set theAlbum to album theAlbumname
		on error
			set theAlbum to (make new album named theAlbumname)
		end try
		import imageList into theAlbum without skip check duplicates
	end tell
end repeat

-- Move all files to destination
repeat with j from 1 to number of items in fileList
	set oneFile to item j of fileList
	tell application "Finder"
		move oneFile to destinationFolder
	end tell
end repeat
