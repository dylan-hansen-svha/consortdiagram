program consortdiagram
	version 17
	syntax varlist (min=1) [if] [in], [font(string) right(varlist) left(varlist) tcolor(string) ///
		fcolor(string) lcolor(string) margin(string) width(real 4.5) height(real 0) ]	
	
	*Make sure syntax is correct*
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
	*END Make sure syntax is correct*
	
	*Set defaults*
	local userif = subinstr("`if'", "if", "&", 1)
	
	if "`font'" == "" {
		local font = "Arial"
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
	
	***Set up the data frame***
	local curframe = c(frame)
	frame `curframe' {
		capture confirm frame consortDiagramFrame
		if !_rc {
			frame drop consortDiagramFrame
			frame create consortDiagramFrame parent_no str30(parent_name) str30(name) ///
				str30(font) str30(layout) str250(description) str300(text) text_row_inputs ///
				str30(tcolor) str30(fcolor) str30(lcolor) str30(margin) ///
				width height
		} 
		else {
			frame create consortDiagramFrame parent_no str30(parent_name) str30(name) ///
				str30(font) str30(layout) str250(description) str300(text) text_row_inputs ///
				str30(tcolor) str30(fcolor) str30(lcolor) str30(margin) ///
				width height
		}
	}
	***END set up the data frame***
	
	***Depth first search through the variables***
	*Number of variable
	local k : word count `varlist'
	*Levels of each variable
	forvalues i = 1/`k' {
		local v : word `i' of `varlist'
		levelsof `v' `if' `in', local(levels_`i')
		local number_levels = `r(r)'
		
		*Check levels of varlist*
		if `number_levels' > 1 & `i' == 1 {
			di in red "First variable must be 1 level" 
			error 123
		}
		else if `number_levels' < 1 & `i' == 1 {
			di in red "First variable must be 1 level" 
			error 122
		}
		*END Check levels of varlist*
	}
	
	*Initialize the stack
	local stack_top 1
	local stack_depth1 1
	local stack_filter1 ""
	local stack_parent1 .
	local dfs_counter = 0
	
	*Loop through
	while `stack_top' > 0 {
		local depth  `stack_depth`stack_top''
		local filter "`stack_filter`stack_top''"
		local parent_id  `stack_parent`stack_top''
		local --stack_top
		local v : word `depth' of `varlist'
		local levels levels_`depth'
		local var_lbe : variable label `v'
		local lbe : value label `v'
		
		if `: list v in right' {
			local layout = "msoOrgChartLayoutRightHanging"
		}  
		else if `: list v in left' {
			local layout = "msoOrgChartLayoutLeftHanging"
		}
		else {
			local layout = "msoOrgChartLayoutStandard"
		}
		
		foreach lvl of local `levels' {
			*Count rows
			if "`filter'" != "" {
				count `in' if `filter' & `v' == `lvl' `userif'
				local count = r(N)
			}
			else {
				count `in' if `v' == `lvl' `userif'
				local count = r(N)
			}
			local n = `count'
			local var_val : label `lbe' `lvl'
			local combined = `""' + char(34) + "`var_lbe': `var_val': n=`count'"  + char(34) + `""' 
			local combined_alt = "`var_lbe': `var_val': n=`count'"
			
			if `count' > 0 {
				*Next filter
				local newfilter "`filter'"
				if "`newfilter'" != "" local newfilter "`newfilter' & "
				local newfilter "`newfilter'`v'==`lvl'"
				local ++dfs_counter
				local this_id = `dfs_counter'
				local this_parent = `parent_id'
				
				if `depth' < `k' {
					*Push next level
					local ++stack_top
					local stack_depth`stack_top' = `depth' + 1
					local stack_filter`stack_top' "`newfilter'"
					local stack_parent`stack_top' = `this_id'
				}
				else {
					*Do nothing for now
				}
				
				if `this_parent' == . {
					local parent_no = 0
				}
				else {
					local parent_no = .
				}
				*di "`combined'"
				frame `curframe' {
					frame post consortDiagramFrame (`parent_no') ("`this_parent'") ("`this_id'") ("`font'") ("`layout'") ///
						(`combined') ("`combined_alt'") (1) ("`tcolor'") ("`fcolor'") ("`lcolor'") ///
						("`margin'") (`width') (`height')
				}
			}			
		}
	}
	
	***END Depth first search through the variables***	
end 