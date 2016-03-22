import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Time exposing (Time, every, millisecond, fps)
import Dict exposing (Dict, get, insert)
import Debug exposing (log)
--
-- main =
--   Signal.map2 clock (every millisecond) stateChangeEvents
--
-- clock t r =
--   collage 600 600
--     [ outlined (solid(grey)) (circle 200)
--     , hand orange t r
--     ]
--
--
-- hand clr time len =
--   let
--     angle = ( time / 1000 ) * 2 * pi
--     thin = solid clr
--     thick = { thin | width = 2 }
--
--   in
--     segment (0,0) (fromPolar (len, angle))
--       |> traced thick

port stateChangeEvents : Signal (String, String, Float)

type alias Geometry = { radius : Float, omega : Float, color : Color }
type alias State = Dict String Geometry
type alias Pos = ( Float, Float )

initState : State
initState = Dict.fromList
  [ ("c1", Geometry 200 0.1 orange)
  , ("c2", Geometry 100 0.3 blue)
  , ("c3", Geometry 50 0.8 red)
  ]

safeGet : String -> State -> Geometry
safeGet idx state =
  let
    mgeometry = get idx state
  in
    case mgeometry of
      Just g -> g
      Nothing -> Geometry 10 1 black

update_radius : Float -> Float
update_radius coeff =
  -- old * (1 + coeff/2)
  50 + (600 * coeff)

update_omega coeff = 2 * coeff

update : String -> Float -> Geometry -> Geometry
update prop value geometry =
  case prop of
    "radius" -> { geometry | radius = update_radius value }
    "omega" -> { geometry | omega = update_omega value }
    _ -> geometry

action : (String, String, Float) -> State -> State
action (idx, prop, value) state =
  let
    new_geometry =
      state |> safeGet idx |> update prop value
  in
    insert idx new_geometry state

stateSignal =
  Signal.foldp action initState stateChangeEvents

type alias DState = { drawing : List Form, last_position : Pos, paths : List Form }

sgm : Pos -> Pos -> List Form
sgm start stop =
  case start of
    (0, 0) -> []
    other -> [traced (solid black) (segment other stop)]

compositeSignal : Signal (Time, State)
compositeSignal =
  Signal.map2 (\x y -> (x, y)) (every millisecond) stateSignal

draw_action : (Time, State) -> DState -> DState
draw_action (time, state) ds =
  let
    last_position = ds.last_position
    (new_pos, form_list) = render time state
    dsgm = sgm last_position new_pos
    updated = { ds | last_position = new_pos, paths = ds.paths ++ dsgm }
  in
    { updated | drawing = form_list ++ updated.paths }

lift : State -> DState
lift state =
  { last_position = (0, 0)
  , drawing = []
  , paths = []
  }

drawingSignal : Signal DState
drawingSignal =
  Signal.foldp draw_action (lift initState) compositeSignal

main : Signal Element
main =
  Signal.map view drawingSignal

view : DState -> Element
view ds =
  collage 600 600 ds.drawing

-- main =
--   Signal.map2 view (every millisecond) stateSignal


-- view : Time -> State -> Element
-- view time state =
--   collage 900 900 (render time state)

render : Time -> State -> (Pos, List Form)
render time state =
  ((0,0), [])
  |> rotor time (safeGet "c1" state)
  |> rotor time (safeGet "c2" state)
  |> rotor time (safeGet "c3" state)

rotor : Time -> Geometry -> (Pos, List Form) -> (Pos, List Form)
rotor time geometry (center, acc) =
  let
    angle =
      2 * pi * geometry.omega * ( time / 1000 )
    thin =
      solid geometry.color
    thick =
      { thin | width = 2 }
    (deltaX, deltaY) =
      fromPolar (geometry.radius, angle)
    pos =
      ((fst center) + deltaX, (snd center) + deltaY)
    seg =
      segment center pos
    elm =
      [ move center (outlined (solid grey) (circle geometry.radius))
      , traced thick seg
      ]
    new_list =
      acc ++ elm
  in
    (pos, new_list)



--}
