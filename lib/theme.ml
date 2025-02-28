open Prelude

type default = {
  font_family : string;
  mono_font_family : string;
  transition_duration : string;
  transition_timing_function : string;
}

module Prelude = struct
  type theme = {
    animate : string String_map.t;
    aspect : string String_map.t;
    blur : string String_map.t;
    breakpoint : string String_map.t;
    color : string String_map.t;
    size : string String_map.t;
    drop_shadow : string String_map.t;
    ease : string String_map.t;
    font : string String_map.t;
    font_weight : string String_map.t;
    inset_shadow : string String_map.t;
    leading : string String_map.t;
    perspective : string String_map.t;
    radius : string String_map.t;
    shadow : string String_map.t;
    spacing : float * string;
    text_line_height : string String_map.t;
    text_size : string String_map.t;
    tracking : string String_map.t;
  }
end

include Prelude

type t = theme

(* Consider enforcing https://drafts.csswg.org/css-values/#lengths *)
let parse_spacing input =
  let invalid_format_err =
    Invalid_argument "spacing: invalid format, expected: [0-9]+[a-zA-Z]+"
  in
  let first_non_digit =
    try
      String_ext.find_index
        (fun c ->
          match c with
          | '0' .. '9' | '.' -> false
          | _ -> true)
        input
    with Not_found -> raise invalid_format_err
  in
  let num =
    try float_of_string (String.sub input 0 first_non_digit)
    with _ -> raise invalid_format_err
  in
  let unit =
    String.sub input first_non_digit (String.length input - first_non_digit)
  in
  (num, unit)

let empty =
  {
    animate = String_map.empty;
    aspect = String_map.empty;
    blur = String_map.empty;
    breakpoint = String_map.empty;
    color =
      String_map.of_list
        [
          ("inherit", "inherit");
          ("current", "currentColor");
          ("transparent", "transparent");
        ];
    size = String_map.empty;
    drop_shadow = String_map.empty;
    ease = String_map.empty;
    font = String_map.empty;
    font_weight = String_map.empty;
    inset_shadow = String_map.empty;
    leading = String_map.empty;
    perspective = String_map.empty;
    radius = String_map.empty;
    shadow = String_map.of_list [ ("none", "0 0 #0000") ];
    spacing = (0.25, "rem");
    text_line_height = String_map.empty;
    text_size = String_map.empty;
    tracking = String_map.empty;
  }

let default =
  let font =
    [
      ( "sans",
        "ui-sans-serif, system-ui, sans-serif, 'Apple Color Emoji', 'Segoe UI \
         Emoji', 'Segoe UI Symbol', 'Noto Color Emoji'" );
      ("serif", "ui-serif, Georgia, Cambria, 'Times New Roman', Times, serif");
      ( "mono",
        "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation \
         Mono', 'Courier New', monospace" );
    ]
  in
  let color =
    [
      ("red-50", "oklch(0.971 0.013 17.38)");
      ("red-100", "oklch(0.936 0.032 17.717)");
      ("red-200", "oklch(0.885 0.062 18.334)");
      ("red-300", "oklch(0.808 0.114 19.571)");
      ("red-400", "oklch(0.704 0.191 22.216)");
      ("red-500", "oklch(0.637 0.237 25.331)");
      ("red-600", "oklch(0.577 0.245 27.325)");
      ("red-700", "oklch(0.505 0.213 27.518)");
      ("red-800", "oklch(0.444 0.177 26.899)");
      ("red-900", "oklch(0.396 0.141 25.723)");
      ("red-950", "oklch(0.258 0.092 26.042)");
      ("orange-50", "oklch(0.98 0.016 73.684)");
      ("orange-100", "oklch(0.954 0.038 75.164)");
      ("orange-200", "oklch(0.901 0.076 70.697)");
      ("orange-300", "oklch(0.837 0.128 66.29)");
      ("orange-400", "oklch(0.75 0.183 55.934)");
      ("orange-500", "oklch(0.705 0.213 47.604)");
      ("orange-600", "oklch(0.646 0.222 41.116)");
      ("orange-700", "oklch(0.553 0.195 38.402)");
      ("orange-800", "oklch(0.47 0.157 37.304)");
      ("orange-900", "oklch(0.408 0.123 38.172)");
      ("orange-950", "oklch(0.266 0.079 36.259)");
      ("amber-50", "oklch(0.987 0.022 95.277)");
      ("amber-100", "oklch(0.962 0.059 95.617)");
      ("amber-200", "oklch(0.924 0.12 95.746)");
      ("amber-300", "oklch(0.879 0.169 91.605)");
      ("amber-400", "oklch(0.828 0.189 84.429)");
      ("amber-500", "oklch(0.769 0.188 70.08)");
      ("amber-600", "oklch(0.666 0.179 58.318)");
      ("amber-700", "oklch(0.555 0.163 48.998)");
      ("amber-800", "oklch(0.473 0.137 46.201)");
      ("amber-900", "oklch(0.414 0.112 45.904)");
      ("amber-950", "oklch(0.279 0.077 45.635)");
      ("yellow-50", "oklch(0.987 0.026 102.212)");
      ("yellow-100", "oklch(0.973 0.071 103.193)");
      ("yellow-200", "oklch(0.945 0.129 101.54)");
      ("yellow-300", "oklch(0.905 0.182 98.111)");
      ("yellow-400", "oklch(0.852 0.199 91.936)");
      ("yellow-500", "oklch(0.795 0.184 86.047)");
      ("yellow-600", "oklch(0.681 0.162 75.834)");
      ("yellow-700", "oklch(0.554 0.135 66.442)");
      ("yellow-800", "oklch(0.476 0.114 61.907)");
      ("yellow-900", "oklch(0.421 0.095 57.708)");
      ("yellow-950", "oklch(0.286 0.066 53.813)");
      ("lime-50", "oklch(0.986 0.031 120.757)");
      ("lime-100", "oklch(0.967 0.067 122.328)");
      ("lime-200", "oklch(0.938 0.127 124.321)");
      ("lime-300", "oklch(0.897 0.196 126.665)");
      ("lime-400", "oklch(0.841 0.238 128.85)");
      ("lime-500", "oklch(0.768 0.233 130.85)");
      ("lime-600", "oklch(0.648 0.2 131.684)");
      ("lime-700", "oklch(0.532 0.157 131.589)");
      ("lime-800", "oklch(0.453 0.124 130.933)");
      ("lime-900", "oklch(0.405 0.101 131.063)");
      ("lime-950", "oklch(0.274 0.072 132.109)");
      ("green-50", "oklch(0.982 0.018 155.826)");
      ("green-100", "oklch(0.962 0.044 156.743)");
      ("green-200", "oklch(0.925 0.084 155.995)");
      ("green-300", "oklch(0.871 0.15 154.449)");
      ("green-400", "oklch(0.792 0.209 151.711)");
      ("green-500", "oklch(0.723 0.219 149.579)");
      ("green-600", "oklch(0.627 0.194 149.214)");
      ("green-700", "oklch(0.527 0.154 150.069)");
      ("green-800", "oklch(0.448 0.119 151.328)");
      ("green-900", "oklch(0.393 0.095 152.535)");
      ("green-950", "oklch(0.266 0.065 152.934)");
      ("emerald-50", "oklch(0.979 0.021 166.113)");
      ("emerald-100", "oklch(0.95 0.052 163.051)");
      ("emerald-200", "oklch(0.905 0.093 164.15)");
      ("emerald-300", "oklch(0.845 0.143 164.978)");
      ("emerald-400", "oklch(0.765 0.177 163.223)");
      ("emerald-500", "oklch(0.696 0.17 162.48)");
      ("emerald-600", "oklch(0.596 0.145 163.225)");
      ("emerald-700", "oklch(0.508 0.118 165.612)");
      ("emerald-800", "oklch(0.432 0.095 166.913)");
      ("emerald-900", "oklch(0.378 0.077 168.94)");
      ("emerald-950", "oklch(0.262 0.051 172.552)");
      ("teal-50", "oklch(0.984 0.014 180.72)");
      ("teal-100", "oklch(0.953 0.051 180.801)");
      ("teal-200", "oklch(0.91 0.096 180.426)");
      ("teal-300", "oklch(0.855 0.138 181.071)");
      ("teal-400", "oklch(0.777 0.152 181.912)");
      ("teal-500", "oklch(0.704 0.14 182.503)");
      ("teal-600", "oklch(0.6 0.118 184.704)");
      ("teal-700", "oklch(0.511 0.096 186.391)");
      ("teal-800", "oklch(0.437 0.078 188.216)");
      ("teal-900", "oklch(0.386 0.063 188.416)");
      ("teal-950", "oklch(0.277 0.046 192.524)");
      ("cyan-50", "oklch(0.984 0.019 200.873)");
      ("cyan-100", "oklch(0.956 0.045 203.388)");
      ("cyan-200", "oklch(0.917 0.08 205.041)");
      ("cyan-300", "oklch(0.865 0.127 207.078)");
      ("cyan-400", "oklch(0.789 0.154 211.53)");
      ("cyan-500", "oklch(0.715 0.143 215.221)");
      ("cyan-600", "oklch(0.609 0.126 221.723)");
      ("cyan-700", "oklch(0.52 0.105 223.128)");
      ("cyan-800", "oklch(0.45 0.085 224.283)");
      ("cyan-900", "oklch(0.398 0.07 227.392)");
      ("cyan-950", "oklch(0.302 0.056 229.695)");
      ("sky-50", "oklch(0.977 0.013 236.62)");
      ("sky-100", "oklch(0.951 0.026 236.824)");
      ("sky-200", "oklch(0.901 0.058 230.902)");
      ("sky-300", "oklch(0.828 0.111 230.318)");
      ("sky-400", "oklch(0.746 0.16 232.661)");
      ("sky-500", "oklch(0.685 0.169 237.323)");
      ("sky-600", "oklch(0.588 0.158 241.966)");
      ("sky-700", "oklch(0.5 0.134 242.749)");
      ("sky-800", "oklch(0.443 0.11 240.79)");
      ("sky-900", "oklch(0.391 0.09 240.876)");
      ("sky-950", "oklch(0.293 0.066 243.157)");
      ("blue-50", "oklch(0.97 0.014 254.604)");
      ("blue-100", "oklch(0.932 0.032 255.585)");
      ("blue-200", "oklch(0.882 0.059 254.128)");
      ("blue-300", "oklch(0.809 0.105 251.813)");
      ("blue-400", "oklch(0.707 0.165 254.624)");
      ("blue-500", "oklch(0.623 0.214 259.815)");
      ("blue-600", "oklch(0.546 0.245 262.881)");
      ("blue-700", "oklch(0.488 0.243 264.376)");
      ("blue-800", "oklch(0.424 0.199 265.638)");
      ("blue-900", "oklch(0.379 0.146 265.522)");
      ("blue-950", "oklch(0.282 0.091 267.935)");
      ("indigo-50", "oklch(0.962 0.018 272.314)");
      ("indigo-100", "oklch(0.93 0.034 272.788)");
      ("indigo-200", "oklch(0.87 0.065 274.039)");
      ("indigo-300", "oklch(0.785 0.115 274.713)");
      ("indigo-400", "oklch(0.673 0.182 276.935)");
      ("indigo-500", "oklch(0.585 0.233 277.117)");
      ("indigo-600", "oklch(0.511 0.262 276.966)");
      ("indigo-700", "oklch(0.457 0.24 277.023)");
      ("indigo-800", "oklch(0.398 0.195 277.366)");
      ("indigo-900", "oklch(0.359 0.144 278.697)");
      ("indigo-950", "oklch(0.257 0.09 281.288)");
      ("violet-50", "oklch(0.969 0.016 293.756)");
      ("violet-100", "oklch(0.943 0.029 294.588)");
      ("violet-200", "oklch(0.894 0.057 293.283)");
      ("violet-300", "oklch(0.811 0.111 293.571)");
      ("violet-400", "oklch(0.702 0.183 293.541)");
      ("violet-500", "oklch(0.606 0.25 292.717)");
      ("violet-600", "oklch(0.541 0.281 293.009)");
      ("violet-700", "oklch(0.491 0.27 292.581)");
      ("violet-800", "oklch(0.432 0.232 292.759)");
      ("violet-900", "oklch(0.38 0.189 293.745)");
      ("violet-950", "oklch(0.283 0.141 291.089)");
      ("purple-50", "oklch(0.977 0.014 308.299)");
      ("purple-100", "oklch(0.946 0.033 307.174)");
      ("purple-200", "oklch(0.902 0.063 306.703)");
      ("purple-300", "oklch(0.827 0.119 306.383)");
      ("purple-400", "oklch(0.714 0.203 305.504)");
      ("purple-500", "oklch(0.627 0.265 303.9)");
      ("purple-600", "oklch(0.558 0.288 302.321)");
      ("purple-700", "oklch(0.496 0.265 301.924)");
      ("purple-800", "oklch(0.438 0.218 303.724)");
      ("purple-900", "oklch(0.381 0.176 304.987)");
      ("purple-950", "oklch(0.291 0.149 302.717)");
      ("fuchsia-50", "oklch(0.977 0.017 320.058)");
      ("fuchsia-100", "oklch(0.952 0.037 318.852)");
      ("fuchsia-200", "oklch(0.903 0.076 319.62)");
      ("fuchsia-300", "oklch(0.833 0.145 321.434)");
      ("fuchsia-400", "oklch(0.74 0.238 322.16)");
      ("fuchsia-500", "oklch(0.667 0.295 322.15)");
      ("fuchsia-600", "oklch(0.591 0.293 322.896)");
      ("fuchsia-700", "oklch(0.518 0.253 323.949)");
      ("fuchsia-800", "oklch(0.452 0.211 324.591)");
      ("fuchsia-900", "oklch(0.401 0.17 325.612)");
      ("fuchsia-950", "oklch(0.293 0.136 325.661)");
      ("pink-50", "oklch(0.971 0.014 343.198)");
      ("pink-100", "oklch(0.948 0.028 342.258)");
      ("pink-200", "oklch(0.899 0.061 343.231)");
      ("pink-300", "oklch(0.823 0.12 346.018)");
      ("pink-400", "oklch(0.718 0.202 349.761)");
      ("pink-500", "oklch(0.656 0.241 354.308)");
      ("pink-600", "oklch(0.592 0.249 0.584)");
      ("pink-700", "oklch(0.525 0.223 3.958)");
      ("pink-800", "oklch(0.459 0.187 3.815)");
      ("pink-900", "oklch(0.408 0.153 2.432)");
      ("pink-950", "oklch(0.284 0.109 3.907)");
      ("rose-50", "oklch(0.969 0.015 12.422)");
      ("rose-100", "oklch(0.941 0.03 12.58)");
      ("rose-200", "oklch(0.892 0.058 10.001)");
      ("rose-300", "oklch(0.81 0.117 11.638)");
      ("rose-400", "oklch(0.712 0.194 13.428)");
      ("rose-500", "oklch(0.645 0.246 16.439)");
      ("rose-600", "oklch(0.586 0.253 17.585)");
      ("rose-700", "oklch(0.514 0.222 16.935)");
      ("rose-800", "oklch(0.455 0.188 13.697)");
      ("rose-900", "oklch(0.41 0.159 10.272)");
      ("rose-950", "oklch(0.271 0.105 12.094)");
      ("slate-50", "oklch(0.984 0.003 247.858)");
      ("slate-100", "oklch(0.968 0.007 247.896)");
      ("slate-200", "oklch(0.929 0.013 255.508)");
      ("slate-300", "oklch(0.869 0.022 252.894)");
      ("slate-400", "oklch(0.704 0.04 256.788)");
      ("slate-500", "oklch(0.554 0.046 257.417)");
      ("slate-600", "oklch(0.446 0.043 257.281)");
      ("slate-700", "oklch(0.372 0.044 257.287)");
      ("slate-800", "oklch(0.279 0.041 260.031)");
      ("slate-900", "oklch(0.208 0.042 265.755)");
      ("slate-950", "oklch(0.129 0.042 264.695)");
      ("gray-50", "oklch(0.985 0.002 247.839)");
      ("gray-100", "oklch(0.967 0.003 264.542)");
      ("gray-200", "oklch(0.928 0.006 264.531)");
      ("gray-300", "oklch(0.872 0.01 258.338)");
      ("gray-400", "oklch(0.707 0.022 261.325)");
      ("gray-500", "oklch(0.551 0.027 264.364)");
      ("gray-600", "oklch(0.446 0.03 256.802)");
      ("gray-700", "oklch(0.373 0.034 259.733)");
      ("gray-800", "oklch(0.278 0.033 256.848)");
      ("gray-900", "oklch(0.21 0.034 264.665)");
      ("gray-950", "oklch(0.13 0.028 261.692)");
      ("zinc-50", "oklch(0.985 0 0)");
      ("zinc-100", "oklch(0.967 0.001 286.375)");
      ("zinc-200", "oklch(0.92 0.004 286.32)");
      ("zinc-300", "oklch(0.871 0.006 286.286)");
      ("zinc-400", "oklch(0.705 0.015 286.067)");
      ("zinc-500", "oklch(0.552 0.016 285.938)");
      ("zinc-600", "oklch(0.442 0.017 285.786)");
      ("zinc-700", "oklch(0.37 0.013 285.805)");
      ("zinc-800", "oklch(0.274 0.006 286.033)");
      ("zinc-900", "oklch(0.21 0.006 285.885)");
      ("zinc-950", "oklch(0.141 0.005 285.823)");
      ("neutral-50", "oklch(0.985 0 0)");
      ("neutral-100", "oklch(0.97 0 0)");
      ("neutral-200", "oklch(0.922 0 0)");
      ("neutral-300", "oklch(0.87 0 0)");
      ("neutral-400", "oklch(0.708 0 0)");
      ("neutral-500", "oklch(0.556 0 0)");
      ("neutral-600", "oklch(0.439 0 0)");
      ("neutral-700", "oklch(0.371 0 0)");
      ("neutral-800", "oklch(0.269 0 0)");
      ("neutral-900", "oklch(0.205 0 0)");
      ("neutral-950", "oklch(0.145 0 0)");
      ("stone-50", "oklch(0.985 0.001 106.423)");
      ("stone-100", "oklch(0.97 0.001 106.424)");
      ("stone-200", "oklch(0.923 0.003 48.717)");
      ("stone-300", "oklch(0.869 0.005 56.366)");
      ("stone-400", "oklch(0.709 0.01 56.259)");
      ("stone-500", "oklch(0.553 0.013 58.071)");
      ("stone-600", "oklch(0.444 0.011 73.639)");
      ("stone-700", "oklch(0.374 0.01 67.558)");
      ("stone-800", "oklch(0.268 0.007 34.298)");
      ("stone-900", "oklch(0.216 0.006 56.043)");
      ("stone-950", "oklch(0.147 0.004 49.25)");
      ("black", "#000");
      ("white", "#fff");
    ]
  in
  let breakpoint =
    [
      ("sm", "40rem");
      ("md", "48rem");
      ("lg", "64rem");
      ("xl", "80rem");
      ("2xl", "96rem");
    ]
  in
  let size =
    [
      ("3xs", "16rem");
      ("2xs", "18rem");
      ("xs", "20rem");
      ("sm", "24rem");
      ("md", "28rem");
      ("lg", "32rem");
      ("xl", "36rem");
      ("2xl", "42rem");
      ("3xl", "48rem");
      ("4xl", "56rem");
      ("5xl", "64rem");
      ("6xl", "72rem");
      ("7xl", "80rem");
    ]
  in
  let text_size =
    [
      ("xs", "0.75rem");
      ("sm", "0.875rem");
      ("base", "1rem");
      ("lg", "1.125rem");
      ("xl", "1.25rem");
      ("2xl", "1.5rem");
      ("3xl", "1.875rem");
      ("4xl", "2.25rem");
      ("5xl", "3rem");
      ("6xl", "3.75rem");
      ("7xl", "4.5rem");
      ("8xl", "6rem");
      ("9xl", "8rem");
    ]
  in
  let text_line_height =
    [
      ("xs", "calc(1 / 0.75)");
      ("sm", "calc(1.25 / 0.875)");
      ("base", "calc(1.5 / 1)");
      ("lg", "calc(1.75 / 1.125)");
      ("xl", "calc(1.75 / 1.25)");
      ("2xl", "calc(2 / 1.5)");
      ("3xl", "calc(2.25 / 1.875)");
      ("4xl", "calc(2.5 / 2.25)");
      ("5xl", "1");
      ("6xl", "1");
      ("7xl", "1");
      ("8xl", "1");
      ("9xl", "1");
    ]
  in
  let font_weight =
    [
      ("thin", "100");
      ("extralight", "200");
      ("light", "300");
      ("normal", "400");
      ("medium", "500");
      ("semibold", "600");
      ("bold", "700");
      ("extrabold", "800");
      ("black", "900");
    ]
  in
  let tracking =
    [
      ("tighter", "-0.05em");
      ("tight", "-0.025em");
      ("normal", "0em");
      ("wide", "0.025em");
      ("wider", "0.05em");
      ("widest", "0.1em");
    ]
  in
  let leading =
    [
      ("tight", "1.25");
      ("snug", "1.375");
      ("normal", "1.5");
      ("relaxed", "1.625");
      ("loose", "2");
    ]
  in
  let radius =
    [
      ("xs", "0.125rem");
      ("sm", "0.25rem");
      ("md", "0.375rem");
      ("lg", "0.5rem");
      ("xl", "0.75rem");
      ("2xl", "1rem");
      ("3xl", "1.5rem");
      ("4xl", "2rem");
    ]
  in
  let shadow =
    [
      ("2xs", "0 1px var(--sx-shadow-color, rgb(0 0 0 / 0.05))");
      ("xs", "0 1px 2px 0 var(--sx-shadow-color, rgb(0 0 0 / 0.05))");
      ( "",
        "0 1px 3px 0 var(--sx-shadow-color, rgb(0 0 0 / 0.1)), 0 1px 2px -1px \
         var(--sx-shadow-color, rgb(0 0 0 / 0.1))" );
      ( "sm",
        "0 1px 3px 0 var(--sx-shadow-color, rgb(0 0 0 / 0.1)), 0 1px 2px -1px \
         var(--sx-shadow-color, rgb(0 0 0 / 0.1))" );
      ( "md",
        "0 4px 6px -1px var(--sx-shadow-color, rgb(0 0 0 / 0.1)), 0 2px 4px \
         -2px var(--sx-shadow-color, rgb(0 0 0 / 0.1))" );
      ( "lg",
        "0 10px 15px -3px var(--sx-shadow-color, rgb(0 0 0 / 0.1)), 0 4px 6px \
         -4px var(--sx-shadow-color, rgb(0 0 0 / 0.1))" );
      ( "xl",
        "0 20px 25px -5px var(--sx-shadow-color, rgb(0 0 0 / 0.1)), 0 8px 10px \
         -6px var(--sx-shadow-color, rgb(0 0 0 / 0.1))" );
      ("2xl", "0 25px 50px -12px var(--sx-shadow-color, rgb(0 0 0 / 0.25))");
    ]
  in
  let inset_shadow =
    [
      ("2xs", "inset 0 1px var(--sx-shadow-color, rgb(0 0 0 / 0.05))");
      ("xs", "inset 0 1px 1px var(--sx-shadow-color, rgb(0 0 0 / 0.05))");
      ("sm", "inset 0 2px 4px var(--sx-shadow-color, rgb(0 0 0 / 0.05))");
    ]
  in
  let drop_shadow =
    [
      ("xs", "0 1px 1px var(--sx-shadow-color, rgb(0 0 0 / 0.05))");
      ("sm", "0 1px 2px var(--sx-shadow-color, rgb(0 0 0 / 0.15))");
      ("md", "0 3px 3px var(--sx-shadow-color, rgb(0 0 0 / 0.12))");
      ("lg", "0 4px 4px var(--sx-shadow-color, rgb(0 0 0 / 0.15))");
      ("xl", "0 9px 7px var(--sx-shadow-color, rgb(0 0 0 / 0.1))");
      ("2xl", "0 25px 25px var(--sx-shadow-color, rgb(0 0 0 / 0.15))");
    ]
  in
  let ease =
    [
      ("in", "cubic-bezier(0.4, 0, 1, 1)");
      ("out", "cubic-bezier(0, 0, 0.2, 1)");
      ("in-out", "cubic-bezier(0.4, 0, 0.2, 1)");
    ]
  in
  let animate =
    [
      ("spin", "spin 1s linear infinite");
      ("ping", "ping 1s cubic-bezier(0, 0, 0.2, 1) infinite");
      ("pulse", "pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite");
      ("bounce", "bounce 1s infinite");
    ]
  in
  let blur =
    [
      ("xs", "4px");
      ("sm", "8px");
      ("md", "12px");
      ("lg", "16px");
      ("xl", "24px");
      ("2xl", "40px");
      ("3xl", "64px");
    ]
  in
  let perspective =
    [
      ("dramatic", "100px");
      ("near", "300px");
      ("normal", "500px");
      ("midrange", "800px");
      ("distant", "1200px");
    ]
  in
  let aspect = [ ("video", "16 / 9") ] in

  {
    animate = String_map.of_list animate;
    aspect = String_map.of_list aspect;
    blur = String_map.of_list blur;
    breakpoint = String_map.of_list breakpoint;
    color = String_map.add_seq (List.to_seq color) empty.color;
    size = String_map.of_list size;
    drop_shadow = String_map.of_list drop_shadow;
    ease = String_map.of_list ease;
    font = String_map.of_list font;
    font_weight = String_map.of_list font_weight;
    inset_shadow = String_map.of_list inset_shadow;
    leading = String_map.of_list leading;
    perspective = String_map.of_list perspective;
    radius = String_map.of_list radius;
    shadow = String_map.add_seq (List.to_seq shadow) empty.shadow;
    spacing = empty.spacing;
    text_line_height = String_map.of_list text_line_height;
    text_size = String_map.of_list text_size;
    tracking = String_map.of_list tracking;
  }

open struct
  let add opt_name acc0 (json : Yojson.Basic.t) =
    match json with
    | `Assoc items ->
      List.fold_left
        (fun acc (key, item) ->
          match item with
          | `String value -> String_map.add key value acc
          | _ ->
            invalid_arg
              (String.concat ""
                 [ "option value must be a string: "; opt_name; "."; key ]))
        acc0 items
    | _ ->
      raise (Invalid_argument ("option values must be an object: " ^ opt_name))
