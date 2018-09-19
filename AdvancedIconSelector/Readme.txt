========================================================================================
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
========================================================================================

    Official website for AdvancedIconSelector:
    http://www.curse.com/addons/wow/advancediconselector
    
    Official website for LibAdvancedIconSelector-1.0:
    http://www.curse.com/addons/wow/libadvancediconselector-1-0
    
    Original author: Darthyl of Bronzebeard-US  <darthyl@hotmail.com>

========================================================================================

About AdvancedIconSelector:

AdvancedIconSelector is a complete replacement for the standard Blizzard macro / equipment set icon selector.  It has a built-in search feature and an optional keywords library to make finding the right icon for your new macro or equipment set as easy as conjured mana pie!

This addon has several goals:
- To make the icon selector dialog resizeable, so you can see more icons at once.
- To allow searching by icon filename.
- To allow searching by addon-defined keywords (like "fire" or "cat").
- To make its icon selector available to other addons via its shared library

The keyword library that comes with AdvancedIconSelector specifies search terms for the 1200+ icons which can be used for macros and equipment sets.  This library does not load until it's needed, so you don't have to worry about it adversely affecting your loading time. (it usually takes less than 0.1 seconds anyway)


Usage:
================
If enabled, AdvancedIconSelector will automatically replace the standard Blizzard icon dialogs.  You can also type /icons or /ais to browse all the icons available.

If you hover your mouse over an icon, you'll see that icon's ID, filename, as well as which spells make use of it!

You can also filter the icons displayed by typing into the search box.  You can use terms like AND, OR, and NOT to better specify what you're looking for - for example, you might search for "cat" to search for all cats, but then refine your search to "cat AND NOT cata" to get rid of all the bogus "Cat"aclysm items that appeared when you searched for "cat". (AND OR NOT can also be specified with , ; ! respectively (and whitespace means AND)... the previous search could also be accomplished with "cat !cata")


Tips:
================
- You can search by spell name!  Try typing "arcane intellect"
- Most icons have color keywords.  Try searching for "blue" to view all icons where blue is a prominent color!
- Many icons have element keywords.  Try searching for "fire" !
- Be careful of substrings - searching for "holy" also yields the results for "unholy" as well!
- To do pattern matching, place an = in front of a search term: "=%d%d%d" will find all icons that have 3 consecutive digits in the filename or keywords (see http://www.wowpedia.org/Pattern_matching for more information)
- There's no way I can ever enter every single word you could ever think of for every single icon, so you're gonna have to be a little smart about your searches:
  - Use simple keywords whenever possible: "explosion" is more likely to come up with results than "exploding" or "exploded".  "flame" or "fire" is better than "flaming".  "skull" is better than "skeletal".
  - Use unambiguous terms: "fire" will provide much more helpful results than "magic"... and what I think of as magic may differ from what you think of as magic.
  - Extremely subjective terms like "scary" are very rarely included.
  - I tried to only include keywords like "mouth" if they're significant to the icon, as opposed to including it on every single icon that has a face.  Therefore, searching for dull terms like "hair" may yield no useful results since there are no icons where the hair is really emphasized.


Other notes:
================
- NOT is processed before AND is processed before OR.  Parenthesis are not currently supported.
- Patterns are matched against LOWERCASE filenames and keywords and cannot contain spaces.
- Keywords I've added are optimized out if they're part of the filename or another keyword.  If a keyword you think should be there is not, check first that it's not part of the filename. (i.e., "dead" might not be a keyword if "undead" is part of the filename)
- Spell data is nearly, but not entirely complete.  Most notably missing are hunter pets, mounts, companions, and profession specializations.
- If you also install AddonLoader (http://wow.curse.com/downloads/wow-addons/details/addon-loader.aspx), this addon won't even load until you open the character or macro frame!  I highly recommend it, as it may help in the delayed loading of other addons as well!

The keyword database should be pretty good as it is, and will continue to improve over the new few months as I put it through some major reviews.  There is currently no way to contribute keyword data, but if there's enough interest in contributing keywords and/or localizing the entire keyword library (a ginormous and ongoing task), I'll consider releasing the keyword editor and/or adding a "Contribute" feature directly into the addon.  That said, please post any suggestions you have for now and I'll gladly take them into consideration.

Also, if you're an addon developer, the internal library can be used to provide its searchable icon selection GUI to your own addon (regardless of whether or not this one is installed)!  See AdvancedIconSelector\Libs\LibAdvancedIconSelector-1.0\Readme.txt for details on how to do this.
