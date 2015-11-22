import StartApp.Simple
import Html.Attributes exposing (..)
import Html exposing (..)
import Html.Events exposing (..)

main =
  StartApp.Simple.start
    { model = init
    , update = update
    , view = view
    }

type alias Price = Int

type Rate = Once
          | Weekly
          | Monthly

type alias Model = { price : Price, rate : Rate }

type Action = UpdateRate Rate
            | UpdatePrice Price

init : Model
init = { price = 10, rate = Monthly }

update : Action -> Model -> Model
update action model = model

-- The address (aka update function) takes an action
view : Signal.Address Action -> Model -> Html
view address model =
  div [ class "container" ]
    [ h1 [] [ text "The true cost" ]
    , div [] [ text "of" ]
    , div [] [ text "your purchases" ]
    , div [ class "cost-container" ]
        [ input [ type' "text", value "100" ] [] ]
    , div [ class "rate-container" ]
        [ span [ class "rate-choice once" ] [ text "once" ]
        , span [ class "rate-choice monthly" ] [ text "monthly" ]
        , span [ class "rate-choice weekly" ] [ text "weekly" ]
        -- [ a [ href "#" ] [ span [ class "rate-choice once" ] [ text "once" ] ]
        -- , a [ href "#" ] [ span [ class "rate-choice weekly" ] [ text "weekly" ] ]
        -- , a [ href "#" ] [ span [ class "rate-choice monthly" ] [ text "monthly" ] ]
        ]
    , div [ class "true-cost-container" ]
        [ div [ class "true-cost-dollars" ] [ text "$138" ]
        , div [ class "true-cost-years" ] [ text "over 10 years" ]
        ]
    , div [ class "true-cost-container" ]
        [ div [ class "true-cost-dollars" ] [ text "$1380" ]
        , div [ class "true-cost-years" ] [ text "over 20 years" ]
        ]
    , div [ class "true-cost-container" ]
        [ div [ class "true-cost-dollars" ] [ text "$5380" ]
        , div [ class "true-cost-years" ] [ text "over 30 years" ]
        ]
    , div [ class "footer" ] [ text "Assuming 7% YOY gain" ]
    ]

containerStyle : Attribute
containerStyle =
  style
    [ ("font-size", "20px")
    , ("font-family", "monospace")
    , ("background-color", "red")
    , ("max-width", "480px")
    , ("margin-left", "auto")
    , ("margin-right", "auto")
    ]

