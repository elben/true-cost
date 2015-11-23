import StartApp.Simple
import Html.Attributes exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import String
import Regex

main =
  StartApp.Simple.start
    { model = initModel
    , update = update
    , view = view
    }

----------
-- MODEL
----------

defaultRate : Float
defaultRate = 1.07

type alias Years = Int
type alias Price = Float
type alias Cost = Int

type Rate = Once
          | Weekly
          | Monthly

rateToString : Rate -> String
rateToString rate =
  case rate of
    Once -> "once"
    Weekly -> "weekly"
    Monthly -> "monthly"

type alias Model = { price : Price, rate : Rate }

type Action = UpdateRate Rate
            | UpdatePrice Price

-- Calculate true cost for one-off purchases
calculateTrueCost : Model -> Years -> Float
calculateTrueCost model years =
  case model.rate of
    Once -> model.price * (1.07 ^ (toFloat years))
    Weekly -> sumOfTrueCost (model.price * 52.5) years
    Monthly -> sumOfTrueCost (model.price * 12) years

{-| Calculates the true cost, given a yearly cost and the number of years. For
example, to calculate the true cost of $10/month for 20 years:

  sumOfTrueCost (10 * 12) 20

For the above example, the formula is:

  (120 * 1.07^20) + (120 * 1.07^19) + ... + (120 * 1.07^1)

Which, generalized, is:

  ∑ {i = 1 -> years}: yearlyPrice * rate^(years-i)

-}
sumOfTrueCost : Float -> Years -> Float
sumOfTrueCost yearlyPrice years =
  List.foldl (\y sum -> sum + yearlyPrice * (defaultRate ^ (toFloat (years - y)))) 0.0 [0..years-1]

initModel : Model
initModel = { price = 50, rate = Monthly }

----------
-- UPDATE
----------

update : Action -> Model -> Model
update action model =
  case action of
    UpdatePrice price ->
      { model | price = price }
    UpdateRate rate ->
      { model | rate = rate }

-- Takes in an input value, grabs the number out of it, and sends an UpdatePrice
-- signal to the address
sendPriceUpdate : Signal.Address Action -> String -> Signal.Message
sendPriceUpdate address str =
  -- Strip out '$' and commas with blank
  let cleanStr = Regex.replace Regex.All (Regex.regex "[$,]") (always "") str
  in
    case String.toFloat cleanStr of
      Ok num -> Signal.message address (UpdatePrice num)
      -- Errors on non-numbers (including clearing the field), so default to 0
      Err _ -> Signal.message address (UpdatePrice 0)

----------
-- VIEW
----------

{-| Split string every n, from the right-hand side.
-}
splitEveryFromRight : Int -> String -> List String
splitEveryFromRight n str =
  let numSplits = (String.length str) // n
      (rem, splits) = List.foldl
                      (\i (remaining, splits) ->
                         (String.dropLeft n remaining, String.reverse (String.left n remaining) :: splits))
                      (String.reverse str, [])
                      [0..numSplits-1]
  in
     if String.isEmpty rem then splits else (String.reverse rem) :: splits

-- Add commas
withCommas : Price -> String
withCommas price =
  let parts = String.split "." (toString price)
      rhs = Maybe.withDefault "" (List.head (List.drop 1 parts))
      lhs = Maybe.withDefault "" (List.head parts)
      lhsCommas = String.join "" (List.intersperse "," (splitEveryFromRight 3 lhs))
      final = if String.isEmpty rhs then lhsCommas else lhsCommas ++ "." ++ rhs
  in final

-- Convert a price into a displayable price. No decimal places.
displayPrice : Price -> String
displayPrice price =
  let str = withCommas (toFloat (truncate price))
  in
     "$" ++ str

rateChoiceClasses : Model -> Rate -> Attribute
rateChoiceClasses model rate =
  let selectedClass = if model.rate == rate then "selected" else ""
  in
     class ("rate-choice " ++ rateToString rate ++ " " ++ selectedClass)

-- The address (aka update function) takes an action
view : Signal.Address Action -> Model -> Html
view address model =
  div [ class "container" ]
    [ h1 [] [ text "The true cost" ]
    , div [] [ text "of your purchases" ]
    , div [ class "cost-container" ]
        -- On "input" change, send the input value to sendPriceUpdate (note how
        -- it's partially applied)
        [ text "$"
        , input [ on "input" targetValue (sendPriceUpdate address)
                , type' "text"
                , value (toString model.price)
                ]
                []
        ]
    , div [ class "rate-container" ]
        [ span [ rateChoiceClasses model Once, onClick address (UpdateRate Once) ] [ text (rateToString Once) ]
        , span [ rateChoiceClasses model Monthly, onClick address (UpdateRate Monthly) ] [ text (rateToString Monthly) ]
        , span [ rateChoiceClasses model Weekly , onClick address (UpdateRate Weekly)] [ text (rateToString Weekly)]
        ]
    , div [ class "true-cost-container" ]
        [ div [ class "true-cost-dollars" ]
              [ text (displayPrice (calculateTrueCost model 10)) ]
        , div [ class "true-cost-years" ] [ text "if invested for 10 years" ]
        ]
    , div [ class "true-cost-container" ]
        [ div [ class "true-cost-dollars" ]
              [ text (displayPrice (calculateTrueCost model 20)) ]
        , div [ class "true-cost-years" ] [ text "20 years" ]
        ]
    , div [ class "true-cost-container" ]
        [ div [ class "true-cost-dollars" ]
              [ text (displayPrice (calculateTrueCost model 30)) ]
        , div [ class "true-cost-years" ] [ text "30 years" ]
        ]
    , div [ class "footer" ]
          [ p [] [text "Assuming 7% compounded"]
          , p [] [text "Inspired by ", a [href "http://www.mrmoneymustache.com/2011/04/15/getting-started-3-eliminate-short-termitis-the-bankruptcy-disease/"] [text "MMM"] ]
          , p [] [text "Source code", a [href "http://www.mrmoneymustache.com/2011/04/15/getting-started-3-eliminate-short-termitis-the-bankruptcy-disease/"] [text "MMM"] ]
          ]
    ]

