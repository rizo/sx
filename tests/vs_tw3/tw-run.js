const Tailwindcss = require('tailwindcss');
const Postcss = require('postcss');
const Lightningcss = require('lightningcss');
const Fs = require('node:fs/promises');

function gen(input, config) {
  return Postcss(Tailwindcss(config)).process(input, { from: undefined })
}

function format(input) {
  return Lightningcss
    .transform({
      filename: 'input.css',
      code: Buffer.from(input),
      minify: true,
      targets: { chrome: 106 << 16 },
      drafts: {
        nesting: true,
        customMedia: true,
      },
    })
    .code.toString('utf8')
}

function classNameToCss(className) {
  let config = {
    content: [ { raw: className } ],
    corePlugins: { preflight: false },
    theme: {
      extend: {
        colors: {
          'red': {
            '500': '#dead00'
          },
        },
      }
    }
  }
  let input = "@tailwind utilities;";
  return gen(input, config).then((result) => {
    return format(result.css);
  })
}

async function main() {
  const file = await Fs.open('/dev/stdin');
  for await (const line of file.readLines()) {
    classNameToCss(line).then(css => {
      if (!css) {
        console.warn("empty css: input: ", line)
      }
      console.log(css)
    })
  }
}

main()

