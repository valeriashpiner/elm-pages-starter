module Main exposing (main)

import Color
import Data.Author as Author
import Date
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font as Font
import Element.Region
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Index
import Json.Decode
import Markdown
import Metadata exposing (Metadata)
import Pages exposing (images, pages)
import Pages.Directory as Directory exposing (Directory)
import Pages.Document
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import Palette


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.education ]
    , displayMode = Manifest.Standalone
    , orientation = Manifest.Portrait
    , description = "unicorns & me - React Girl's Blog"
    , iarcRatingId = Nothing
    , name = "unicorns & me"
    , themeColor = Just Color.white
    , startUrl = pages.index
    , shortName = Just "unicorns & me"
    , sourceIcon = images.iconPng
    }


type alias Rendered =
    Element Msg



-- the intellij-elm plugin doesn't support type aliases for Programs so we need to use this line
-- main : Platform.Program Pages.Platform.Flags (Pages.Platform.Model Model Msg Metadata Rendered) (Pages.Platform.Msg Msg Metadata Rendered)


main : Pages.Platform.Program Model Msg Metadata Rendered
main =
    Pages.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ markdownDocument ]
        , head = head
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        }


markdownDocument : ( String, Pages.Document.DocumentHandler Metadata Rendered )
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = Metadata.decoder
        , body =
            \markdownBody ->
                Html.div [] [ Markdown.toHtml [] markdownBody ]
                    |> Element.html
                    |> List.singleton
                    |> Element.paragraph [ Element.width Element.fill ]
                    |> Ok
        }


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( Model, Cmd.none )


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        () ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> List ( PagePath Pages.PathKey, Metadata ) -> Page Metadata Rendered Pages.PathKey -> { title : String, body : Html Msg }
view model siteMetadata page =
    let
        { title, body } =
            pageView model siteMetadata page
    in
    { title = title
    , body =
        body
            |> Element.layout
                [ Element.width Element.fill
                , Font.size 16
                , Font.family [ Font.typeface "Montserrat" ]
                , Font.color (Element.rgba255 0 0 0 0.8)
                ]
    }


pageView : Model -> List ( PagePath Pages.PathKey, Metadata ) -> Page Metadata Rendered Pages.PathKey -> { title : String, body : Element Msg }
pageView model siteMetadata page =
    case page.metadata of
        Metadata.Page metadata ->
            { title = metadata.title
            , body =
                [ header page.path
                , Element.column
                    [ Element.padding 50
                    , Element.spacing 60
                    , Element.Region.mainContent
                    ]
                    [ page.view
                    ]
                ]
                    |> Element.textColumn
                        [ Element.width Element.fill
                        ]
            }

        Metadata.Article metadata ->
            { title = metadata.title
            , body =
                Element.column [ Element.width Element.fill ]
                    [ header page.path
                    , Element.column
                        [ Element.padding 30
                        , Element.spacing 40
                        , Element.Region.mainContent
                        , Element.width (Element.fill |> Element.maximum 800)
                        , Element.centerX
                        ]
                        (Element.column [ Element.spacing 10 ]
                            [ Element.row [ Element.spacing 10 ]
                                [ Author.view [] metadata.author
                                , Element.column [ Element.spacing 10, Element.width Element.fill ]
                                    [ Element.paragraph [ Font.bold, Font.size 16 ]
                                        [ Element.text metadata.author.name
                                        ]
                                    , Element.paragraph [ Font.size 16 ]
                                        [ Element.text metadata.author.bio ]
                                    ]
                                ]
                            ]
                            :: (publishedDateView metadata |> Element.el [ Font.size 16, Font.color (Element.rgba255 0 0 0 0.6) ])
                            :: Palette.blogHeading metadata.title
                            :: articleImageView metadata.image
                            :: [ page.view ]
                        )
                    ]
            }

        Metadata.Author author ->
            { title = author.name
            , body =
                Element.column
                    [ Element.width Element.fill
                    ]
                    [ header page.path
                    , Element.column
                        [ Element.padding 30
                        , Element.spacing 20
                        , Element.Region.mainContent
                        , Element.width (Element.fill |> Element.maximum 800)
                        , Element.centerX
                        ]
                        [ Palette.blogHeading author.name
                        , Author.view [] author
                        , Element.paragraph [ Element.centerX, Font.center ] [ page.view ]
                        ]
                    ]
            }

        Metadata.BlogIndex ->
            { title = "unicorns & me"
            , body =
                Element.column [ Element.width Element.fill, Element.htmlAttribute (Attr.class "body") ]
                    [ header page.path
                    , Element.column [ Element.padding 0, Element.centerX, Element.padding 10 ] [ Index.view siteMetadata ]
                    , footer
                    ]
            }


