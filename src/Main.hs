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
import qualified Data.Text as T
import Control.Monad (void, forever, when)
import Control.Concurrent (threadDelay)
import Network.Socket (Socket)
import System.Environment (getArgs)

appVersion :: String
appVersion = "0.2.1.1"

data Config = Config
    { verbose :: Bool
    , ignoreWindows :: [String]
    , threadTime :: Int
    }

defaultConfig :: Config
defaultConfig = Config
    { verbose = False
    , ignoreWindows = ["xfce4-notifyd", "dunst"]
    , threadTime = 1000000000
    }

parseArgs :: [String] -> Config
parseArgs x = process x defaultConfig

    where process [] config = config
          process ("-v":xs) config = process xs config { verbose = True }
          process ("-i":arg:xs) config = process xs config { ignoreWindows = splitWindows arg } 
          process ("-t":arg:xs) config = process xs config { threadTime = read arg }
          process (_:xs) config = process xs config

          splitWindows :: String -> [String]
          splitWindows = words . map (\c -> if c == ',' then ' ' else c)

main :: IO ()
main = do

    args <- getArgs
    let config = parseArgs args

    when (verbose config) $ do
        putStrLn $ "Arguments: " ++ show args
        putStrLn $ "Ignoring windows: " ++ show (ignoreWindows config)

    putStrLn $ "I3-Auto-Split v" ++ appVersion

    conn <- connecti3
    putStrLn "Connected to i3 :D"

    subscribe (handler config conn) [Sub.Window]

    forever $ threadDelay (threadTime config) 

handler :: Config -> Socket -> Either String E.Event -> IO ()
handler config conn (Right (E.Window ev)) 
    | E.win_change ev == E.WinNew = handleNewWin config conn ev
    | E.win_change ev == E.WinFocus = handleNewWin config conn ev
    | otherwise = return () 
handler _ _ (Left err) = putStrLn $ "Error :c : " ++ err
handler _ _ _ = return ()

handleNewWin :: Config -> Socket -> E.WindowEvent -> IO ()
handleNewWin config conn ev = do

    let node = E.win_container ev
    let nodeSize = R.node_rect node

    when (verbose config) $ do

        let nodeType = R.node_type node
        let nodeName = R.node_name node

        let eventType = E.win_change ev

        putStrLn $ "New window type: " ++ show nodeType
        putStrLn $ "New window name: " ++ show nodeName
        putStrLn $ "New window size: " ++ show nodeSize
        putStrLn $ "Event: " ++ show eventType 
    
    when (isTilingWindow config ev) $ do

        putStrLn "Handling new window"

        let winW = R.width nodeSize
        let winH = R.height nodeSize

        if (winW <= winH)
            then void $ runCommand conn "split v"
            else void $ runCommand conn "split h"

isTilingWindow :: Config -> E.WindowEvent -> Bool
isTilingWindow config ev = nodeType /= R.FloatingConType && 
                           not (isNotification)
    where node = E.win_container ev
          nodeName = R.node_name node
          nodeType = R.node_type node

          isNotification = case nodeName of
              
              Just name -> T.unpack name `elem` (ignoreWindows config)
              Nothing -> False

