module Index exposing (view)

import Data.Author
import Date
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Html.Attributes as Attr
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> Element msg
view posts =
    Element.column [ Element.spacing 10 ]
        (posts
            |> List.filterMap
                (\( path, metadata ) ->
                    case metadata of
                        Metadata.Page meta ->
                            Nothing

                        Metadata.Author _ ->
                            Nothing

                        Metadata.Article meta ->
                            if meta.draft then
                                Nothing

                            else
                                Just ( path, meta )

                        Metadata.BlogIndex ->
                            Nothing
                )
            |> List.map postSummary
        )


postSummary :
    ( PagePath Pages.PathKey, Metadata.ArticleMetadata )
    -> Element msg
postSummary ( postPath, post ) =
    articleIndex post
        |> linkToPost postPath


linkToPost : PagePath Pages.PathKey -> Element msg -> Element msg
linkToPost postPath content =
    Element.link [ Element.width Element.fill ]
        { url = PagePath.toString postPath, label = content }


title : String -> Element msg
title text =
    [ Element.text text ]
        |> Element.paragraph
            [ Element.Font.size 26
            , Element.Font.center
            , Element.Font.family [ Element.Font.typeface "Montserrat" ]
            , Element.Font.semiBold
            , Element.padding 16
            , Element.Font.color (Element.rgba255 0 0 0 0.7)
            ]


articleIndex : Metadata.ArticleMetadata -> Element msg
articleIndex metadata =
    Element.el
        [ Element.centerX
        , Element.width (Element.maximum 700 Element.fill)
        , Element.padding 30
        , Element.spacing 10
        , Element.Border.rounded 15
        , Element.htmlAttribute (Attr.class "article")
        ]
        (postPreview metadata)


readMoreLink =
    Element.text "Continue reading >>"
        |> Element.el
            [ Element.centerX
            , Element.Font.size 16
            , Element.alpha 0.6
            , Element.Font.underline
            , Element.Font.center
            , Element.Font.color (Element.rgba255 0 0 0 1)
            ]


postPreview : Metadata.ArticleMetadata -> Element msg
postPreview post =
    Element.textColumn
        [ Element.centerX
        , Element.width Element.fill
        , Element.spacing 15
        , Element.Font.size 14
        ]
        [ title post.title
        , Element.row [ Element.spacing 10, Element.centerX ]
            [ Data.Author.view [ Element.width (Element.px 40) ] post.author
            , Element.text post.author.name
            , Element.text "•"
            , Element.text (post.published |> Date.format "MMMM ddd, yyyy")
            ]
        , post.description
            |> Element.text
            |> List.singleton
            |> Element.paragraph
                [ Element.Font.size 16
                , Element.Font.center
                , Element.Font.family [ Element.Font.typeface "Montserrat" ]
                ]
        , readMoreLink
        ]
