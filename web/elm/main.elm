import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Time exposing (Time, fps)
import Dict exposing (Dict, get, insert)
import Debug exposing (log)

port stateEvents : Signal (String, String, Float)
stateChangeEvents : Signal Event
stateChangeEvents =
  Signal.map StateUpdate stateEvents

port penEvents : Signal Float
up_or_down : Float -> Event
up_or_down f =
  case f of
    1 -> PenUpdate Down
    _ -> PenUpdate Up
penChangeEvents : Signal Event
penChangeEvents =
  Signal.map up_or_down penEvents

type alias Clean = Bool
port cleanEvents : Signal Float
toBool f =
  case f of
    1 -> True
    _ -> False
cleanSignal : Signal Clean
cleanSignal =
  Signal.map toBool cleanEvents


type Pen = Up | Down
type alias Geometry = { radius : Float, omega : Float, color : Color }
type alias Circles = Dict String Geometry
type alias State = { circles : Circles, pen : Pen }
type alias Pos = ( Float, Float )
type Event = PenUpdate Pen | StateUpdate (String, String, Float)

circles_dict = Dict.fromList
  [ ("c1", Geometry 200 0.1 orange)
  , ("c2", Geometry 100 0.3 blue)
  , ("c3", Geometry 50 0.8 red)
  ]

safeGet : String -> Circles -> Geometry
safeGet idx state =
  let
    mgeometry = get idx state
  in
    case mgeometry of
      Just g -> g
      Nothing -> Geometry 10 1 black

update_radius : Float -> Float
update_radius coeff =
  50 + (600 * coeff)

update_omega coeff = 2 * coeff

g_update : String -> Float -> Geometry -> Geometry
g_update prop value geometry =
  case prop of
    "radius" -> { geometry | radius = update_radius value }
    "omega" -> { geometry | omega = update_omega value }
    _ -> geometry

action : Event -> State -> State
action e state =
  case e of
    PenUpdate x ->
      pen_update x state
    StateUpdate (idx, prop, value) ->
      state_update (idx, prop, value) state

pen_update x state =
  { state | pen = x }

state_update : (String, String, Float) -> State -> State
state_update (idx, prop, value) state =
  let
    new_geometry =
      state.circles |> safeGet idx |> g_update prop value
    new_dict =
      insert idx new_geometry state.circles
  in
    { state | circles = new_dict }

inputSignal =
  Signal.merge penChangeEvents stateChangeEvents

initState : State
initState =
  { circles = circles_dict, pen = Up }

stateSignal =
  Signal.foldp action initState inputSignal

sgm : Pos -> Pos -> List Form
sgm start stop =
  case start of
    (0, 0) -> []
    other -> [traced (solid black) (segment other stop)]

timeline : Signal Time
timeline =
  Signal.foldp (\t acc -> acc + t/1000) 0 (fps 24)

compositeSignal : Signal (Time, State, Clean)
compositeSignal =
  Signal.map3 (\x y z -> (x, y, z)) timeline stateSignal cleanSignal

type alias DState =
  { circles : List Form
  , paths : List Form
  , last_position : Pos
}

draw_action : (Time, State, Clean) -> DState -> DState
draw_action (time, state, clean) ds =
  let
    last_position = ds.last_position
    (new_pos, circles) = render time state.circles
    new_paths = case state.pen of
      Up -> ds.paths
      Down -> ds.paths ++ (sgm last_position new_pos)
    paths = if clean then
      []
    else
      new_paths
  in
    { ds | circles = circles
    , last_position = new_pos
    , paths = paths
    }

initDState : DState
initDState =
  { last_position = (0, 0)
  , circles = []
  , paths = []
  }

drawingSignal : Signal DState
drawingSignal =
  Signal.foldp draw_action initDState compositeSignal

-- gEventUpdate : GEvent -> DState -> DState
-- gEventUpdate e ds = ds

main : Signal Element
main =
  Signal.map view drawingSignal

view : DState -> Element
view ds =
  collage 800 800 (ds.circles ++ ds.paths)

render : Time -> Circles -> (Pos, List Form)
render time state =
  ((0,0), [])
  |> rotor time (safeGet "c1" state)
  |> rotor time (safeGet "c2" state)
  |> rotor time (safeGet "c3" state)

rotor : Time -> Geometry -> (Pos, List Form) -> (Pos, List Form)
rotor time geometry (center, acc) =
  let
    angle =
      2 * pi * geometry.omega * time
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
      group
        [ move center (outlined (solid grey) (circle geometry.radius))
        , traced thick seg
        ]
    new_list =
      elm :: acc
  in
    (pos, new_list)
