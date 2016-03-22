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


main =
  Signal.map2 view (every millisecond) stateSignal


-- type DrawState
-- draw_action : Time -> DrawState -> DrawState
-- draw_action t ds =
--
--   -- ...
--   let
--     (pos, _, elem) =
--       render time state
--     trace =
--       traced dotted black segment ds.last_position pos
--     updated = { ds | last_position = pos }
--   in
--     { updated | drawing = }

{--
view time ds =
  collage 600 600 (render time ds)

--}


view : Time -> State -> Element
view time state =
  collage 900 900 (render time state)

third (a, b, c) = c

render : Time -> State -> List Form
render time state =
  let
    comp =
      (time, (0,0), [])
      |> rotor (safeGet "c1" state)
      |> rotor (safeGet "c2" state)
      |> rotor (safeGet "c3" state)
  in
    third comp

rotor : Geometry -> (Time, Pos, List Form) -> (Time, Pos, List Form)
rotor geometry (time, center, acc) =
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
    (time, pos, new_list)



--}
