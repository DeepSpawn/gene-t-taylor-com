--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Hakyll.Web.Sass (sassCompiler)
import           Hakyll.Web.Redirect (createRedirects)
---------------------------------------------------------------------------

base_url :: String
base_url = "http://gene-t-taylor.com"

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    dateField "dateISO" "%Y-%m-%dT%H:%M:%S" `mappend`
    constField "base_url" base_url `mappend`
    defaultContext


main :: IO ()
main = hakyll $ do

    -- create static redirect pages for outdated/broken incoming links (goes first so any collisions with content, the redirects will lose)
    version "redirects" $ createRedirects brokenLinks

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match (fromList ["about.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    create ["sitemap.xml"] $ do
         route   idRoute
         compile $ do
           posts <- recentFirst =<< loadAll "posts/*"
           about <- load "about.markdown"
           archive <- load "archive.html"
           index <- load "index.html"
           let allPosts = (return (posts ++ [about, archive, index]))
           let sitemapCtx = listField "entries" postCtx allPosts  `mappend`
                            constField "host" base_url            `mappend`
                            defaultContext
           makeItem ""
            >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx
            >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

    match "scss/*.scss" $ do
        route $ setExtension "css"
        let compressCssItem = fmap compressCss
        compile (compressCssItem <$> sassCompiler)

-------------------------------------------------------------------------------- 

--   For use with `createRedirects`.
brokenLinks :: [(Identifier,FilePath)]
brokenLinks = [
   ("2016/11/13/mockito-varargs-matcher/index.html", "/posts/2016-11-13-mockito-varargs-matcher.html")
 , ("2016/11/07/haskell-course/index.html", "/posts/2016-11-07-haskell-course.html")
 , ("2016/07/20/CompletableFuture-sequence/index.html", "/posts/2016-07-20-CompletableFuture-sequence.html")
 , ("2016/06/28/pattern-matching-in-java/index.html", "/posts/2016-06-28-pattern-matching-in-java.html")
 , ("2016/03/26/guava-immutablemap-collector/index.html", "/posts/2016-03-26-guava-immutablemap-collector.html")
 ]
