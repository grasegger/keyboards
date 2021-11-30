let u = 19.05

let uu = 38.0

let halfu = 9.5

let quarteru = 4.75

let minhalfu = -9.5

let uu_border = 45.0

let bottom_bind = 33.0

let mirror_ref = "mirror_matrix_a_home"

let Key =
      { Type = { column_net : Text, bind : List Double }
      , default.bind = [ 0.0, 0.0, 0.0, 0.0 ]
      }

let Anchor =
      { Type = { shift : List Double, rotate : Integer, ref : Text }
      , default =
        { shift = [ 0.0, 0.0 ]
        , rotate = Natural/toInteger 0
        , ref = "matrix_a_home"
        }
      }

let Rows =
      { Type = { home : Key.Type, top : Optional Key.Type }
      , default.top = None Key.Type
      }

let Column =
      { Type =
          { rows : Rows.Type
          , stagger : Double
          , spread : Double
          , rotate : Natural
          }
      , default = { rotate = 0, spread = 0.0, stagger = 0.0 }
      }

let Rectangle = {
  Type = {
    type: Text,
    operation: Text
    , size: List Double
    , anchor: Anchor.Type
  }, default = {
    anchor = Anchor::{=}, type = "rectangle", operation = "subtract"
  }
}

let Circle = {
  Type = {
    type: Text,
    operation: Text
    , radius: Double
    , anchor: Anchor.Type
  }, default = {
    anchor = Anchor::{=}, type = "circle", operation = "subtract"
  }
}


let keyEdgeCut =
      { Type = { type : Text, size : List Double, side : Text, bound : Bool, operation: Text }
      , default =
        { type = "keys", size = [ u, u ], side = "left", bound = True, operation = "add" }
      }

let keyconfig =
      { footprints.mx
        =
        { type = "mx"
        , nets = { from = "=column_net", to = "GND" }
        , params = { hotswap = True, keycaps = True}
        }
      }

let mkColumn = \(net_one: Text) -> \(net_two: Text) -> \(stagger: Double) ->
  let column = Column::{
        stagger = stagger
        , rows = Rows::{
          , home = Key::{ column_net = net_one }
          , top = Some Key::{ column_net = net_two }
          }
        }
  in column

let columns =
      { a = mkColumn "P10" "RST" 0.0
      , b = mkColumn "P14" "P21" halfu
      , c = Column::{
        , stagger = quarteru
        , rows = Rows::{
          , home = Key::{ column_net = "P15", bind = [ 14.5, uu, bottom_bind, uu ] }
          , top = Some Key::{
            , column_net = "P1"
            }
          }
        }
      , d = mkColumn "P16" "P0" -8.0
      , e = Column::{
        , stagger = -30.0
        , rotate = 330
        , spread = 24.5
        , rows = Rows::{
          , home = Key::{ column_net = "P9", bind = [ 2.2, 2.2 ] }
          }
        }
      }

let points =
      { zones.matrix = { columns, key = keyconfig }
      , mirror = { ref = "matrix_e_home", distance = 40 }
      }

let outlines =
      { exports =
        { a_pcb_keys = [ keyEdgeCut::{=}, keyEdgeCut::{ side = "right" } ]
        , b_pcb =  { a = { type = "outline", name = "a_pcb_keys"}
                   , b = Rectangle::{size = [32.0, 5.0], anchor = Anchor::{shift=[85.5, 30.0]}, operation = "add"}
                   }
        , c_final_pcb = { a = { type = "outline", name = "b_pcb", fillet = 1}
                        , b = Circle::{radius = 1.55, anchor = Anchor::{shift = [-6.5, 34.5]}}
                        , c = Circle::{radius = 1.55, anchor = Anchor::{shift = [-6.5, -25.5]}}
                        , f = Circle::{radius = 1.55, anchor = Anchor::{shift = [71.0, -15.5]}}
                        , h = Circle::{radius = 1.05, anchor = Anchor::{shift = [-1.5, 34.5]}}
                        , i = Circle::{radius = 1.05, anchor = Anchor::{shift = [-1.5, -25.5]}}
                        , j = Circle::{radius = 1.05, anchor = Anchor::{shift = [55.0, -17.0]}}
                        , n = Circle::{radius = 1.05, anchor = Anchor::{shift = [47.5, 21.5]}}
                        , d = Circle::{radius = 1.55, anchor = Anchor::{shift = [-6.5, -25.5], ref = mirror_ref}}
                        , e = Circle::{radius = 1.55, anchor = Anchor::{shift = [-6.5, 34.5], ref = mirror_ref}}
                        , k = Circle::{radius = 1.05, anchor = Anchor::{shift = [-1.5, 34.5], ref = mirror_ref}}
                        , l = Circle::{radius = 1.05, anchor = Anchor::{shift = [-1.5, -25.5], ref = mirror_ref}}
                        , m = Circle::{radius = 1.05, anchor = Anchor::{shift = [55.0, -17.0], ref = mirror_ref}}
                        , g = Circle::{radius = 1.55, anchor = Anchor::{shift = [71.0, -15.5], ref = mirror_ref}}
                        , o = Circle::{radius = 1.05, anchor = Anchor::{shift = [47.5, 21.5], ref = mirror_ref}}
                        }
          , d_shield_base = { a = { type = "outline", name = "b_pcb", fillet = 1}
                            , ba = Rectangle::{size = [31.95, 7.0], anchor = Anchor::{shift=[85.525, 29.0]}}
                            , b = keyEdgeCut::{size = [14.0,14.0], operation = "subtract", bound = False}
                            , c =Circle::{radius = 21.1, anchor = Anchor::{shift = [23.0, 10.0], rotate = Natural/toInteger 45, ref = mirror_ref }}
                            , d = Circle::{radius = 1.05, anchor = Anchor::{shift = [-6.5, 34.5]}}
                            , e = Circle::{radius = 1.05, anchor = Anchor::{shift = [-6.5, -25.5]}}
                            , f = Circle::{radius = 1.05, anchor = Anchor::{shift = [71.0, -15.5]}}
                            , g = Circle::{radius = 1.05, anchor = Anchor::{shift = [-6.5, -25.5], ref = mirror_ref}}
                            , h = Circle::{radius = 1.05, anchor = Anchor::{shift = [-6.5, 34.5], ref = mirror_ref}}
                            , i = Circle::{radius = 1.05, anchor = Anchor::{shift = [-1.5, 34.5], ref = mirror_ref}}
                            , j = Circle::{radius = 1.05, anchor = Anchor::{shift = [-1.5, -25.5], ref = mirror_ref}}
                            , k = Circle::{radius = 1.05, anchor = Anchor::{shift = [55.0, -17.0], ref = mirror_ref}}
                            , l = Circle::{radius = 1.05, anchor = Anchor::{shift = [71.0, -15.5], ref = mirror_ref}}
                            , m = Circle::{radius = 1.05, anchor = Anchor::{shift = [47.5, 21.5], ref = mirror_ref}}
                            , o = Rectangle::{size = [14.0,12.0], anchor = Anchor::{shift =  [ 68.5, -9.3 ]}}
                            , p = Rectangle::{size = [15.0,3.0], anchor = Anchor::{shift =  [ 47.5, -8.0 ]}}
                            , q = Circle::{radius = 1.55, anchor = Anchor::{shift = [45.0, -13.0]}}
                            , r = Circle::{radius = 1.55, anchor = Anchor::{shift = [65.0, -24.0]}}
                            , s = Circle::{radius = 1.55, anchor = Anchor::{shift = [45.0, -24.0]}}
                            , t = Circle::{radius = 1.55, anchor = Anchor::{shift = [65.0, -13.0]}}
                            }
        }
      }

