[@@@css []]

module Theme = struct
  let basePadding = 3
end

module Style = struct
  let base =
    let open Sx in
    ignore
      [
        font_size (`pt 16);
        line_height 1.5;
        background_color `red;
        color (`rgb (60, 60, 60));
      ];
    "TODO"

  let highlighted =
    let open Sx in
    ignore [ color `blue ];
    "TODO"

  let button =
    let open Sx in
    ignore
      [
        line_height 2.;
        background_color `white;
        hover [ background_color `blue ];
        active [ background_color `darkblue ];
      ];
    "TODO"

  let card =
    let open Sx in
    ignore
      [
        display `flex;
        flex_direction `column;
        align_items `stretch;
        background_color `white;
        unsafe "-webkit-overflow-scrolling" "touch";
        padding Theme.basePadding;
      ];
    "TODO"

  let s1 =
    let open Sx in
    ignore
      [
        width (`vw 100.);
        height (`vh 100.);
        display `flex;
        align_items `center;
        justify_content `center;
        background_color `red;
      ];
    "TODO"
end

let () =
  ignore [ Style.base; Style.highlighted; Style.button; Style.card; Style.s1 ]
