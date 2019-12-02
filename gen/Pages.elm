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
    [ (buildPage [ "article", "a1-hello" ])
    , (buildPage [ "article", "a2-how-to-memorize-better" ])
    , (buildPage [ "article", "a3-spaced-repetition" ])
    , (buildPage [ "article", "a4-how-to-manage-your-study" ])
    , (buildPage [  ])
    ]

pages =
    { article =
        { a1Hello = (buildPage [ "article", "a1-hello" ])
        , a2HowToMemorizeBetter = (buildPage [ "article", "a2-how-to-memorize-better" ])
        , a3SpacedRepetition = (buildPage [ "article", "a3-spaced-repetition" ])
        , a4HowToManageYourStudy = (buildPage [ "article", "a4-how-to-manage-your-study" ])
        , directory = directoryWithoutIndex ["article"]
        }
    , index = (buildPage [  ])
    , directory = directoryWithIndex []
    }

images =
    { articleCovers =
        { hello = (buildImage [ "article-covers", "hello.png" ])
        , howToManageYourStudy = (buildImage [ "article-covers", "how-to-manage-your-study.png" ])
        , howToMemorizeBetter = (buildImage [ "article-covers", "how-to-memorize-better.jpeg" ])
        , spacedRepetition = (buildImage [ "article-covers", "spaced-repetition.png" ])
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
    , (buildImage [ "article-covers", "how-to-manage-your-study.png" ])
    , (buildImage [ "article-covers", "how-to-memorize-better.jpeg" ])
    , (buildImage [ "article-covers", "spaced-repetition.png" ])
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
  ( ["article", "a1-hello"]
    , { frontMatter = """{"type":"blog","author":"React Girl","title":"✨ Hello, world!","description":"C вами на связи с французских земель Канады React Girl и вы в блоге unicorns&me. Этот блог - моё пространство, где я описываю, как я ставлю себе цели и достигаю их, а также это перенос и продолжение моего большого треда в твиттере о том, как я учу французский язык.","image":"/images/article-covers/hello.png","published":"2019-10-20"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["article", "a2-how-to-memorize-better"]
    , { frontMatter = """{"type":"blog","author":"React Girl","title":"✨ How to memorize better","description":"Сегодня мы с вами поговорим о том, как лучше запоминать иностранные слова.","image":"/images/article-covers/how-to-memorize-better.jpeg","published":"2019-10-22"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["article", "a3-spaced-repetition"]
    , { frontMatter = """{"type":"blog","author":"React Girl","title":"✨ Spaced Repetition","description":"Spaced Repetition - это мощный инструмент в изучении нового материала. Читайте дальше о том, что это за эффект и как с этим связан наш мозг.","image":"/images/article-covers/spaced-repetition.png","published":"2019-11-03"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["article", "a4-how-to-manage-your-study"]
    , { frontMatter = """{"type":"blog","author":"React Girl","title":"✨ How to manage your study","description":"Правильное планирование - это мотивация, успешное обучение и сохранение сил. Читай 🖤","image":"/images/article-covers/how-to-manage-your-study.png","published":"2019-12-02"}
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
