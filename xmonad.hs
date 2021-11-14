import XMonad
import System.Directory
import System.IO (hPutStrLn)
import System.Exit
import qualified XMonad.StackSet as W

import XMonad.Actions.CycleWS
import XMonad.Actions.Navigation2D

import Data.Monoid
import qualified Data.Map        as M

import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ServerMode

import XMonad.Layout.Spacing
import XMonad.Layout.Renamed
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders

import XMonad.Util.Dmenu
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

main :: IO ()
main = do
    xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.xmonad/xmobar/mainScreen.hs"
    xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.xmonad/xmobar/secondaryScreen.hs"

    xmonad $ def
        -- simple stuff
        { terminal           = myTerminal
        , focusFollowsMouse  = myFocusFollowsMouse
        , clickJustFocuses   = myClickJustFocuses
        , borderWidth        = myBorderWidth
        , modMask            = myModMask
        , workspaces         = myWorkspaces
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor

        -- key bindings
        , keys               = myLegacyKeys
        , mouseBindings      = myMouseBindings

        -- hooks, layouts
        , manageHook         = myManageHook <+> manageDocks
        , handleEventHook    = myEventHook
        , layoutHook         = spacing myGapSize $ myLayoutHook
        , startupHook        = myStartupHook
        , logHook            = dynamicLogWithPP $ xmobarPP
            { ppOutput = \x -> hPutStrLn xmproc0 x -- xmobar on Monitor 1
                            >> hPutStrLn xmproc1 x -- xmobar on Monitor 2

            , ppCurrent         = xmobarColor "#ebdbb2" "#665c54" . wrap "<box type=Bottom width=2 mb=2 color=#fabd2f> " " </box>" -- Current workspace
            , ppVisible         = xmobarColor "#ebdbb2" ""        . wrap "<box type=Bottom width=2 mb=2 color=#665c54> " " </box>" -- Visible but not current workspace
            , ppHidden          = xmobarColor "#ebdbb2" ""        . wrap " " " "                                                   -- Hidden workspaces
            , ppHiddenNoWindows = xmobarColor "#504945" ""        . wrap " " " "                                                   -- Hidden workspaces (no windows)
            , ppUrgent          = xmobarColor "#FF5252" ""        . wrap " " " "                                                   -- Urgent workspace
            , ppTitle           = xmobarColor "#ebdbb2" ""        . shorten 60                                                     -- Title of active window
            , ppSep             = "<fc=#7c6f64> | </fc>"                                                                           -- Separator between widgets
            , ppOrder           = \(ws:l:t:_) -> [l,ws,t]                                                                          -- order of things in xmobar
            }

    } `additionalKeysP` myKeysP `additionalKeys` myKeys

myStartupHook = do
    spawnOnce "$HOME/.config/autostart-scripts/testing.sh"

myEventHook = docksEventHook

myManageHook = composeAll
    [ className =? "confirm"            --> doFloat
    , className =? "file_progress"      --> doFloat
    , className =? "dialog"             --> doFloat
    , className =? "download"           --> doFloat
    , className =? "error"              --> doFloat
    , className =? "Gimp"               --> doFloat
    , className =? "MPlayer"            --> doFloat
    , className =? "notification"       --> doFloat
    , className =? "splash"             --> doFloat
    , className =? "toolbar"            --> doFloat
    , resource  =? "desktop_window"     --> doIgnore
    , resource  =? "kdesktop"           --> doIgnore 
    , isFullscreen                      --> doFullFloat
      
    , className =? "Brave-browser"      --> doShift ( myWorkspaces !! 0 )
    , className =? "qutebrowser"        --> doShift ( myWorkspaces !! 0 )
    , className =? "Emacs"              --> doShift ( myWorkspaces !! 2 )
    , className =? "Gimp"               --> doShift ( myWorkspaces !! 5 )
    , className =? "VirtualBox Manager" --> doShift ( myWorkspaces !! 8 )
    ]

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myClickJustFocuses :: Bool
myClickJustFocuses = False

myTerminal         = "alacritty"
myTextEditor       = "alacritty -e vim"
myWebBrowser       = "qutebrowser"
myIncognitoBrowser = "qutebrowser --target private-window"
myTorBrowser       = "torbrowser-launcher"
myFileManager      = "pcmanfm"
myMusicPlayer      = "youtubemusic-nativefier"
-- myCliMusicPlayer   = myTerminal + " -e tmux attach -t music"
myVideoPlayer      = "celluloid"
myGame             = "/usr/bin/steam-runtime %U"
myIde              = "emacsclient -c -a 'emacs'"
myImageEditor      = "gimp"
myVectorEditor     = "inkscape"
myVideoEditor      = "kdenlive"
myPhotoLibrary    = "digikam"
myTorrentClient    = "transmission-qt"
myVpn              = "/opt/piavpn/bin/pia-client --quiet"
myVm               = "virtualbox"
myLauncher         = "rofi -show drun"
myPasswordManager  = "rofi-pass"

myNetworkManager   = "nm-connection-editor"
myBluetoothManager = "blueman-manager"
myPowerManager     = "xfce4-power-manager-settings"
-- myAudioManager     = terminal + " -e alsamixer"

