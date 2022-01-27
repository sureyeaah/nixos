{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TupleSections #-}

import Control.Concurrent (threadDelay)
import Control.Monad (unless)
import Data.List
import qualified Data.Map as M
import Data.Maybe
import Data.Monoid
import System.Directory (doesFileExist)
import System.Exit (exitSuccess)
import System.Posix (ownerModes)
import System.Posix.Files (createNamedPipe)
import Text.Read (readMaybe)
import XMonad
import XMonad.Actions.CopyWindow (kill1)
import qualified XMonad.Actions.CycleWS as CycleWS
import XMonad.Actions.FloatKeys
import qualified XMonad.Actions.PhysicalScreens as PhysicalScreens
import XMonad.Actions.Promote
import XMonad.Actions.Warp (Corner (..), banishScreen, warpToScreen)
import XMonad.Actions.WithAll (killAll, sinkAll)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers (doCenterFloat, isDialog)
import XMonad.Hooks.RefocusLast (refocusLastLayoutHook, refocusLastWhen)
import XMonad.Layout.Fullscreen (fullscreenManageHook)
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows)
import XMonad.Layout.MultiToggle (EOT (EOT), Toggle (..), mkToggle, (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (NBFULL, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed (Rename (Replace), renamed)
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spacing
import XMonad.Layout.TwoPanePersistent
import XMonad.Layout.WindowArranger (windowArrange)
import qualified XMonad.StackSet as W
import XMonad.Util.Dmenu (menuMapArgs)
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput)
import XMonad.Util.NamedWindows (getName)
import XMonad.Util.SpawnOnce

------------------------------------------------------------------------
---VARIABLES
------------------------------------------------------------------------
-- myFont :: String
-- myFont = "xft:Iosevka Nerd Font:bold:size=10"

myHome :: String
myHome = "/home/sureyeaah/"

myModMask :: KeyMask
myModMask = mod4Mask -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "kitty " -- Sets default terminal

myBrowser :: String
myBrowser = "brave"

myEditor :: String
myEditor = myTerminal ++ " -e nvim " -- Sets nvim as editor

myBorderWidth :: Dimension
myBorderWidth = 5 -- Sets border width for windows

myNormColor :: String
myNormColor = "#282a36" -- Border color of normal windows

myFocusColor :: String
myFocusColor = "#bd93f9" -- Border color of focused windows

visibleWorkspaceColor :: String
visibleWorkspaceColor = "#686f9a"

focusedWorkspaceColor :: String
focusedWorkspaceColor = "#5ccc96"

------------------------------------------------------------------------
---SCRATCHPADS
------------------------------------------------------------------------
-- Allows to have several floating scratchpads running different applications.
-- Import Util.NamedScratchpad.  Bind a key to namedScratchpadSpawnAction.
myScratchPads :: [NamedScratchpad]
myScratchPads =
  [ NS "pulse" spawnPulse findPulse managePulse -- Pavucontrol
  ]
  where
    -- spawnTerm  = myTerminal ++ " -n scratchpad"
    -- findTerm   = resource =? "scratchpad"
    -- manageTerm = customFloating $ W.RationalRect l t w h
    --            where
    --              h = 0.95
    --              w = 0.95
    --              t = 0.98 -h
    --              l = 0.975 -w

    spawnPulse = "pavucontrol"
    findPulse = resource =? "pavucontrol"
    managePulse = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w

------------------------------------------------------------------------
---WORKSPACES
------------------------------------------------------------------------
myWorkspaces :: [String]
myWorkspaces = ["web", "code", "term", "slack", "notes", "watch", "music", "8", "9"]

------------------------------------------------------------------------
---WINDOW RULES
------------------------------------------------------------------------
-- Android Studio Fix
(~=?) :: Eq a => Query [a] -> [a] -> Query Bool
q ~=? x = fmap (isInfixOf x) q

-- Do not treat menus and settings popup as a separate window.
manageIdeaCompletionWindow = (className =? "jetbrains-studio") <&&> (title ~=? "win") --> doIgnore

-- My Window Rules
myManageHook :: Query (Data.Monoid.Endo WindowSet)
myManageHook =
  (isDialog --> doF W.swapUp) -- Bring Dialog Window on Top of Parent Floating Window
    <+> insertPosition Below Newer -- Insert New Windows at the Bottom of Stack Area
    -- <+> namedScratchpadManageHook myScratchPads       -- Adding Rules for Named Scratchpads
    <+> manageIdeaCompletionWindow -- Adding Fix for Android Studio
    <+> composeAll
      [ (className =? "firefox" <&&> title =? "Library") --> doCenterFloat, -- Float Firefox Downloads Window to Centre
      -- , stringProperty "_NET_WM_NAME" =? "Emulator" --> doCenterFloat                                  -- Float Android Emulator to Centre
        (className =? "Lxappearance") --> doCenterFloat, -- Float Lxappearance to Centre
        isDialog --> doCenterFloat -- Float Dialog Windows to Centre
      ]

------------------------------------------------------------------------
---AUTOSTART
------------------------------------------------------------------------
-- Firefox Fullscreen Support
setFullscreenSupport :: X ()
setFullscreenSupport = withDisplay $ \dpy -> do
  r <- asks theRoot
  a <- getAtom "_NET_SUPPORTED"
  c <- getAtom "ATOM"
  supp <-
    mapM
      getAtom
      [ "_NET_WM_STATE_HIDDEN",
        "_NET_WM_STATE_FULLSCREEN",
        "_NET_NUMBER_OF_DESKTOPS",
        "_NET_CLIENT_LIST",
        "_NET_CLIENT_LIST_STACKING",
        "_NET_CURRENT_DESKTOP",
        "_NET_DESKTOP_NAMES",
        "_NET_ACTIVE_WINDOW",
        "_NET_WM_DESKTOP",
        "_NET_WM_STRUT"
      ]
  io $ changeProperty32 dpy r a c propModeReplace (fmap fromIntegral supp)

notify :: String -> X ()
notify = \case
  "" -> notifySend "<Empty>"
  str -> notifySend str
  where
    notifySend m = spawn $ "notify-send -u normal -i \"~/.xmonad/Xmonad.svg\" \"" ++ m ++ "\""

getCurrentScreen :: X ScreenId
getCurrentScreen = gets (W.screen . W.current . windowset)

getCurrentMonitor :: X (Maybe String)
getCurrentMonitor = getCurrentScreen >>= screenToMonitor

screenToMonitor :: ScreenId -> X (Maybe String)
screenToMonitor (S screenId) = do
  out <- lines <$> runProcessWithInput "xrandr" ["--listmonitors"] ""
  pure $ fmap snd . listToMaybe . filter ((screenId ==) . fst) . catMaybes . fmap parse $ out
    where
      parse line = case words line of
        a:(as@(_:_)) -> (, last as) <$> (readMaybe (init a) :: Maybe Int)
        _ -> Nothing

withMonitorRegex :: (String -> X ()) -> X ()
withMonitorRegex action = do
  monitor <- fromMaybe ".*" <$> getCurrentMonitor
  action $ "^" ++ monitor ++ "$"

hidePolybar :: String -> X ()
hidePolybar monitor = do
  spawn $ "polybar-action.sh main \"" ++ monitor ++ "\" hide"

--spawn $ "polybar-action.sh tray \"" ++ monitor ++ "\" hide"

showPolybar :: String -> X ()
showPolybar monitor =
  spawn $ "polybar-action.sh main \"" ++ monitor ++ "\" show"

togglePolybar :: String -> X ()
togglePolybar monitor =
  spawn $ "polybar-action.sh main \"" ++ monitor ++ "\" toggle"

-- toggleBars :: String -> X ()
-- toggleBars monitor = do
--   spawn $ "polybar-action.sh main \"" ++ monitor ++ "\" toggle"
--   spawn $ "polybar-action.sh tray \"" ++ monitor ++ "\" toggle"

usLayout :: X ()
usLayout = spawn "setxkbmap us -option caps:escape"

colemakLayout :: X ()
colemakLayout = spawn "setxkbmap us -variant colemak-dh -option caps:escape"

changeMonitorLayout :: String -> X ()
changeMonitorLayout s = do
  spawn s
  setWallpaper

-- My Startup Applications
myStartupHook :: X ()
myStartupHook = do
  mapM_
    spawnOnce
    [ "blueman-applet",
      "xset r rate 300 30",
      "xfce4-clipman"
      -- myHome </> "scripts/discharging.sh",
    ]
  usLayout
  setWallpaper
  setFullscreenSupport -- Adding Firefox Fullscreen Support
  notify "XMonad is running"
  spawn "rm -f /tmp/xmonad-*-log"

------------------------------------------------------------------------
---LAYOUTS
------------------------------------------------------------------------
-- Below implementation makes it easier to use spacingRaw module to set required spacing just by changing the value of i.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border i i i i) False (Border i i i i) True

myLayoutHook =
  refocusLastLayoutHook $
    avoidStruts $
      windowArrange $
        mkToggle (NBFULL ?? NOBORDERS ?? EOT) $
          myDefaultLayout
  where
    myDefaultLayout = smartBorders tall ||| noBorders full ||| smartBorders twopane

tall =
  renamed [Replace "tall"] $
    -- mySpacing 3 $
      ResizableTall 1 (3 / 100) (1 / 2) []

full =
  renamed [Replace "full"] $
      Full

twopane =
  renamed [Replace "two"] $
    TwoPanePersistent Nothing (3 / 100) (1 / 2)

------------------------------------------------------------------------
--- Log hook
------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook :: X ()
myLogHook = workspaceLogHook {-fadeInactiveLogHook fadeAmount-}
  where
    fadeAmount = 0.95

formatWithColor :: String -> String -> String
formatWithColor str color = "%{F" ++ color ++ "}" ++ str ++ "%{F-}"

createPipeIfNotExist :: FilePath -> X ()
createPipeIfNotExist logFile = io $ do
  exists <- doesFileExist logFile
  unless exists $ createNamedPipe logFile ownerModes

data MonitorSummary = MonitorSummary
  { monitorName :: !String,
    monitorWS :: !String,
    monitorFocus :: !Bool,
    monitorLayout :: !String,
    monitorWins :: !Int,
    monitorWinTitle :: !String
  }

getMonitorSummary :: Bool -> String -> (W.Workspace WorkspaceId (Layout Window) Window) -> X MonitorSummary
getMonitorSummary monitorFocus monitorName ws = do
  let monitorWS = W.tag ws
  let monitorLayout = description . W.layout $ ws
  let monitorWins = length . W.integrate' . W.stack $ ws
  monitorWinTitle <- case W.focus <$> W.stack ws of
    Nothing -> pure ""
    Just w -> show <$> getName w
  pure MonitorSummary {..}

workspaceLogHook :: X ()
workspaceLogHook = do
  winset <- gets windowset
  let screens = (W.current winset, True):[ (w, False) | w <- W.visible winset ]
  monitors <- mapM screenToMonitor . map (W.screen . fst) $ screens
  monitorSums <- sequence
    [ getMonitorSummary f m (W.workspace sc)
    | ((sc, f), Just m) <- zip screens monitors
    ]
  flip mapM_ monitorSums $ \ms -> do
    workspaceLogFile <- mkLogFile "workspace" ms
    let wsStr = concatMap (formatter ms) myWorkspaces
    io $ appendFile workspaceLogFile (wsStr ++ "\n")
    -- layout and window count
    layoutLogFile <- mkLogFile "layout" ms
    io $ appendFile layoutLogFile (monitorLayout ms ++ " (" ++ show (monitorWins ms) ++ ")\n")
    -- title
    titleLogFile <- mkLogFile "title" ms
    io $ appendFile titleLogFile (monitorWinTitle ms ++ "\n")
  where
    mkLogFile :: String -> MonitorSummary -> X (String)
    mkLogFile name ms = do
      let logFile = "/tmp/xmonad-" ++ name ++ "-" ++ monitorName ms ++ "-log"
      createPipeIfNotExist logFile
      pure logFile
    formatter :: MonitorSummary -> String -> String
    formatter ms ws
      | monitorWS ms == ws && monitorFocus ms
      = "|" ++ formatWithColor ws focusedWorkspaceColor ++ "|"
      | monitorWS ms == ws
      = "|" ++ formatWithColor ws visibleWorkspaceColor ++ "|"
      | otherwise
      = " " ++ ws ++ " "

------------------------------------------------------------------------
---KEYBINDINGS
------------------------------------------------------------------------
-- Function to toggle floating state on focused window.
toggleFloat w =
  windows
    ( \s ->
        if M.member w (W.floating s)
          then W.sink w s
          else (W.float w (W.RationalRect (1 / 6) (1 / 6) (2 / 3) (2 / 3)) s)
    )

rofiKeys :: X ()
rofiKeys = do
  action <- menuMapArgs "rofi" ["-dmenu", "-i", "-p", "Xmonad"] keyBindingMap
  fromMaybe (pure ()) action

movePointerToScreen :: Int -> X ()
movePointerToScreen screen = warpToScreen (S screen) 0.5 0.5

setWallpaper :: X ()
setWallpaper = spawn "feh --bg-scale ~/Desktop/wallpaper.png"

-- My Keybindings
keyBindings :: [(String, String, X ())]
keyBindings =
  [ -- Xmonad
    ("M-q", "Do nothing", return ()),
    ("M-S-r", "Restart Xmonad", spawn "xmonad --restart"),
    ("M-C-q", "Quit Xmonad", io exitSuccess),
    ("M-r", "Refresh current workspace", refresh),
    -- Workspaces
    ("M-<Tab>", "Toggle to the previous WS excluding NSP", CycleWS.toggleWS' ["NSP"]),
    -- Windows
    ("M-S-q", "Kill current window", kill1),
    ("M-M1-a", "Kill all windows on current workspace", killAll),
    -- ("M-f", "Full screen", sendMessage (Toggle NBFULL)), -- >> sendMessage ToggleStruts), -- >> withMonitorRegex togglePolybar),
    -- Floating Windows
    ("M-<Delete>", "Unfloat", withFocused $ windows . W.sink),
    ("M-S-<Delete>", "Unfloat all", sinkAll),
    -- Windows Navigation
    ("M-m", "Focus master window", windows W.focusMaster),
    ("M-j", "Focus next window", windows W.focusDown),
    ("M-k", "Focus previous window", windows W.focusUp),
    ("M-S-m", "Swap focus window with master window", windows W.swapMaster),
    ("M-S-j", "Swap focus window with next window", windows W.swapDown),
    ("M-S-k", "Swap focus window with prev window", windows W.swapUp),
    ("M-C-m", "Move focus window to master, all others maintain order", promote),
    ("M-,", "Resize horizontally to left", sendMessage Shrink),
    ("M-.", "Resize horizontally to right", sendMessage Expand),
    -- Screen Navigation
    ("M-h", "Move to left screen", PhysicalScreens.viewScreen def 0 >> movePointerToScreen 0),
    ("M-l", "Move to right screen", PhysicalScreens.viewScreen def 1 >> movePointerToScreen 1),
    ("M-S-h", "Shift to left screen", PhysicalScreens.sendToScreen def 0),
    ("M-S-l", "Shift to right screen", PhysicalScreens.sendToScreen def 1),
    -- Layout
    ("M-<Space>", "Switch to next layout", sendMessage NextLayout),
    ("M-S-<Space>", "Toggle float", withFocused toggleFloat),
    --("M-S-n", "Toggle border", sendMessage $ Toggle NOBORDERS),
    -- Floating Windows Actions
    ("M-<Up>", "Move floating window up", withFocused (keysMoveWindow (0, -10))),
    ("M-<Down>", "Move floating window down", withFocused (keysMoveWindow (0, 10))),
    ("M-<Right>", "Move floating window right", withFocused (keysMoveWindow (10, 0))),
    ("M-<Left>", "Move floating window left", withFocused (keysMoveWindow (-10, 0))),
    ("M-S-<Up>", "Increase size of floating window up", withFocused (keysResizeWindow (0, 10) (0, 1))),
    ("M-S-<Down>", "Increase size of floating window down", withFocused (keysResizeWindow (0, 10) (0, 0))),
    ("M-S-<Right>", "Increase size of floating window right", withFocused (keysResizeWindow (10, 0) (0, 1))),
    ("M-S-<Left>", "Increase size of floating window left", withFocused (keysResizeWindow (10, 0) (1, 1))),
    ("M-C-<Up>", "Decrease size of floating window up", withFocused (keysResizeWindow (0, -10) (0, 1))),
    ("M-C-<Down>", "Decrease size of floating window down", withFocused (keysResizeWindow (0, -10) (0, 0))),
    ("M-C-<Right>", "Decrease size of floating window right", withFocused (keysResizeWindow (-10, 0) (0, 1))),
    ("M-C-<Left>", "Decreasesize of floating window left", withFocused (keysResizeWindow (-10, 0) (1, 1))),
    -- Bar Toggle
    ("M-b", "Toggle Struts and Polybar", sendMessage ToggleStruts >> withMonitorRegex togglePolybar),
    ("M-p", "Toggle polybar", withMonitorRegex togglePolybar),
    -- Menus
    ("M-w", "Rofi windows", spawn "rofi -show combi -combi-modi \"window,drun\" -modi combi"),
    ("M-s", "Rofi ssh", spawn "rofi -show ssh -modi ssh"),
    ("M-d", "Rofi run", spawn "rofi -show run -modi run"),
    ("M-'", "Show help", rofiKeys),
    -- Multimedia keys
    ("<XF86AudioLowerVolume>", "Decrease volume", spawn "amixer -q sset Master 5%- unmute"),
    ("<XF86AudioRaiseVolume>", "Increase volume", spawn "amixer -q sset Master 5%+ unmute"),
    ("<XF86AudioMute>", "Mute", spawn "amixer -q set Master toggle"),
    ("<XF86AudioPlay>", "Play track", spawn "playerctl play-pause"),
    ("<XF86AudioPrev>", "Prev track", spawn "playerctl prev"),
    ("<XF86AudioNext>", "Next track", spawn "playerctl next"),
    ("<XF86AudioMicMute>", "Mute mic", spawn "pactl set-source-mute @DEFAULT_SOURCE@ toggle"),
    ("M-A-m", "Mute mic", spawn "pactl set-source-mute @DEFAULT_SOURCE@ toggle"),
    ("<XF86MonBrightnessDown>", "Decrease Brightness", spawn "$(which xbacklight) -dec 10"),
    ("<XF86MonBrightnessUp>", "Increase brightness", spawn "$(which xbacklight) -inc 10"),
    -- Scratchpads
    ("M-S-p", "Open Pavucontrol scratchpad", namedScratchpadAction myScratchPads "pulse"),
    -- My Applications
    ("M-<Return>", "Open Terminal", spawn myTerminal),
    ("M-g", "Open browser", spawn myBrowser),
    ("M-n", "Open editor", spawn myEditor),
    ("M-t", "Open Thunar", spawn "thunar"),
    ("M-<Print>", "Copy screenshot to clipboard", spawn "gnome-screenshot -c"),
    ("<Print>", "Open screenshot app", spawn "gnome-screenshot -i"),
    -- Mouse
    ("M-;", "Move cursor to top left corner", banishScreen UpperLeft),
    -- Monitor setup
    ("M-M1-1", "Laptop monitor only", changeMonitorLayout "switch_laptop_monitor"),
    ("M-M1-2", "External monitor only", changeMonitorLayout "switch_external_monitor"),
    -- ("M-M1-2", "Laptop + monitor", changeMonitorLayout "laptop-dual-monitor.sh"),
    -- ("M-M1-4", "Dual monitor", changeMonitorLayout "dual-monitor.sh"),
    -- Layout
    ("M--", "US Layout", usLayout),
    ("M-S--", "Colemak-dh Layout", colemakLayout),
    -- Power
    ("M-x s", "Suspend", spawn "systemctl suspend && mylock"),
    ("M-x l", "Lock", spawn "mylock"),
    ("M-x r", "Reboot", spawn "reboot")
  ]

myKeys :: [(String, X ())]
myKeys = [(kb, action) | (kb, _, action) <- keyBindings]

keyBindingMap :: M.Map String (X ())
keyBindingMap = M.fromList [(kb ++ " " ++ help, action) | (kb, help, action) <- keyBindings]

------------------------------------------------------------------------
---MAIN
------------------------------------------------------------------------
main :: IO ()
main = do
  -- Xmonad Settings
  xmonad . ewmh . docks $
    def
      { manageHook = myManageHook <+> manageDocks <+> fullscreenManageHook,
        startupHook = myStartupHook,
        layoutHook = myLayoutHook,
        handleEventHook = docksEventHook <+> fullscreenEventHook <+> refocusLastWhen (pure True),
        modMask = myModMask,
        terminal = myTerminal,
        focusFollowsMouse = False,
        borderWidth = myBorderWidth,
        normalBorderColor = myNormColor,
        focusedBorderColor = myFocusColor,
        workspaces = myWorkspaces,
        logHook = myLogHook
      }
      `additionalKeysP` myKeys