end

let of_yojson (json : Yojson.Basic.t) =
  match json with
  | `Assoc items -> (
    try
      List.fold_left
        (fun acc (k, v) ->
          match k with
          | "animate" -> { acc with animate = add k acc.animate v }
          | "aspect" -> { acc with aspect = add k acc.aspect v }
          | "blur" -> { acc with blur = add k acc.blur v }
          | "breakpoint" -> { acc with breakpoint = add k acc.breakpoint v }
          | "color" -> { acc with color = add k acc.color v }
          | "size" -> { acc with size = add k acc.size v }
          | "drop-shadow" -> { acc with drop_shadow = add k acc.drop_shadow v }
          | "ease" -> { acc with ease = add k acc.ease v }
          | "font" -> { acc with font = add k acc.font v }
          | "font-weight" -> { acc with font_weight = add k acc.font_weight v }
          | "inset-shadow" ->
            { acc with inset_shadow = add k acc.inset_shadow v }
          | "leading" -> { acc with leading = add k acc.leading v }
          | "perspective" -> { acc with perspective = add k acc.perspective v }
          | "radius" -> { acc with radius = add k acc.radius v }
          | "shadow" -> { acc with shadow = add k acc.shadow v }
          | "spacing" ->
            { acc with spacing = parse_spacing (Yojson.Basic.Util.to_string v) }
          | "text-line-height" ->
            { acc with text_line_height = add k acc.text_line_height v }
          | "text-size" -> { acc with text_size = add k acc.text_size v }
          | "tracking" -> { acc with tracking = add k acc.tracking v }
          | _ -> raise (Invalid_argument ("invalid theme option: " ^ k)))
        empty items
      |> Result.ok
    with exn -> Error exn)
  | _ -> Error (Invalid_argument "config must be a JSON object")
