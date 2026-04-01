*clear all
program consortdiagrami
	version 17
	syntax anything(name=inputs), name(string) [parent(string) start font(string) ///
		standard right left tcolor(string) fcolor(string) lcolor(string) ///
		margin(string) width(real 4.5) height(real 0) ]
	*Make sure syntax is correct*
	if ("`parent'" == "" & "`start'" == "") {
        di as err "You must specify either parent() or start()."
        exit 198
    }
	if ("`standard'" != "" & "`right'" != "") {
        di as err "You can only specify 1 of standard or right."
        exit 198
    }
	if ("`standard'" != "" & "`left'" != "") {
        di as err "You can only specify 1 of standard or left."
        exit 198
    }
	if ("`left'" != "" & "`right'" != "") {
        di as err "You can only specify 1 of right or left."
        exit 198
    }
	if "`margin'" != "" {
		if !inlist("`margin'", "zero", "tiny", "vsmall", "small", "medsmall", "medium", "medlarge", "large", "vlarge") {
			tokenize "`margin'"
			local n : word count `margin'
			if `n' != 4 {
				di as err "margin() must contain either a keyword or four numbers"
				exit 198
			}
			foreach x in 1 2 3 4 {
				capture confirm number ``x''
				if _rc {
					di as err "margin() numeric values must be numbers"
					exit 198
				}
			}
		}
	}
	*END make sure syntax is correct*
	
	*Set defaults*
	local n : word count `inputs'
	local combined = ""
	local combined_alt = ""
	forval i = 1/`n' {
		local w : word `i' of `inputs'
		local combined = `"`combined' `""' + " "  + `""' + char(34) + `"`w'"' + char(34) + `""'  "'
		local combined_alt = "`combined_alt' `w'"
	}
	local layout = "msoOrgChartLayoutStandard"
	if "`right'" != "" {
		local layout = "msoOrgChartLayoutRightHanging"
	}
	if "`left'" != "" {
		local layout = "msoOrgChartLayoutLeftHanging"
	}
	if "`font'" == "" {
		local font = "Arial"
	}
	local parent_no = .
	if "`start'" != "" {
		local parent_no = 0 
		local parent = ""
	}
	if "`tcolor'" == "" {
		local tcolor = "black"
	}
	if "`fcolor'" == "" {
		local fcolor = "none"
	}
	if "`lcolor'" == "" {
		local lcolor = "black"
	}
	if "`margin'" == "" {
		local margin = "zero"
	}
	/*if `width' == 0 {
		local width = "."
	}*/
	if `height' == 0 {
		local height = "."
	}
	*END Set defaults*
	
	local curframe = c(frame)
	frame `curframe' {
		capture confirm frame consortDiagramFrame
		if !_rc {
			di "exists"
		} 
		else {
			frame create consortDiagramFrame parent_no str30(parent_name) str30(name) ///
				str30(font) str30(layout) str250(description) str300(text) text_row_inputs ///
				str30(tcolor) str30(fcolor) str30(lcolor) str30(margin) ///
				width height
		}
		di "hello"
		frame post consortDiagramFrame (`parent_no') ("`parent'") ("`name'") ("`font'") ("`layout'") ///
			(`combined') ("`combined_alt'") (`n') ("`tcolor'") ("`fcolor'") ("`lcolor'") ///
			("`margin'") (`width') (`height')
		di "hello2"
	}
end

/*foo

capture postclose flowchart
postfile flowchart parent_no str30(parent_name) str30(name) str30(font) str30(layout)  ///
	str50(description) str50(text) using flowchartData.dta, replace

program drop foo
program define foo
	syntax anything(name=inputs), name(string) [parent(string) start font(string) ///
		standard right]
	// The local macro `inputs` now contains all strings separated by spaces
    *di "You entered: `inputs'"

    // Count how many strings were provided
    local n : word count `inputs'
    di "Number of strings: `n'"
	*di "`inputs'"
	local word_1 : word 2 of `inputs'
	local combined = ""
	forval i = 1/`n' {
		*replace text_form = text_form + `"""' + " " + `"""' if str_pos > 22 & `i' <= word_count
		*local post = `"`post' (`"`group`g'_l_n' (`group`g'_l_p'%):n=`group`g'_n'"')"'
		local w : word `i' of `inputs'
		di "`w'"
		*`" `"""' `combined' `"`w' "'"'
		local combined = `"`combined' `""' + " "  + `""' + char(34) + `"`w'"' + char(34) + `""'  "'
	}
	*di "`combined'"
	*local combined : subinstr local combined " " "", 1
	/*di "`word_1'"
	di "`parent'"
	di "`start'"*/
	if ("`parent'" == "" & "`start'" == "") {
        di as err "You must specify either parent() or start()."
        exit 198
    }
	if ("`standard'" != "" & "`right'" != "") {
        di as err "You can only specify 1 of standard or right."
        exit 198
    }
	local mytext = "This is a " + "`char(34)'" + "quoted" + `"char(34)"' + " word."
	post flowchart (0) ("") ("start") ("Arial") (`combined') ///
		("This is a " + char(34) + "quoted" + char(34) + " word.") ("`mytext'")
end

foo "its hard to find a rhym" "but even harder to spell it", name(bruce) parent(blork)
*foo "hello" "goodbye", name(bruce) parent(blork)
postclose flowchart
clear 
use flowchartData.dta
br layout description text


local combined = `" `"""' hello`"""' "' 
di `combined'

	*/
