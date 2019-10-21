port module Pages exposing (PathKey, allPages, allImages, application, images, isValidRoute, pages)

import Color exposing (Color)
import Head
import Html exposing (Html)
import Json.Decode
import Json.Encode
import Mark
import Pages.Platform
import Pages.ContentCache exposing (Page)
import Pages.Manifest exposing (DisplayMode, Orientation)
import Pages.Manifest.Category as Category exposing (Category)
import Url.Parser as Url exposing ((</>), s)
import Pages.Document as Document
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Directory as Directory exposing (Directory)


type PathKey
    = PathKey


buildImage : List String -> ImagePath PathKey
buildImage path =
    ImagePath.build PathKey ("images" :: path)



buildPage : List String -> PagePath PathKey
buildPage path =
    PagePath.build PathKey path


directoryWithIndex : List String -> Directory PathKey Directory.WithIndex
directoryWithIndex path =
    Directory.withIndex PathKey allPages path


directoryWithoutIndex : List String -> Directory PathKey Directory.WithoutIndex
directoryWithoutIndex path =
    Directory.withoutIndex PathKey allPages path


port toJsPort : Json.Encode.Value -> Cmd msg


application :
    { init : ( userModel, Cmd userMsg )
    , update : userMsg -> userModel -> ( userModel, Cmd userMsg )
    , subscriptions : userModel -> Sub userMsg
    , view : userModel -> List ( PagePath PathKey, metadata ) -> Page metadata view PathKey -> { title : String, body : Html userMsg }
    , head : metadata -> List (Head.Tag PathKey)
    , documents : List ( String, Document.DocumentHandler metadata view )
    , manifest : Pages.Manifest.Config PathKey
    , canonicalSiteUrl : String
    }
    -> Pages.Platform.Program userModel userMsg metadata view
application config =
    Pages.Platform.application
        { init = config.init
        , view = config.view
        , update = config.update
        , subscriptions = config.subscriptions
        , document = Document.fromList config.documents
        , content = content
        , toJsPort = toJsPort
        , head = config.head
        , manifest = config.manifest
        , canonicalSiteUrl = config.canonicalSiteUrl
        , pathKey = PathKey
        }



allPages : List (PagePath PathKey)
allPages =
    [ (buildPage [ "article", "hello" ])
    , (buildPage [  ])
    ]

pages =
    { article =
        { hello = (buildPage [ "article", "hello" ])
        , directory = directoryWithoutIndex ["article"]
        }
    , index = (buildPage [  ])
    , directory = directoryWithIndex []
    }

images =
    { articleCovers =
        { hello = (buildImage [ "article-covers", "hello.png" ])
        , directory = directoryWithoutIndex ["articleCovers"]
        }
    , author =
        { valeria = (buildImage [ "author", "valeria.png" ])
        , directory = directoryWithoutIndex ["author"]
        }
    , iconPng = (buildImage [ "icon-png.png" ])
    , icon = (buildImage [ "icon.svg" ])
    , telegramLogo = (buildImage [ "telegram-logo.svg" ])
    , twitterLogo = (buildImage [ "twitter-logo.svg" ])
    , directory = directoryWithoutIndex []
    }

allImages : List (ImagePath PathKey)
allImages =
    [(buildImage [ "article-covers", "hello.png" ])
    , (buildImage [ "author", "valeria.png" ])
    , (buildImage [ "icon-png.png" ])
    , (buildImage [ "icon.svg" ])
    , (buildImage [ "telegram-logo.svg" ])
    , (buildImage [ "twitter-logo.svg" ])
    ]


isValidRoute : String -> Result String ()
isValidRoute route =
    let
        validRoutes =
            List.map PagePath.toString allPages
    in
    if
        (route |> String.startsWith "http://")
            || (route |> String.startsWith "https://")
            || (route |> String.startsWith "#")
            || (validRoutes |> List.member route)
    then
        Ok ()

    else
        ("Valid routes:\n"
            ++ String.join "\n\n" validRoutes
        )
            |> Err


content : List ( List String, { extension: String, frontMatter : String, body : Maybe String } )
content =
    [ 
  ( ["article", "hello"]
    , { frontMatter = """{"type":"blog","author":"React Girl","title":"✨ Hello, world!","description":"C вами на связи с французских земель Канады React Girl и вы в блоге unicorns&me. Этот блог - моё пространство, где я описываю, как я ставлю себе цели и достигаю их, а также это перенос и продолжение моего большого треда в твиттере о том, как я учу французский язык...","image":"/images/article-covers/hello.png","published":"2019-10-20"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( []
    , { frontMatter = """{"title":"elm-pages blog","type":"blog-index"}
""" , body = Nothing
    , extension = "md"
    } )
  
    ]
