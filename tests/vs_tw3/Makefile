
# tw

simple-out.tw.css: simple-in.csv
	node ./tw-run.js < $< > $@

tarides-com-simple-out.tw.css: tarides-com-simple-in.csv
	node ./tw-run.js < $< > $@

tarides-com-issues-out.tw.css: tarides-com-issues-in.csv
	node ./tw-run.js < $< > $@


# sx

tarides-com-simple-out.sx.css: tarides-com-simple-in.csv ../../_build/default/tools/sx_linewise.exe
	../../_build/default/tools/sx_linewise.exe < $< > $@

# diff
.PHONY: diff
diff: tarides-com-simple-out.sx.css
	diff --color -a -d tarides-com-simple-out.tw.css tarides-com-simple-out.sx.css 

