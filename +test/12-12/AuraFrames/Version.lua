local AuraFrames = LibStub("AceAddon-3.0"):GetAddon("AuraFrames");

-----------------------------------------------------------------
-- Version information
-----------------------------------------------------------------
AuraFrames.Version = {
  
  String   = "1.3.6-Release",
  Revision = "440",
  Date     = date("%m/%d/%y %H:%M:%S", tonumber("@project-timestamp@")),
  
};

if AuraFrames.Version.String == "@".."project-version".."@" then

  AuraFrames.Version.String = "SVN Repository";
  AuraFrames.Version.Revision = "SVN Repository";

end
