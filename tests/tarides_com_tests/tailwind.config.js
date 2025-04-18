module.exports = {
content: [
    "./site.classes"
  ],
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
  ],
  theme: {
    extend: {
      fontFamily: {
          'orkney': ['Orkney', '-apple-system', 'system-ui', 'Helvetica', 'Arial', 'sans-serif'],
          'sukhumvit' : ['Sukhumvit','-apple-system','BlinkMacSystemFont','Helvetica','Arial','sans-serif'],
          'vision' : ['Vision','-apple-system','BlinkMacSystemFont','Helvetica','Arial','sans-serif'],
      },
      typography: (theme) => ({
        DEFAULT: {
          css: [{
            'code::before': {
              content: '""',
            },
            'code::after': {
              content: '""',
            },
            h1: {
              fontWeight: 700,
            },
            code: {
              fontSize: "1em",
            },
            'h2 code': {
              fontSize: "1em",
            },
            'h3 code': {
              fontSize: "1em",
            },
          }]
        },
        sm: {
          css: {
            code: {
              fontSize: "1em",
            },
          },
        }
      }),
    }
  }};
