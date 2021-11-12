import XMonad
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)

import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.SpawnOnce

main = xmonad defaults

defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myLegacyKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    } `additionalKeysP` myKeys

myStartupHook = do
    spawnOnce "$HOME/.config/autostart-scripts/testing.sh"

myEventHook = mempty

myLogHook = return ()

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myClickJustFocuses :: Bool
myClickJustFocuses = False

myTerminal         = "alacritty"
-- myTextEditor       = myTerminal + " -e vim"
myWebBrowser       = "qutebrowser"
myIncognitoBrowser = "qutebrowser --target private-window"
myTorBrowser       = "torbrowser-launcher"
myFileManager      = "pcmanfm"
myMusicPlayer      = "youtubemusic-nativefier"
-- myCliMusicPlayer   = myTerminal + " -e tmux attach -t music"
myVideoPlayer      = "celluloid"
myGame             = "/usr/bin/steam-runtime %U"
myIde              = "emacsclient -c -a 'emacs'"
myGraphicsEditor   = "gimp"
myVectorEditor     = "inkscape"
myVideoEditor      = "kdenlive"
myPhotosLibrary    = "digikam"
myTorrentClient    = "transmission-qt"
myVpn              = "/opt/piavpn/bin/pia-client --quiet"
myVm               = "virtualbox"
myLauncher         = "rofi -show drun"
myPasswordManager  = "rofi-pass"

myNetworkManager   = "nm-connection-editor"
myBluetoothManager = "blueman-manager"
myPowerManager     = "xfce4-power-manager-settings"
-- myAudioManager     = terminal + " -e alsamixer"

myBorderWidth = 3

myNormalBorderColor  = "#928374"
myFocusedBorderColor = "#fb4934"

myModMask       = mod4Mask

myKeys :: [(String, X ())]
myKeys =
    -- System
    [ ("M-C-r", spawn "xmonad --recompile; xmonad --restart") -- Restart xmonad
    , ("M-C-q", io (exitWith ExitSuccess))                    -- Quit xmonad

    -- Windows
    , ("M-q"       , kill                  ) -- close focused window
    , ("M1-<Tab>"  , windows W.focusDown   ) -- Move focus to the next window
    , ("M1-S-<Tab>", windows W.focusUp     ) -- Move focus to the next window
    , ("M-h"       , windows W.focusUp     ) -- Move focus to the previous window
    , ("M-j"       , windows W.focusDown   ) -- Move focus to the next window
    , ("M-k"       , windows W.focusUp     ) -- Move focus to the previous window
    , ("M-l"       , windows W.focusDown   ) -- Move focus to the next window
    , ("M-m"       , windows W.focusMaster ) -- Move focus to the master window
    , ("M-S-h"     , windows W.swapUp      ) -- Swap the focused window with the previous window
    , ("M-S-j"     , windows W.swapDown    ) -- Swap the focused window with the next window
    , ("M-S-k"     , windows W.swapUp      ) -- Swap the focused window with the previous window
    , ("M-S-l"     , windows W.swapDown    ) -- Swap the focused window with the next window

    -- Screens
    , ("M-,", prevScreen) -- launch a terminal
    , ("M-.", nextScreen) -- launch a terminal

    -- Layouts
    , ("M-<Space>"  , sendMessage NextLayout            ) -- Rotate through the available layout algorithms
    -- , ("M-S-<Space>", setLayout $ XMonad.layoutHook conf) -- Reset the layouts on the current workspace to default
    , ("M-="      , refresh                           ) -- Resize viewed windows to the correct size

    -- Workspaces

    -- Power Control
    , ("M-z z", spawn "$HOME/.local/bin/dmscripts/dm-power"         ) -- dm-power
    , ("M-z l", spawn "$HOME/.local/bin/dmscripts/dm-power lock"    ) -- Lock Screen
    , ("M-z s", spawn "$HOME/.local/bin/dmscripts/dm-power suspend" ) -- Suspend System
    , ("M-z p", spawn "$HOME/.local/bin/dmscripts/dm-power poweroff") -- Shutdown System
    , ("M-z r", spawn "$HOME/.local/bin/dmscripts/dm-power reboot"  ) -- Reboot
    , ("M-z w", spawn "$HOME/.local/bin/dmscripts/dm-power windows" ) -- Reboot to Windows

    -- Screenshot
    , ("M-<Print>"  , spawn "$HOME/.local/bin/dmscripts/dm-screenshot full"   ) -- Full Desktop Screenshot
    , ("<Print>"    , spawn "$HOME/.local/bin/dmscripts/dm-screenshot screen" ) -- Fullscreen Screenshot
    , ("M-S-<Print>", spawn "$HOME/.local/bin/dmscripts/dm-screenshot area"   ) -- Selection Area Screenshot
    , ("M1-<Print>" , spawn "$HOME/.local/bin/dmscripts/dm-screenshot window" ) -- Active Window Screenshot

    -- Media Keys
    , ("<XF86AudioMute>", spawn "amixer set Master toggle")
    , ("<XF86AudioLowerVolume>", spawn "amixer set Master 3%- unmute")
    , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 3%+ unmute")
    -- , ("<XF86AudioPlay>", spawn "mocp --play")
    -- , ("<XF86AudioPrev>", spawn "mocp --previous")
    -- , ("<XF86AudioNext>", spawn "mocp --next")
    -- , ("<XF86HomePage>", spawn "qutebrowser https://www.youtube.com/c/DistroTube")
    -- , ("<XF86Search>", spawn "dm-websearch")
    -- , ("<XF86Mail>", runOrRaise "thunderbird" (resource =? "thunderbird"))
    -- , ("<XF86Calculator>", runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk"))
    -- , ("<XF86Eject>", spawn "toggleeject")
    -- , ("<Print>", spawn "dm-maim")

    -- Launching Apps
    , ("C-M1-t"    , spawn (myTerminal))         -- launch terminal
    , ("M-<Return>", spawn (myTerminal))         -- launch terminal
    , ("M-c"       , spawn (myIde))              -- launch IDE
    , ("M-b"       , spawn (myWebBrowser))       -- launch web browser
    , ("M-i"       , spawn (myIncognitoBrowser)) -- launch web browser in incognito mode
    , ("M-r"       , spawn (myLauncher))         -- launch launcher
    , ("M-S-r"     , spawn "dmenu_run")          -- launch dmenu
    , ("M-p"       , spawn (myPasswordManager))  -- autofill password

  ]

myLegacyKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    [ ((modm .|. shiftMask, xK_p     ), spawn "gmrun"               ) -- launch gmrun



    -- , ((modm,               xK_Return), windows W.swapMaster)               -- Swap the focused window and the master window

    -- , ((modm,               xK_h     ), sendMessage Shrink            ) -- Shrink the master area
    -- , ((modm,               xK_l     ), sendMessage Expand            ) -- Expand the master area
    , ((modm,               xK_t     ), withFocused $ windows . W.sink) -- Push window back into tiling
    -- , ((modm              , xK_comma ), sendMessage (IncMasterN 1)    ) -- Increment the number of windows in the master area
    -- , ((modm              , xK_period), sendMessage (IncMasterN (-1)) ) -- Deincrement the number of windows in the master area

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_F1, xK_F2, xK_F3] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
-- myWorkspaces    = ["","","","","","","","",""]

myLayout = tiled ||| Mirror tiled ||| Full
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
