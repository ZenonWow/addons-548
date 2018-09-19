--[[========================================================================================
      AdvancedIconSelector, a World of Warcraft icon selector replacement with search
      functionality.
      
      Copyright (c) 2011 - 2012 David Forrester  (Darthyl of Bronzebeard-US)
        Email: darthyl@hotmail.com
      
      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:
      
      The above copyright notice and this permission notice shall be included in
      all copies or substantial portions of the Software.
      
      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
      THE SOFTWARE.
    ========================================================================================]]

local L = LibStub:GetLibrary("AceLocale-3.0"):NewLocale("AdvancedIconSelector", "enUS", true)
if not L then return end

-- Note: Although the icon selector may be localized, the search feature will still operate on english filenames and keywords.

L["Edit Equipment Set"] = true
L["New Equipment Set"] = true
L["Edit Bank Tab"] = true
L["Edit Macro"] = true
L["New Macro"] = true
L["Macro icons"] = true
L["Item icons"] = true
