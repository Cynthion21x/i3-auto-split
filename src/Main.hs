{-# LANGUAGE OverloadedStrings #-}

module Main where

import I3IPC
  ( connecti3
  , subscribe
  , runCommand
  )
import qualified I3IPC.Subscribe as Sub
import qualified I3IPC.Event as E
import qualified I3IPC.Reply as R
import Control.Monad (void, forever, when)
import Control.Concurrent (threadDelay)
import Network.Socket (Socket)

appVersion :: String
appVersion = "0.1.0.0"

main :: IO ()
main = do

    conn <- connecti3

    putStrLn ("I3-Auto-Split v" ++ appVersion)
    putStrLn ("Connected to i3 :D")

    subscribe (handler conn) [Sub.Window]

    forever $ threadDelay 1000000000

handler :: Socket -> Either String E.Event -> IO ()
handler conn (Right (E.Window ev)) 
    | E.win_change ev == E.WinNew = handleNewWin conn ev
    | otherwise = return () 
handler _ (Left err) = putStrLn $ "Error :c : " ++ err
handler _ _ = return ()

handleNewWin :: Socket -> E.WindowEvent -> IO ()
handleNewWin conn ev = do

    let node = E.win_container ev
    let nodeType = R.node_type node
    let nodeName = R.node_name node

    putStrLn $ "New window type: " ++ show nodeType
    putStrLn $ "New window name: " ++ show nodeName
    
    when (isTilingWindow ev) $ do
        putStrLn "Handling new window"
        void $ runCommand conn "split toggle"

isTilingWindow :: E.WindowEvent -> Bool
isTilingWindow ev = nodeType /= R.FloatingConType && 
                    not (isNotification)
    where node = E.win_container ev
          nodeName = R.node_name node
          nodeType = R.node_type node

          isNotification = case nodeName of
              
              Just name -> name `elem` ["xfce4-notifyd", "dunst"] 
              Nothing -> False