articleImageView : ImagePath Pages.PathKey -> Element msg
articleImageView articleImage =
    Element.image [ Element.width Element.fill ]
        { src = ImagePath.toString articleImage
        , description = "Article cover photo"
        }


header : PagePath Pages.PathKey -> Element msg
header currentPath =
    Element.column [ Element.width Element.fill ]
        [ Element.el
            [ Element.height (Element.px 4)
            , Element.width Element.fill
            , Element.Background.gradient
                { angle = 0.2
                , steps =
                    [ Element.rgb255 255 191 224
                    , Element.rgb255 191 217 254
                    ]
                }
            ]
            Element.none
        , Element.row
            [ Element.paddingXY 25 4
            , Element.spaceEvenly
            , Element.width Element.fill
            , Element.Region.navigation
            ]
            [ Element.link []
                { url = "/"
                , label =
                    Element.row [ Font.size 16, Element.spacing 14 ]
                        [ Element.image
                            [ Element.width (Element.px 44)
                            ]
                            { src = ImagePath.toString Pages.images.iconPng, description = "Logo" }
                        , Element.text "unicorns & me"
                        ]
                }
            , Element.row [ Element.spacing 15 ]
                [ twitterLink
                , telegramLink
                ]
            ]
        ]


highlightableLink :
    PagePath Pages.PathKey
    -> Directory Pages.PathKey Directory.WithIndex
    -> String
    -> Element msg
highlightableLink currentPath linkDirectory displayName =
    let
        isHighlighted =
            currentPath |> Directory.includes linkDirectory
    in
    Element.link
        (if isHighlighted then
            [ Font.underline
            , Font.color Palette.color.primary
            ]

         else
            []
        )
        { url = linkDirectory |> Directory.indexPath |> PagePath.toString
        , label = Element.text displayName
        }


head : Metadata -> List (Head.Tag Pages.PathKey)
head metadata =
    case metadata of
        Metadata.Page meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "unicorns & me"
                , image =
                    { url = images.iconPng
                    , alt = "elm-pages logo"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = siteTagline
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.website

        Metadata.Article meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "elm-pages starter"
                , image =
                    { url = meta.image
                    , alt = meta.description
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = meta.description
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.article
                    { tags = []
                    , section = Nothing
                    , publishedTime = Just (Date.toIsoString meta.published)
                    , modifiedTime = Nothing
                    , expirationTime = Nothing
                    }

        Metadata.Author meta ->
            let
                ( firstName, lastName ) =
                    case meta.name |> String.split " " of
                        [ first, last ] ->
                            ( first, last )

                        [ first, middle, last ] ->
                            ( first ++ " " ++ middle, last )

                        [] ->
                            ( "", "" )

                        _ ->
                            ( meta.name, "" )
            in
            Seo.summary
                { canonicalUrlOverride = Nothing
                , siteName = "unicorns & me"
                , image =
                    { url = meta.avatar
                    , alt = meta.name ++ "'s elm-pages articles."
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = meta.bio
                , locale = Nothing
                , title = meta.name ++ "'s elm-pages articles."
                }
                |> Seo.profile
                    { firstName = firstName
                    , lastName = lastName
                    , username = Nothing
                    }

        Metadata.BlogIndex ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "elm-pages"
                , image =
                    { url = images.iconPng
                    , alt = "elm-pages logo"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = siteTagline
                , locale = Nothing
                , title = "elm-pages blog"
                }
                |> Seo.website


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://unicornsandme.netlify.com/"


siteTagline : String
siteTagline =
    "unicorns & me"


publishedDateView metadata =
    Element.text
        (metadata.published
            |> Date.format "MMMM ddd, yyyy"
        )


telegramLink : Element msg
telegramLink =
    Element.newTabLink []
        { url = "https://t.me/unicornsandme"
        , label =
            Element.image
                [ Element.width (Element.px 24)
                , Font.color Palette.color.primary
                ]
                { src = ImagePath.toString Pages.images.telegramLogo, description = "Telegram chanel" }
        }


twitterLink : Element msg
twitterLink =
    Element.newTabLink []
        { url = "https://twitter.com/react_girl"
        , label =
            Element.image
                [ Element.width (Element.px 24)
                , Font.color Palette.color.primary
                ]
                { src = ImagePath.toString Pages.images.twitterLogo, description = "Twitter Link" }
        }


footer =
    Element.text "Created with Elm and 💛 by React Girl"
        |> Element.el
            [ Element.centerX
            , Font.size 16
            , Element.alpha 0.6
            , Font.center
            , Font.color (Element.rgba255 0 0 0 1)
            , Element.htmlAttribute (Attr.class "footer")
            ]
