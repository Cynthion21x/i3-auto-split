{-# LANGUAGE OverloadedStrings #-}

module Main where

import I3IPC
  ( connecti3
  , subscribe
  , runCommand
  )
import qualified I3IPC.Subscribe as Sub
import qualified I3IPC.Event as E
import Control.Concurrent.MVar
import Control.Monad (void, forever)
import Control.Concurrent (threadDelay)
import Network.Socket (Socket)

main :: IO ()
main = do

    conn <- connecti3
    putStrLn "Connected to i3 ^.^"

    splitVar <- newMVar True

    subscribe (handler conn splitVar) [Sub.Window]
    
    forever $ threadDelay 1000000000

handler :: Socket -> MVar Bool -> Either String E.Event -> IO ()
handler conn splitVar event = 
    case event of

        Right (E.Window ev) -> 

            case E.win_change ev of

                E.WinNew -> do

                    putStrLn "Found you making a new window"

                    horizontal <- takeMVar splitVar

                    let cmd = if horizontal then "split v" else "split h"
                    void $ runCommand conn cmd
                    putMVar splitVar (not horizontal)

                changeType -> 
                    putStrLn $ "Ignoring window event: " ++ show changeType

        Right _ -> return ()

        Left err -> 
            putStrLn $ "ERROR: " ++ err