myBarSize = 24
myGapSize = 5
myBorderWidth = 3

myNormalBorderColor  = "#928374"
myFocusedBorderColor = "#fb4934"

myModMask       = mod4Mask

myKeysP :: [(String, X ())]
myKeysP =
    -- System
    [ ("M-C-r", spawn "xmonad --recompile; xmonad --restart") -- Restart XMonad
    , ("M-C-q", io (exitWith ExitSuccess)                   ) -- Quit XMonad
      -- "M-d" Debug
      -- "M-t z" Changing UI

    -- Windows
    , ("M-q"       , kill                                                                          ) -- Close focused Window
    , ("M-<F11>"   , toggleSmartSpacing >> sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts ) -- Toggles Fullscreen
    , ("M-m"       , toggleSmartSpacing >> sendMessage (Toggle NBFULL)                             ) -- Toggle Maximize
    -- , ("M-f"       , withFocused $ windows . W.sink                                             ) -- Toggle Floating
    -- , ("M-d"       , windows W.                                                                 ) -- Toggle Minimize
    , ("M1-<Tab>"  , windows W.focusDown                                                           ) -- Move focus to next Window
    , ("M1-S-<Tab>", windows W.focusUp                                                             ) -- Move focus to prev Window
    , ("M-/"       , switchLayer                                                                   ) -- Switch navigation layer (Tiled vs Floating screens)
    , ("M-h"       , windowGo L False                                                              ) -- Move focus to left Window
    , ("M-j"       , windowGo D False                                                              ) -- Move focus to below Window
    , ("M-k"       , windowGo U False                                                              ) -- Move focus to above Window
    , ("M-l"       , windowGo R False                                                              ) -- Move focus to right Window
    -- , ("M-m"       , windows W.focusMaster                                                      ) -- Move focus to Master Window
    , ("M-S-h"     , windowSwap L False                                                            ) -- Swap focused Window with left Window
    , ("M-S-j"     , windowSwap D False                                                            ) -- Swap focused Window with below Window
    , ("M-S-k"     , windowSwap U False                                                            ) -- Swap focused Window with above Window
    , ("M-S-l"     , windowSwap R False                                                            ) -- Swap focused Window with right Window
    , ("M-C-h"     , sendMessage Shrink                                                            ) -- Grow focused Window left
    , ("M-C-l"     , sendMessage Expand                                                            ) -- Grow focused Window right
    , ("M-C-j"     , sendMessage Shrink                                                            ) -- Grow focused Window down
    , ("M-C-k"     , sendMessage Expand                                                            ) -- Grow focused Window up

    -- Monitors
    , ("M-,"  , screenGo L False      ) -- Move focus to left Screen
    , ("M-."  , screenGo R False      ) -- Move focus to right Screen
    , ("M-S-,", windowToScreen L False) -- Move focused Window to the left Screen
    , ("M-S-.", windowToScreen R False) -- Move focused Window to the right Screen
    , ("M-C-,", screenSwap L False    ) -- Swap active Screen with the left Screen
    , ("M-C-.", screenSwap R False    ) -- Swap active Screen with the right Screen

    -- Layouts
    , ("M-<Space>"   , sendMessage NextLayout            ) -- Switch Layouts
    -- , ("M-S-<Space>" , setLayout $ XMonad.layoutHook conf) -- Switch Layouts
    , ("M-M1-<Space>", sendMessage FirstLayout           ) -- Switch to default Layout
    , ("M-="         , refresh                           ) -- Resize viewed windows to the correct size
    , ("M-t w b"     , sendMessage (Toggle NOBORDERS) ) -- Toggle Window Borders

    -- Workspaces
    , ("M-<Tab>" , toggleWS           ) -- Toggle Workspace
    -- , ("M-`"     ,                    ) -- Toggle Scratchpad

    -- Media Keys
    , ("<XF86AudioLowerVolume>", spawn "amixer set Master 3%- unmute" )
    , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 3%+ unmute" )
    , ("<XF86AudioMute>"       , spawn "amixer set Master toggle"     )
    -- , ("<XF86AudioPlay>"       , spawn "mocp --play"                  )
    -- , ("<XF86AudioPrev>"       , spawn "mocp --previous"              )
    -- , ("<XF86AudioNext>"       , spawn "mocp --next"                  )

    -- Launching Apps
    , ("C-M1-t"    , spawn (myTerminal)        ) -- Launch Terminal
    , ("M-<Return>", spawn (myTerminal)        ) -- Launch Terminal
    , ("M-c"       , spawn (myIde)             ) -- Launch IDE
    , ("M-e"       , spawn (myFileManager)     ) -- Launch File Manager
    , ("M-b"       , spawn (myWebBrowser)      ) -- Launch Web Browser
    , ("M-i"       , spawn (myIncognitoBrowser)) -- Launch Web Browser in Incognito Mode
    , ("M-p"       , spawn (myPasswordManager) ) -- Autofill Passwords
    , ("M-r"       , spawn (myLauncher)        ) -- Launch Launcher
    , ("M-S-r"     , spawn "dmenu_run"         ) -- Launch dmenu
    -- Primary
    , ("M-o t"     , spawn (myTorBrowser)      ) -- Launch Tor Browser
    , ("M-o m"     , spawn (myMusicPlayer)     ) -- Launch Music Player
    , ("M-o v"     , spawn (myVideoPlayer)     ) -- Launch Video Player
    , ("M-o s"     , spawn (myGame)            ) -- Launch Steam
    -- Secondary
    , ("C-M1-o t"  , spawn (myTextEditor)      ) -- Launch Text Editor
    , ("C-M1-o p"  , spawn (myPhotoLibrary)    ) -- Launch Photo Library
    , ("C-M1-o g"  , spawn (myImageEditor)     ) -- Launch Image Editor
    , ("C-M1-o r"  , spawn (myVectorEditor)    ) -- Launch Vector Editor
    , ("C-M1-o v"  , spawn (myVideoEditor)     ) -- Launch Video Editor

    -- dm-scripts
    , ("M-s M-s" , spawn "$HOME/.local/bin/dmscripts/dm-master"     )
    , ("M-s w"   , spawn "$HOME/.local/bin/dmscripts/dm-wallpaper"  )
    , ("M-s r"   , spawn "$HOME/.local/bin/dmscripts/dm-record"     )
    , ("M-s p"   , spawn "$HOME/.local/bin/dmscripts/dm-power"      )
    , ("M-s s"   , spawn "$HOME/.local/bin/dmscripts/dm-screenshot" )
    , ("M-s b"   , spawn "$HOME/.local/bin/dmscripts/dm-bookman"    )
    , ("M-s n"   , spawn "$HOME/.local/bin/dmscripts/dm-notify"     )
    , ("M-s \\"  , spawn "$HOME/.local/bin/dmscripts/dm-notify"     )

    -- Power Control
    , ("M1-<F4>", spawn "$HOME/.local/bin/dmscripts/dm-power"         ) -- Logout Menu
    , ("M-z z"  , spawn "$HOME/.local/bin/dmscripts/dm-power"         ) -- Logout Menu
    , ("M-z l"  , spawn "$HOME/.local/bin/dmscripts/dm-power lock"    ) -- Lock Screen
    , ("M-z s"  , spawn "$HOME/.local/bin/dmscripts/dm-power suspend" ) -- Suspend System
    , ("M-z p"  , spawn "$HOME/.local/bin/dmscripts/dm-power poweroff") -- Shutdown System
    , ("M-z r"  , spawn "$HOME/.local/bin/dmscripts/dm-power reboot"  ) -- Reboot System
    , ("M-z w"  , spawn "$HOME/.local/bin/dmscripts/dm-power windows" ) -- Reboot to Windows

    -- Screenshot
    , ("M-<Print>"  , spawn "$HOME/.local/bin/dmscripts/dm-screenshot full"   ) -- Full Desktop Screenshot
    , ("<Print>"    , spawn "$HOME/.local/bin/dmscripts/dm-screenshot screen" ) -- Fullscreen Screenshot
    , ("M-S-<Print>", spawn "$HOME/.local/bin/dmscripts/dm-screenshot area"   ) -- Selection Area Screenshot
    , ("M1-<Print>" , spawn "$HOME/.local/bin/dmscripts/dm-screenshot window" ) -- Active Window Screenshot

    -- Notifications
    , ("M-\\ \\"  , spawn "$HOME/.local/bin/dmscripts/dm-notify recents" ) -- Show recent Notifications
    , ("M-\\ r"   , spawn "$HOME/.local/bin/dmscripts/dm-notify recents" ) -- Show recent Notifications
    , ("M-\\ S-c" , spawn "$HOME/.local/bin/dmscripts/dm-notify clear"   ) -- Clear all Notifications
    , ("M-\\ c"   , spawn "$HOME/.local/bin/dmscripts/dm-notify close"   ) -- Clear last Notification
    , ("M-\\ a"   , spawn "$HOME/.local/bin/dmscripts/dm-notify context" ) -- Open last Notification
  ]

myKeys :: [((KeyMask, KeySym), X ())]
myKeys =
    [ ((shiftMask, xK_Alt_L), spawn "$HOME/.local/bin/dmscripts/dm-lang"  ) -- Language Switching

    -- Push window back into tiling
    -- , ((mod4Mask,               xK_t     ), withFocused $ windows . W.sink)

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    -- , ((mod4Mask .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    -- , ((mod4Mask          , xK_b     ), sendMessage ToggleStruts)
    ]

myLegacyKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

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

myWorkspaces  = [ "<fn=2>\xf268</fn>"
                , "<fn=2>\xf3f6</fn>"
                , "<fn=1>\xf11c</fn>"
                , "<fn=1>\xf07b</fn>"
                , "<fn=1>\xf025</fn>"
                , "<fn=1>\xf030</fn>"
                , "<fn=1>\xf03d</fn>"
                , "<fn=1>\xf7cd</fn>"
                , "<fn=2>\xf395</fn>"
                ]

myLayoutHook = avoidStruts $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) (tiled ||| Mirror tiled ||| Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

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
