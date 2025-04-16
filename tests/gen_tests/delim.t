
No match:
  $ sx <<< 'xmt-0'
  $ sx <<< 'mt-0x'
  $ sx <<< 'xmt-0y'

Delimited match:
  $ sx <<< 'xmt-0 mt-1'
  .mt-1{margin-top:0.25rem}

  $ sx <<< 'xmt-0 mt-1 xmt-2'
  .mt-1{margin-top:0.25rem}

  $ sx <<< 'mt-1 xmt-0'
  .mt-1{margin-top:0.25rem}

  $ sx <<< 'mt-1 mt-2 xmt-0'
  .mt-1{margin-top:0.25rem}
  .mt-2{margin-top:0.5rem}

  $ sx <<< 'mt-1 xmt-0 mt-2 xmt-8'
  .mt-1{margin-top:0.25rem}
  .mt-2{margin-top:0.5rem}

  $ sx <<< 'xmt-0 mt-1 xmt-8 mt-2'
  .mt-1{margin-top:0.25rem}
  .mt-2{margin-top:0.5rem}

  $ sx <<< 'class="mt-0"'
  .mt-0{margin-top:0px}

  $ sx <<< "className='mt-0'"
  .mt-0{margin-top:0px}

  $ sx <<< 'class_name {|mt-0|}'
  .mt-0{margin-top:0px}
