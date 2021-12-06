let u = 19.05

let uu = 38.0

let halfu = 9.5

let quarteru = 4.75

let minhalfu = -9.5

let uu_border = 45.0

let bottom_bind = 33.0

let C1 = "DP5"
let C2 = "DP6"
let C3 = "DP7"
let C4 = "DP8"
let C5 = "DP9"

let DC1 = "P5"
let DC2 = "P6"
let DC3 = "P7"
let DC4 = "P8"
let DC5 = "P9"

let R1 = "P21"
let R2 = "P20"
let R3 = "P19"
let R4 = "P18"


let Key =
      { Type = { column_net : Text, bind : List Double, row_net : Text }
      , default.bind = [ 0.0, 0.0, 0.0, 0.0 ]
      }

let Anchor =
      { Type = { shift : List Double, rotate : Integer, ref : Text }
      , default =
        { shift = [ 0.0, 0.0 ]
        , rotate = Natural/toInteger 0
        , ref = "matrix_a_a"
        }
      }

let Rows =
      { Type = { a : Key.Type, b : Optional Key.Type, c : Optional Key.Type, d : Optional Key.Type }
      , default={ b = None Key.Type, c = None Key.Type, d = None Key.Type }
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
        , nets = { from = "=column_net", to = "=row_net" }
        , params = { hotswap = True, keycaps = True}
        }
      }

let mkColumn = \(column: Text)  ->
  let column = Column::{
        , rows = Rows::{
          , a = Key::{ column_net = "${column}${R1}", row_net = R1 }
          , b = Some Key::{ column_net = "${column}${R2}", row_net = R2 }
          , c = Some Key::{ column_net = "${column}${R3}", row_net = R3 }
          , d = Some Key::{ column_net = "${column}${R4}", row_net = R4 }
          }
        }
  in column

let columns =
      { a = mkColumn C1
      , b = mkColumn C2
      , c = Column::{
         rows = Rows::{
           a =  Key::{column_net = "${C3}${R1}", row_net = R1}
          , b = Some Key::{ column_net = "${C3}${R2}", row_net = R2 } 
          , c = Some Key::{ column_net = "${C3}${R3}", row_net = R3 }
          , d = Some Key::{ column_net = "${C3}${R4}", row_net = R4, bind = [ 20.0, uu, 0.0, uu ] }
        }
            }
      , d = mkColumn C4
      , e = mkColumn C5
      }
      

let points =
      { zones.matrix = { columns, key = keyconfig }
      }

let outlines =
      { exports =
        { a_pcb_keys = [ keyEdgeCut::{=}, keyEdgeCut::{ side = "right" } ]
        , b_pcb =  { a = { type = "outline", name = "a_pcb_keys"}
                   }
        , c_final_pcb = { a = { type = "outline", name = "b_pcb", fillet = 1}
                        }
        }
      }

let on_off_anchor = Anchor::{ shift = [ 0.0, 84.5 ], ref = "matrix_c_a" }
let on_off_left =
      { type = "slider"
      , anchor = on_off_anchor
      , nets = { from = "RAW", to = "BATPSWITCH" }
      } 


let battery_anchor =
      Anchor::{ rotate = Natural/toInteger 90, shift = [ 0.0, 77.0 ], ref = "matrix_c_a" }

let battery_connector_left =
      { type = "jstph"
      , anchor = battery_anchor
      , nets = { pos = "BATPSWITCH", neg = "GND" }
      }


let mcu_anchor = Anchor::{ rotate = -180, shift = [ 66.0, 77.0] }

let mcu_left = { type = "promicro", anchor = mcu_anchor, params = {orientation = "down"} }

let mcu_right =
      { type = "promicro"
      , anchor = mcu_anchor // { rotate = 0, shift = [10.0, 77.0] }
      }


let puck_anchor = Anchor::{shift = [halfu, halfu], ref = "matrix_c_b"}
let puck_left = {
  type = "puck", 
  anchor = puck_anchor
}

let puck_right = {
  type = "puck", 
  anchor = puck_anchor // {ref = "matrix_b_b"}
}


let reset_anchor = Anchor::{shift = [0.0, 13.0], ref = "matrix_c_d"}
let reset = {
  type = "reset", anchor = reset_anchor, nets = {from = "GND", to = "RST"}
}

let pcbs =
      { weirdo =
        { outlines = [ { outline = "c_final_pcb" } ]
        , footprints =
          { on_off_left
          , battery_connector_left
          , mcu_left
          , mcu_right
          , puck_left
          , puck_right
          , reset
          , daa = {type = "diode", nets = {from = "${C1}${R1}", to = DC1}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_a_a"}}
          , dab = {type = "diode", nets = {from = "${C1}${R2}", to = DC1}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_a_b"}}
          , dac = {type = "diode", nets = {from = "${C1}${R3}", to = DC1}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_a_c"}}
          , dad = {type = "diode", nets = {from = "${C1}${R4}", to = DC1}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_a_d"}}
          , dba = {type = "diode", nets = {from = "${C2}${R1}", to = DC2}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_b_a"}}
          , dbb = {type = "diode", nets = {from = "${C2}${R2}", to = DC2}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_b_b"}}
          , dbc = {type = "diode", nets = {from = "${C2}${R3}", to = DC2}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_b_c"}}
          , dbd = {type = "diode", nets = {from = "${C2}${R4}", to = DC2}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_b_d"}}
          , dca = {type = "diode", nets = {from = "${C3}${R1}", to = DC3}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_c_a"}}
          , dcb = {type = "diode", nets = {from = "${C3}${R2}", to = DC3}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_c_b"}}
          , dcc = {type = "diode", nets = {from = "${C3}${R3}", to = DC3}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_c_c"}}
          , dcd = {type = "diode", nets = {from = "${C3}${R4}", to = DC3}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_c_d"}}
          , dda = {type = "diode", nets = {from = "${C4}${R1}", to = DC4}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_d_a"}}
          , ddb = {type = "diode", nets = {from = "${C4}${R2}", to = DC4}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_d_b"}}
          , ddc = {type = "diode", nets = {from = "${C4}${R3}", to = DC4}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_d_c"}}
          , ddd = {type = "diode", nets = {from = "${C4}${R4}", to = DC4}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_d_d"}}
          , dea = {type = "diode", nets = {from = "${C5}${R1}", to = DC5}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_e_a"}}
          , deb = {type = "diode", nets = {from = "${C5}${R2}", to = DC5}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_e_b"}}
          , dec = {type = "diode", nets = {from = "${C5}${R3}", to = DC5}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_e_c"}}
          , ded = {type = "diode", nets = {from = "${C5}${R4}", to = DC5}, anchor = Anchor::{rotate = -180, shift = [0.0, 8.5], ref ="matrix_e_d"}}
          }
        }
      }

in  { outlines, points, pcbs }
