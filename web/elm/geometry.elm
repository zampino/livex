module Geometry (Circle, Point, update, sgmnt, rotor) where

import Time exposing (Time)
import Color exposing (Color, grey, black)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)

type alias Point = (Float, Float)
type alias Circle
  = { radius : Float
    , omega : Float
    , color : Color
    }

update_radius : Float -> Float
update_radius coeff =
  50 + (600 * coeff)

update_omega coeff = 2 * coeff

update : String -> Float -> Circle -> Circle
update prop value c =
  case prop of
    "radius" -> { c | radius = update_radius value }
    "omega" -> { c | omega = update_omega value }
    _ -> c

rotor : Time -> Circle -> (Point, List Form) -> (Point, List Form)
rotor time crcl (center, acc) =
  let
    angle =
      2 * pi * crcl.omega * time
    thin =
      solid crcl.color
    thick =
      { thin | width = 2 }
    (deltaX, deltaY) =
      fromPolar (crcl.radius, angle)
    pos =
      ((fst center) + deltaX, (snd center) + deltaY)
    seg =
      segment center pos
    elm =
      group
        [ move center (outlined (solid grey) (circle crcl.radius))
        , traced thick seg
        ]
    new_list =
      elm :: acc
  in
    (pos, new_list)

sgmnt : Point -> Point -> List Form
sgmnt start stop =
  case start of
    (0, 0) -> []
    other -> [traced (solid black) (segment other stop)]
