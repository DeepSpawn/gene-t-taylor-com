{-# LANGUAGE OverloadedStrings #-}
import           Clay

myStylesheet :: Css
myStylesheet = body ? background red

main :: IO ()
main = putCss myStylesheet