let on_off_anchor = Anchor::{ shift = [ 57.25, 36.2 ] }
let on_off_left =
      { type = "slider"
      , anchor = on_off_anchor
      , nets = { from = "RAW", to = "BATPSWITCH" }
      } 

let on_off_right =
      { type = "slider"
      , anchor = on_off_anchor // {ref = mirror_ref}
      , nets = { from = "MIRROR_RAW", to = "MIRROR_BATPSWITCH" }
      }

let battery_anchor =
      Anchor::{ rotate = Natural/toInteger 90, shift = [ 0.0, -14.0 ] }

let battery_connector_left =
      { type = "jstph"
      , anchor = battery_anchor
      , nets = { pos = "BATPSWITCH", neg = "GND" }
      }

let battery_connector_right =
          battery_connector_left
      //  { anchor = battery_anchor // { ref = mirror_ref }
          , nets = { pos = "MIRROR_BATPSWITCH", neg = "MIRROR_GND" }
          }

let mcu_anchor = Anchor::{ rotate = -90, shift = [ 75.75, 19.0] }

let mcu_left = { type = "promicro", anchor = mcu_anchor, params = {orientation = "up"} }

let mcu_right =
      { type = "promicro"
      , anchor = mcu_anchor // { ref = mirror_ref }
      , params.mirror = True
      }

let encoder_anchor = Anchor::{ rotate = -180, shift = [ 75.0, -3.3 ] }

let encoder_left =
      { type = "rotary"
      , anchor = encoder_anchor
      , nets = { from = "P7", to = "GND", A = "P6", B = "P5", C = "GND" }
      }

let encoder_right =
          encoder_left
      //  { anchor = encoder_anchor // { ref = mirror_ref }
          , nets =
            { from = "MIRROR_P7"
            , to = "MIRROR_GND"
            , A = "MIRROR_P6"
            , B = "MIRROR_P5"
            , C = "MIRROR_GND"
            }
          }

let trackball_anchor = Anchor::{shift = [55.0, -16.0], rotate = -90}

let trackball_left =
      { type = "pimoroni477"
      , anchor = trackball_anchor
      , nets =
        { GND = "GND", VCC = "VCC", SDA = "P2", SCL = "P3", INT = "P4" }
      }

let trackball_right =
          trackball_left
      //  { anchor = trackball_anchor // { ref = mirror_ref }
          , nets =
            { GND = "MIRROR_GND"
            , VCC = "MIRROR_VCC"
            , SDA = "MIRROR_P2"
            , SCL = "MIRROR_P3"
            , INT = "MIRROR_P4"
            }
          }

let puck_anchor = Anchor::{shift = [23.0, 10.0], rotate = Natural/toInteger 45}
let puck_left = {
  type = "puck", 
  anchor = puck_anchor
}

let puck_right = puck_left // {
  anchor = puck_anchor  // { ref = mirror_ref }
}

let pcbs =
      { lasagna =
        { outlines = [ { outline = "c_final_pcb" } ]
        , footprints =
          { on_off_left
          , on_off_right
          , battery_connector_left
          , battery_connector_right
          , mcu_left
          , mcu_right
          , encoder_left
          , encoder_right
          , trackball_left
          , trackball_right
          , puck_left
          , puck_right
          }
        }
      , lasagna_shield = {outlines = [{outline = "d_shield_base"}]}
      }

in  { outlines, points, pcbs }
