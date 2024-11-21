module Theme = struct
  let basePadding = 3
end

module Style = struct
  (* Basic styles *)
  let base =
    [%css
      font_size (`pt 16);
      line_height 1.5;
      background_color `red;
      color (`rgb (60, 60, 60))]

  let highlighted = [%css color `blue]

  (* Pseudo-class styles *)

  let button =
    [%css
      line_height 2.;
      background_color `white;
      hover [ background_color `blue ];
      active [ background_color `darkblue ]]

  let card =
    [%css
      display `flex;
      flex_direction `column;
      align_items `stretch;
      background_color `white;
      unsafe "-webkit-overflow-scrolling" "touch";
      padding Theme.basePadding]

  let s1 =
    [%css
      width (`vw 100.);
      height (`vh 100.);
      display `flex;
      align_items `center;
      justify_content `center;
      background_color `red]
end

let () =
  ignore [ Style.base; Style.highlighted; Style.button; Style.card; Style.s1 ]
