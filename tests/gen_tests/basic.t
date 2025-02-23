  $ sx <<< 'flex'
  .flex { display: flex; }

  $ sx <<< 'm-0'
  .m-0 { margin: 0px; }

  $ sx <<< 'm-px'
  .m-px { margin: 1px; }

  $ sx <<< 'm-1'
  .m-1 { margin: 0.25rem; }

  $ sx <<< 'm-20'
  .m-20 { margin: 5rem; }

  $ sx <<< 'my-0'
  .my-0 { margin-top: 0px;margin-bottom: 0px; }

  $ sx <<< 'mx-px'
  .mx-px { margin-left: 1px;margin-right: 1px; }

  $ sx <<< 'me-1'
  .me-1 { margin-inline-end: 0.25rem; }

  $ sx <<< 'mb-20'
  .mb-20 { margin-bottom: 5rem; }

  $ sx <<< 'my-0'
  .my-0 { margin-top: 0px;margin-bottom: 0px; }

  $ sx <<< 'mx-px'
  .mx-px { margin-left: 1px;margin-right: 1px; }

  $ sx <<< '-m-4'
  .-m-4 { margin: -1rem; }

  $ sx <<< '-mx-1'
  .-mx-1 { margin-left: -0.25rem;margin-right: -0.25rem; }

  $ sx <<< 'mt-auto'
  .mt-auto { margin-top: auto; }

  $ sx <<< 'p-0'
  .p-0 { padding: 0px; }

  $ sx <<< 'ps-2'
  .ps-2 { padding-inline-start: 0.5rem; }

  $ sx <<< 'py-80'
  .py-80 { padding-top: 20rem;padding-bottom: 20rem; }

  $ sx <<< 'aspect-square'
  .aspect-square { aspect-ratio:1 / 1; }

  $ sx <<< 'columns-5'
  .columns-5 { columns: 5; }

  $ sx <<< 'columns-10'
  .columns-10 { columns: 10; }

  $ sx <<< 'columns-auto'
  .columns-auto { columns: auto; }

  $ sx <<< 'columns-xs'
  .columns-xs { columns: 20rem; }

  $ sx <<< 'columns-3xs'
  .columns-3xs { columns: 16rem; }

  $ sx <<< 'break-before-all'
  .break-before-all { break-before: all; }

  $ sx <<< 'break-inside-avoid'
  .break-inside-avoid { break-before: avoid; }

  $ sx <<< 'flex'
  .flex { display: flex; }

  $ sx <<< 'basis-32'
  .basis-32 { flex-basis: 8rem; }

  $ sx <<< 'basis-px'
  .basis-px { flex-basis: 1px; }

  $ sx <<< 'basis-1.5'
  .basis-1.5 { flex-basis: 0.375rem; }

  $ sx <<< 'hidden'
  .hidden { display:none; }

  $ sx <<< 'fixed'
  .fixed { position: fixed; }

  $ sx <<< 'absolute'
  .absolute { position: absolute; }

  $ sx <<< 'float-end'
  .float-end { float:inline-end; }

  $ sx <<< 'clear-none'
  .clear-none { clear: none; }

  $ sx <<< 'object-cover'
  .object-cover { object-fit: cover; }

  $ sx <<< 'border'
  .border { border-width: 1px; }

  $ sx <<< 'border-0'
  .border-0 { border-width: 0px; }

  $ sx <<< 'border-2'
  .border-2 { border-width: 2px; }

  $ sx <<< 'border-t'
  .border-t { border-top-width: 1px; }

  $ sx <<< 'border-x'
  .border-x { border-left-width: 1px;border-right-width: 1px; }

  $ sx <<< 'border-y-4'
  .border-y-4 { border-top-width: 4px;border-bottom-width: 4px; }

  $ sx <<< 'border-black'
  .border-black { border-color: #000; }

  $ sx <<< 'border-red-400'
  .border-red-400 { border-color: oklch(0.704 0.191 22.216); }

  $ sx <<< 'border-x-red-400'
  .border-x-red-400 { border-left: oklch(0.704 0.191 22.216);border-right: oklch(0.704 0.191 22.216); }

  $ sx <<< 'border-e-current'
  .border-e-current { border-inline-end: currentColor; }

  $ sx <<< 'border-slate-50'
  .border-slate-50 { border-color: oklch(0.984 0.003 247.858); }

  $ sx <<< 'border-y-sky-400'
  .border-y-sky-400 { border-top: oklch(0.746 0.16 232.661);border-bottom: oklch(0.746 0.16 232.661); }

  $ sx <<< 'border-none'
  .border-none { border-style: none; }

  $ sx <<< 'divide-fuchsia-950'
  .divide-fuchsia-950 { border-color: oklch(0.293 0.136 325.661); }

  $ sx <<< 'outline-slate-800'
  .outline-slate-800 { outline-color: oklch(0.279 0.041 260.031); }

  $ sx <<< 'ring-neutral-100'
  .ring-neutral-100 { --sx-ring-color: oklch(0.97 0 0); }

  $ sx <<< 'shadow-neutral-900'
  .shadow-neutral-900 { --sx-shadow-color: oklch(0.205 0 0); }

  $ sx <<< 'text-stone-300'
  .text-stone-300 { color: oklch(0.869 0.005 56.366); }

  $ sx <<< 'text-red-500'
  .text-red-500 { color: oklch(0.637 0.237 25.331); }

  $ sx <<< 'text-transparent'
  .text-transparent { color: transparent; }

  $ sx <<< 'decoration-pink-500'
  .decoration-pink-500 { text-decoration-color: oklch(0.656 0.241 354.308); }

  $ sx <<< 'bg-inherit'
  .bg-inherit { background-color: inherit; }

  $ sx <<< 'bg-violet-900'
  .bg-violet-900 { background-color: oklch(0.38 0.189 293.745); }

  $ sx <<< 'bg-origin-padding'
  .bg-origin-padding { background-origin: padding-box; }

  $ sx <<< 'bg-right-bottom'
  .bg-right-bottom { background-position: right bottom; }

  $ sx <<< 'bg-no-repeat'
  .bg-no-repeat { background-repeat:no-repeat; }

  $ sx <<< 'bg-repeat-x'
  .bg-repeat-x { background-repeat:repeat-x; }

  $ sx <<< 'bg-none'
  .bg-none { background-image:none; }

  $ sx <<< 'bg-auto'
  .bg-auto { background-size: auto; }

  $ sx <<< 'accent-zinc-400'
  .accent-zinc-400 { accent-color: oklch(0.705 0.015 286.067); }

  $ sx <<< 'accent-auto'
  .accent-auto { accent-color:auto; }

  $ sx <<< 'caret-white'
  .caret-white { caret-color: #fff; }

  $ sx <<< 'scroll-m-11'
  .scroll-m-11 { scroll-margin: 2.75rem; }

  $ sx <<< 'scroll-mr-72'
  .scroll-mr-72 { scroll-margin-right: 18rem; }

  $ sx <<< 'scroll-p-0'
  .scroll-p-0 { scroll-padding: 0px; }

  $ sx <<< 'scroll-px-96'
  .scroll-px-96 { scroll-padding-left: 24rem;scroll-padding-right: 24rem; }

  $ sx <<< 'fill-sky-50'
  .fill-sky-50 { fill: oklch(0.977 0.013 236.62); }

  $ sx <<< 'stroke-gray-600'
  .stroke-gray-600 { stroke: oklch(0.446 0.03 256.802); }

  $ sx <<< 'stroke-2'
  .stroke-2 { stroke-width: 2; }

indent
  $ sx <<< 'indent-0 indent-px indent-1 indent-3.5 indent-96'
  .indent-0 { text-indent: 0px; }
  .indent-1 { text-indent: 0.25rem; }
  .indent-3.5 { text-indent: 0.875rem; }
  .indent-96 { text-indent: 24rem; }
  .indent-px { text-indent: 1px; }

text
  $ sx <<< 'text-sm text-base text-9xl'
  .text-9xl { font-size: 8rem; line-height: 1; }
  .text-base { font-size: 1rem; line-height: calc(1.5 / 1); }
  .text-sm { font-size: 0.875rem; line-height: calc(1.25 / 0.875); }

top-right-bottom-left
  $ sx <<< 'inset-0 left-96 inset-64 inset-y-72 right-56 bottom-3 end-4 start-7 top-5 right-0 inset-x-px bottom-0.5 inset-x-auto end-2/3 top-3/4 start-full'
  .bottom-0.5 { bottom: 0.125rem; }
  .bottom-3 { bottom: 0.75rem; }
  .end-2/3 { inset-inline-end: 66.6666666667%; }
  .end-4 { inset-inline-end: 1rem; }
  .inset-0 { inset: 0px; }
  .inset-64 { inset: 16rem; }
  .inset-x-auto { left: auto;right: auto; }
  .inset-x-px { left: 1px;right: 1px; }
  .inset-y-72 { top: 18rem;bottom: 18rem; }
  .left-96 { left: 24rem; }
  .right-0 { right: 0px; }
  .right-56 { right: 14rem; }
  .start-7 { inset-inline-start: 1.75rem; }
  .start-full { inset-inline-start: 100%; }
  .top-3/4 { top: 75%; }
  .top-5 { top: 1.25rem; }

gap
  $ sx <<< 'gap-0 gap-0.5 gap-px gap-6 gap-96'
  .gap-0 { gap: 0px; }
  .gap-0.5 { gap: 0.125rem; }
  .gap-6 { gap: 1.5rem; }
  .gap-96 { gap: 24rem; }
  .gap-px { gap: 1px; }

gap x/y
  $ sx <<< 'gap-x-0 gap-y-0.5 gap-x-px gap-y-6 gap-x-96'
  .gap-x-0 { column-gap: 0px; }
  .gap-x-96 { column-gap: 24rem; }
  .gap-x-px { column-gap: 1px; }
  .gap-y-0.5 { row-gap: 0.125rem; }
  .gap-y-6 { row-gap: 1.5rem; }

width
  $ sx <<< 'w-0 w-px w-0.5 w-14 w-96 w-auto w-1/2 w-5/6 w-9/12 w-full'
  .w-0 { width: 0px; }
  .w-0.5 { width: 0.125rem; }
  .w-1/2 { width: 50%; }
  .w-14 { width: 3.5rem; }
  .w-5/6 { width: 83.3333333333%; }
  .w-9/12 { width: 75%; }
  .w-96 { width: 24rem; }
  .w-auto { width: auto; }
  .w-full { width: 100%; }
  .w-px { width: 1px; }

width extra
  $ sx <<< 'w-lvw w-dvw w-fit w-max w-min w-screen w-svw'
  .w-dvw { width: 100dvw; }
  .w-fit { width: fit-content; }
  .w-lvw { width: 100lvw; }
  .w-max { width: max-content; }
  .w-min { width: min-content; }
  .w-screen { width: 100vw; }
  .w-svw { width: 100svw; }

height
  $ sx <<< 'h-0 h-px h-0.5 h-14 h-96 h-auto h-1/2 h-5/6 h-full'
  .h-0 { height: 0px; }
  .h-0.5 { height: 0.125rem; }
  .h-1/2 { height: 50%; }
  .h-14 { height: 3.5rem; }
  .h-5/6 { height: 83.3333333333%; }
  .h-96 { height: 24rem; }
  .h-auto { height: auto; }
  .h-full { height: 100%; }
  .h-px { height: 1px; }

height extra
  $ sx <<< 'h-lvh h-dvh h-fit h-max h-min h-screen h-svh'
  .h-dvh { height: 100dvh; }
  .h-fit { height: fit-content; }
  .h-lvh { height: 100lvh; }
  .h-max { height: max-content; }
  .h-min { height: min-content; }
  .h-screen { height: 100vh; }
  .h-svh { height: 100svh; }

  $ sx <<< 'md:border-t'
  @media (min-width: 768px) {
    .md\:border-t { border-top-width: 1px; }
  }

  $ sx <<< 'hover:bg-red-100'
  .hover\:bg-red-100:hover { background-color: oklch(0.936 0.032 17.717); }

  $ sx <<< 'focus:hover:bg-red-100'
  .hover\:focus\:bg-red-100:hover:focus { background-color: oklch(0.936 0.032 17.717); }

  $ sx <<< 'border-red-500'
  .border-red-500 { border-color: oklch(0.637 0.237 25.331); }

  $ sx <<< 'hover:border-red-500'
  .hover\:border-red-500:hover { border-color: oklch(0.637 0.237 25.331); }

  $ sx <<< 'bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded'
  .bg-blue-500 { background-color: oklch(0.623 0.214 259.815); }
  .hover\:bg-blue-700:hover { background-color: oklch(0.488 0.243 264.376); }
  .px-4 { padding-left: 1rem;padding-right: 1rem; }
  .py-2 { padding-top: 0.5rem;padding-bottom: 0.5rem; }
  .text-white { color: #fff; }

  $ sx <<< 'md:mx-auto mx-2'
  .mx-2 { margin-left: 0.5rem;margin-right: 0.5rem; }
  @media (min-width: 768px) {
    .md\:mx-auto { margin-left: auto;margin-right: auto; }
  }

  $ sx <<< 'hover:mx-auto lg:mt-0 md:mx-2x mt-1'
  .hover\:mx-auto:hover { margin-left: auto;margin-right: auto; }
  .mt-1 { margin-top: 0.25rem; }
  @media (min-width: 1024px) {
    .lg\:mt-0 { margin-top: 0px; }
  }

  $ sx << EOF
  > <div class="{{ error ? 'text-red-600' : 'text-green-600' }}"></div>
  > EOF
  .text-green-600 { color: oklch(0.627 0.194 149.214); }
  .text-red-600 { color: oklch(0.577 0.245 27.325); }

  $ sx <<< 'shadow-none'
  .shadow-none { box-shadow: 0 0 #0000; }

  $ sx <<< 'shadow'
  .shadow { box-shadow: 0 1px 3px 0 var(--sx-shadow-color, rgb(0 0 0 / 0.1)), 0 1px 2px -1px var(--sx-shadow-color, rgb(0 0 0 / 0.1)); }

  $ sx <<< 'shadow-black'
  .shadow-black { --sx-shadow-color: #000; }

  $ sx <<< 'shadow-sm shadow-red-500'
  .shadow-red-500 { --sx-shadow-color: oklch(0.637 0.237 25.331); }
  .shadow-sm { box-shadow: 0 1px 3px 0 var(--sx-shadow-color, rgb(0 0 0 / 0.1)), 0 1px 2px -1px var(--sx-shadow-color, rgb(0 0 0 / 0.1)); }

