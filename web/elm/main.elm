import Graphics.Collage exposing (Form, collage, traced, solid, segment)
import Graphics.Element exposing (Element)
import Color exposing (orange, blue, red, black)

import Time exposing (Time, fps)
import Dict exposing (Dict, get, insert)
import Debug exposing (log)

import Geometry exposing (Circle, Point)
-- type alias Circle
--   = { radius : Float
--     , omega : Float (angular speed)
--     , color : Color
--     }
--
type Pen = Up | Down
--                                                  ( key, property, value )
type SpiroGraphEvent = PenUpdate Pen | CircleUpdate (String, String, Float)

-- ---- PORTS ------------------------------------------------------------------

port circleEvents : Signal (String, String, Float)
circleChangeEvents : Signal SpiroGraphEvent
circleChangeEvents =
  Signal.map CircleUpdate circleEvents

port penEvents : Signal Float
penChangeEvents : Signal SpiroGraphEvent
penChangeEvents =
  Signal.map (\f -> if f == 1 then PenUpdate Down else PenUpdate Up) penEvents

type alias Clean = Bool
port cleanEvents : Signal Float
cleanSignal : Signal Clean
cleanSignal =
  Signal.map (\f -> if f == 1 then True else False) cleanEvents

-- -------- SPIROGRAPH STATE SIGNALS -------------------------------------------------
type alias Circles = Dict String Circle
type alias SpiroGraph = { circles : Circles, pen : Pen }

spiroGraphEvents =
  Signal.merge penChangeEvents circleChangeEvents

spiroGraphSignal =
  Signal.foldp action initSpiroGraph spiroGraphEvents

initSpiroGraph : SpiroGraph
initSpiroGraph =
  { circles = initCircles, pen = Up }
initCircles = Dict.fromList
  [ ("c1", Circle 200 0.1 orange)
  , ("c2", Circle 100 0.3 blue)
  , ("c3", Circle 50 0.8 red)
  ]

action : SpiroGraphEvent -> SpiroGraph -> SpiroGraph
action event spirograph =
  case event of
    PenUpdate x ->
      { spirograph | pen = x }
    CircleUpdate (idx, prop, value) ->
      update (idx, prop, value) spirograph

update : (String, String, Float) -> SpiroGraph -> SpiroGraph
update (idx, prop, value) state =
  let
    new_geometry =
      state.circles |> safeGet idx |> Geometry.update prop value
    new_dict =
      insert idx new_geometry state.circles
  in
    { state | circles = new_dict }

-- ---------- DRAWING AND ANIMATIONS -------------------------------------------

timeline : Signal Time
timeline =
  Signal.foldp (\t acc -> acc + t/1000) 0 (fps 24)

compositeSignal : Signal (Time, SpiroGraph, Clean)
compositeSignal =
  Signal.map3 ( \x y z -> (x, y, z) ) timeline spiroGraphSignal cleanSignal

type alias Drawing =
  { circles : List Form
  , paths : List Form
  , last_position : Point
  }

initDrawing : Drawing
initDrawing =
  { last_position = (0, 0)
  , circles = []
  , paths = []
  }

drawingSignal : Signal Drawing
drawingSignal =
  Signal.foldp draw_action initDrawing compositeSignal

draw_action : (Time, SpiroGraph, Clean) -> Drawing -> Drawing
draw_action (time, state, clean) drawing =
  let
    last_position = drawing.last_position
    (new_pos, circles) = render time state.circles
    new_paths = case state.pen of
      Up -> drawing.paths
      Down -> drawing.paths ++ (Geometry.sgmnt last_position new_pos)
    paths = if log "clean events" clean then
      []
    else
      new_paths
  in
    { drawing | circles = circles
    , last_position = new_pos
    , paths = paths
    }

-- gEventUpdate : GEvent -> Drawing -> Drawing
-- gEventUpdate e drawing = ds

main : Signal Element
main =
  Signal.map view drawingSignal

view : Drawing -> Element
view ds =
  collage 800 800 (ds.circles ++ ds.paths)

render : Time -> Circles -> (Point, List Form)
render time state =
  ((0,0), [])
  |> Geometry.rotor time (safeGet "c1" state)
  |> Geometry.rotor time (safeGet "c2" state)
  |> Geometry.rotor time (safeGet "c3" state)


-- UTILS

safeGet : String -> Circles -> Circle
safeGet idx circles =
  let
    mgeometry = get idx circles
  in
    case mgeometry of
      Just g -> g
      Nothing -> Circle 10 1 black
