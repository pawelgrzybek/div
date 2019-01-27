-- check if active application is in full screen mode
on isItFullScreen()
  tell application "System Events"
    set activeApp to item 1 of (get name of processes whose frontmost is true)
    tell process activeApp
      get value of attribute "AXFullScreen" of window 1
    end tell
  end tell
  return result as boolean
end isItFullScreen

-- return screens size
on screenSize()
  tell application "Finder"
    set _b to bounds of window of desktop
    set _width to item 3 of _b
    set _height to item 4 of _b
  end tell
  return {_width, _height}
end screenSize

-- convert arguments to list
on converttoList(delimiter, input)
  local delimiter, input, ASTID
  set ASTID to AppleScript's text item delimiters
  try
    set AppleScript's text item delimiters to delimiter
    set input to text items of input
    set AppleScript's text item delimiters to ASTID
    return input --> list
  on error eMsg number eNum
    set AppleScript's text item delimiters to ASTID
    error "Can't convert: " & eMsg number eNum
  end try
end converttoList

-- on script invocation read the passed argumens and assign to userQuery
on run userQuery

  -- set some variables
  set screenBounds to screenSize()
  set args to converttoList(" ", userQuery)
  set argsSize to count of args
  set isCurrentAppInFullScreenMode to isItFullScreen()

  -- Load Objective-C script
  -- tell application "Finder"
  --   set myPath to container of (path to me) as text
  -- end tell
  -- set divObjC to load script file (myPath & "divObjC.scptd")
  -- set screensCount to divObjC's getScreensCount()
  -- based on this one i can check if we deal with multiple monitos
  -- if not, carry one
  -- if yes, i can get the origin and possitin of a screen needed to count agains


  -- warn user that the Div doesn't work in full screen mode
  if isCurrentAppInFullScreenMode is true then
    display notification "Div doesn't work in full screen mode!" with title "Div" subtitle "Sorry dude :-(" sound name "Basso"
    return
  end if

  -- if user provided 4 arguments, resize to custom bounds
  if argsSize is 4 then
    tell application "System Events"
      set activeApp to name of first application process whose frontmost is true
      tell process activeApp

          if subrole of window 1 is "AXUnknown" then
            set activeWindow to 2
          else
            set activeWindow to 1
          end if

          -- set pTemp to position of window activeWindow
          -- set sTemp to size of window activeWindow
          -- log pTemp
          -- log sTemp
          -- based on this info i can find where the item is
          -- and override screenBounds

          set position of window activeWindow to {(item 1 of args / 100) * item 1 of screenBounds, (item 2 of args / 100) * item 2 of screenBounds}
          set size of window activeWindow to {((item 3 of args / 100) - (item 1 of args / 100)) * item 1 of screenBounds, ((item 4 of args / 100) - (item 2 of args / 100)) * item 2 of screenBounds}

      end tell
    end tell
  -- if user provided 2 arguments, resize to absolute size on the center of a window
  else if argsSize is 2 then
    if item 1 of args as number > item 1 of screenBounds as number or item 2 of args as number > item 2 of screenBounds as number then
      display notification "Buy a bigger one dude" with title "Div" subtitle "Screen not big enough :-(" sound name "Basso"
    else
      tell application "System Events"
        set activeApp to name of first application process whose frontmost is true
        tell process activeApp

            if subrole of window 1 is "AXUnknown" then
              set activeWindow to 2
            else
              set activeWindow to 1
            end if

            set position of window activeWindow to {(item 1 of screenBounds - item 1 of args) / 2, (item 2 of screenBounds - item 2 of args) / 2}
            set size of window activeWindow to {item 1 of args, item 2 of args}

        end tell
      end tell
    end if
  -- Remmind your user how many arguments is required
  else
    display notification "Two or four arguments (space separated) only!" with title "Div" subtitle "Sorry dude :-(" sound name "Basso"
  end if

end run
