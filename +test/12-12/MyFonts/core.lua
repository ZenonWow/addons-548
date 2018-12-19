-- A small addon for adding my preferred fonts in LibSharedMedia
local ADDON = ...

-- Setup shared media
local LSM = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)
local fontpath = "Interface\\Addons\\"..ADDON.."\\fonts\\"

if LSM then	
	-- "Ace Futurism is a simple techno font inspired by multiple that already exist. 
	-- Was initially to be used in a game but the game halted being worked 
	-- on so I finished up the font and here it is."
	-- http://nalgames.com/fonts/all-fonts/
	LSM:Register("font", "Ace Futurism", fontpath .. "Ace_Futurism.ttf")
		
	-- PT Sans is a drop in replacement of Myriad font by Adobe
	-- It is licensed under the OFL 1.1.
	-- https://www.google.com/fonts/specimen/PT+Sans
	LSM:Register("font", "PT Sans", fontpath .. "PT_Sans-Web-Regular")
	LSM:Register("font", "PT Sans Bold", fontpath .. "PT_Sans-Web-Bold")
	LSM:Register("font", "PT Sans Bold Italic", fontpath .. "PT_Sans-Web-BoldItalic")
	LSM:Register("font", "PT Sans Italic", fontpath .. "PT_Sans-Web-Italic")
	
	-- Carlito is a drop in replacement for Calibri Fonts. 
	-- Metrically compatible with the current MS default font Calibri. 
	-- It is licensed under the OFL 1.1.
	-- http://blogs.gnome.org/uraeus/2013/10/10/a-thank-you-to-google/
	LSM:Register("font", "Carlito", fontpath .. "Carlito-Regular.ttf")
	LSM:Register("font", "Carlito Bold", fontpath .. "Carlito-Bold.ttf")
	LSM:Register("font", "Carlito Italic", fontpath .. "Carlito-Italic.ttf")
	LSM:Register("font", "Carlito Bold Italic", fontpath .. "Carlito-BoldItalic.ttf")
	
	-- The Ubuntu Font Family are a set of matching new libre/open fonts 
	-- in development during 2010-2011. The development is being funded by Canonical Ltd 
	-- on behalf the wider Free Software community and the Ubuntu project. 
	-- The technical font design work and implementation is being undertaken by Dalton Maag.
	-- http://font.ubuntu.com/
	LSM:Register("font", "Ubuntu", fontpath .. "Ubuntu-R.ttf")
	LSM:Register("font", "Ubuntu Italic", fontpath .. "Ubuntu-RI.ttf")
	LSM:Register("font", "Ubuntu Condensed", fontpath .. "Ubuntu-C.ttf")
	LSM:Register("font", "Ubuntu Bold", fontpath .. "Ubuntu-B.ttf")
	LSM:Register("font", "Ubuntu Bold Italic", fontpath .. "Ubuntu-BI.ttf")
	LSM:Register("font", "Ubuntu Light", fontpath .. "Ubuntu-L.ttf")	
	LSM:Register("font", "Ubuntu Light Italic", fontpath .. "Ubuntu-LI.ttf")
	LSM:Register("font", "Ubuntu Medium", fontpath .. "Ubuntu-M.ttf")	
	LSM:Register("font", "Ubuntu Medium Italic", fontpath .. "Ubuntu-MI.ttf")	
	
	-- Comic Neue is a casual script typeface released in 2014. It was designed 
	-- by Craig Rozynski as a more modern, refined version of the ubiquitous, 
	-- but frequently criticised typeface, Comic Sans.
	-- http://comicneue.com/
	LSM:Register("font", "ComicNeue", fontpath .. "ComicNeue-Regular.ttf")	
	LSM:Register("font", "ComicNeue Light", fontpath .. "ComicNeue-Light.ttf")	
	LSM:Register("font", "ComicNeue Bold", fontpath .. "ComicNeue-Bold.ttf")		
end