module Main where

import System.Environment (getArgs)
import System.Exit
import qualified Data.ByteString.Char8 as BC
import qualified Bencode as Benc
import qualified Metainfo as MInfo
import qualified Tracker as T
import qualified Text.ParserCombinators.Parsec as Parsec
import Data.Functor

printError :: Parsec.ParseError -> IO ()
printError e = putStrLn $ "parse error: " ++ show e

genPeerId :: String
genPeerId = "-HS0001-20150215"

exit :: IO BC.ByteString
exit = exitWith ExitSuccess

usage :: IO ()
usage = putStrLn "usage: deluge torrent-file"

parse :: [String] -> IO (BC.ByteString)
parse [] = usage >> exit
parse [a] = BC.readFile a
parse _ = exit

main :: IO ()
main = do
  args <- getArgs
  torrentStr <- parse args
  case (Benc.decode torrentStr) of
   Right d -> case (MInfo.mkMetaInfo d) of
               Nothing -> putStrLn "parse error"
               Just m -> do
                 body <- (Benc.decode . BC.pack) <$> T.connect (MInfo.announce m) (T.prepareRequest d genPeerId)
                 putStrLn (show body)
   Left e -> printError e
  putStrLn "done"
