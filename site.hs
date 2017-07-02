--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Data.Maybe (fromMaybe)
import           Hakyll.Web.Sass (sassCompiler)
import           Hakyll.Web.Redirect (createRedirects)
import           Text.Pandoc.Options
import           Skylighting.Styles
---------------------------------------------------------------------------

base_url :: String
-- base_url = "http://gene-t-taylor.com"
base_url = "http://127.0.0.1:8000"

siteCtx :: Hakyll.Context String
siteCtx = constField "site.title" "Gene Taylor" `mappend`
          constField "site.owner.twitter" "SplicedGene"


-- postCtxWithTags :: Tags -> Context String
-- tagsCtx tags = tagsField "tags" tags 

postCtx :: Hakyll.Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    dateField "dateISO" "%Y-%m-%dT%H:%M:%S" `mappend`
    constField "base_url" base_url `mappend`
    listField "recentPosts" postCtx recentPosts `mappend`
    -- listField "recentPosts" postCtx ((loadAllSnapshots "pages/*" "forListing") >>= \x -> pure(take 3 x)) `mappend`
    siteCtx `mappend`
    defaultContext

-- tags <- buildTags "posts/*" (fromCapture "tags/*.html") 


compileMenu :: Rules ()
compileMenu = match "posts/*" $ version "menu" $ compile destination

destination :: Compiler (Item String)
destination = setVersion Nothing <$> getUnderlying
                >>= getRoute
                >>= makeItem . fromMaybe ""

-- getMenu :: Compiler String
-- getMenu = do
--     all <- loadAll (fromVersion $ Just "menu")
--     recent <- recentFirst all
--     recentPosts <- pure(take 3 recent)
--     return recentPosts    

    --    all <- loadAll (fromVersion $ Just "menu")
    --         recent <- recentFirst all
    --         recentPosts <- pure(take 3 recent)

recentPosts :: Compiler [Item String]
recentPosts  = do
    identifiers <- getMatches "posts/*"
    -- saveSnapshot "forListing"
    ordered <- recentFirst $ [Item identifier "" | identifier <- identifiers]
    return (take 3 ordered)

allPosts :: Compiler [Item String]
allPosts  = do
    identifiers <- getMatches "posts/*"
    ordered <- recentFirst $ [Item identifier "" | identifier <- identifiers]
    return ordered

myPandocCompiler =
  pandocCompilerWith
    defaultHakyllReaderOptions
    defaultHakyllWriterOptions
      { writerHtml5            = True
      , writerHighlight        = True
      , writerHighlightStyle   = pygments
      , writerHTMLMathMethod   = MathML Nothing                         
      , writerEmailObfuscation = NoObfuscation
      }
main :: IO ()
main = hakyll $ do




    -- create static redirect pages for outdated/broken incoming links (goes first so any collisions with content, the redirects will lose)
    version "redirects" $ createRedirects brokenLinks

    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "about.markdown" $ do
        route   $ setExtension "html"
        compile $ myPandocCompiler
            >>= loadAndApplyTemplate "templates/page.html" (constField "noSocial" "true" `mappend` postCtx)
            >>= relativizeUrls
    
    -- compileMenu 

    -- let rrecentPosts = compile $ do
    --         (recentFirst =<< loadAll "posts/*") >>= pure(take 3 allPosts)

    -- match "posts/*" $ version "forListing" $ do
    --     compile $ getResourceString >>= saveSnapshot "forListing"

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ do 
            -- let indexCtx =  listField "recentPosts" postCtx (return rrecentPosts) `mappend`
            --                   ((listField "recentPosts" postCtx fakePosts) `mappend` postCtx)
            myPandocCompiler
            >>= loadAndApplyTemplate "templates/post.html" postCtx
            >>= relativizeUrls
            -- saveSnapshot "map"

-- //listField "pages" context (loadAllSnapshots "pages/*" "map")


    -- create ["sitemap.xml"] $ do
    --      route   idRoute
    --      compile $ do
    --        posts <- recentFirst =<< loadAll "posts/*"
    --        about <- load "about.markdown"
    --        index <- load "index.html"
    --        let allPosts = (return (posts ++ [about, index]))
    --        let sitemapCtx = listField "entries" postCtx allPosts  `mappend`
    --                         constField "host" base_url            `mappend`
    --                         defaultContext
    --        makeItem ""
    --         >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx
    --         >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            -- allPosts <- recentFirst =<< (loadAll ("posts/*" .&&. hasVersion "forListing"))
            -- recentPosts <- pure(take 3 allPosts)
            -- let indexCtx =  listField "allPosts" postCtx (return allPosts) `mappend`
            --                 listField "recentPosts" postCtx (return recentPosts) `mappend`
            --                 constField "title" "Recent Posts" `mappend`
            --                 siteCtx `mappend`
            --                 dateField "date" "%B %e, %Y" `mappend`
            --                 dateField "dateISO" "%Y-%m-%dT%H:%M:%S" `mappend`
            --                 constField "base_url" base_url `mappend`
            --                 defaultContext
            myPandocCompiler
                >>= loadAndApplyTemplate "templates/home.html" postCtx
                >>= relativizeUrls

    match "archive.md" $ do
        route $ setExtension "html"
        compile $ do
            let archiveCtx =
                    listField "posts" postCtx allPosts `mappend`
                    constField "title" "Archives"            `mappend`
                    siteCtx                                  `mappend`
                    dateField "date" "%B %e, %Y" `mappend`
                    dateField "dateISO" "%Y-%m-%dT%H:%M:%S" `mappend`
                    constField "base_url" base_url `mappend`
                    listField "recentPosts" postCtx recentPosts `mappend`
                    defaultContext
            myPandocCompiler
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/page.html" archiveCtx
                >>= relativizeUrls
                    

    match "templates/*" $ compile templateCompiler
    match "templates/*/*" $ compile templateCompiler

    match "assets/css/i.scss" $ do
        route $ setExtension "css"
        let compressCssItem = fmap compressCss
        compile (compressCssItem <$> sassCompiler)

    match ( "assets/fonts/*"
            .||. "assets/js/*" 
            .||. "assets/js/vendor/*" 
            .||. "assets/*.png"
            .||. "assets/*.ico" 
            .||. "assets/css/fonts/*" 
            .||. "assets/css/entypo.css") $ do
          route   idRoute
          compile copyFileCompiler       

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
