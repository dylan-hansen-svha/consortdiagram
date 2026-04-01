program consortdiagram_generate
	version 17
	syntax, [font(string) vba background(string)]
	
	***defaults***
	if "`background'" != "" {
		local background = "plotregion(fcolor(`background'))"
	}
	***END defaults***
	
	frame consortDiagramFrame {
		*gen orig_order = _n
		*Idividal rowid
		gen id = _n 
		gen text_form = text if text_row_inputs != 1
		replace text = subinstr(text, `"""', "", .)
		**get parent row ID because IDs are easier to work with than strings**
		gen parent_id = .
		levelsof name, local(prev_row_name)
		foreach var in `prev_row_name' {
			summ id if name == "`var'"
			replace parent_id = `r(mean)' if parent_name == "`var'"
		}
		**END get parent row ID because IDs are easier to work with than strings**
		
		***Margins***
		gen font_size = 0.4
		gen x_margin = font_size*0.25 if margin == "tiny"
		gen y_margin = font_size*0.25 if margin == "tiny"
		replace x_margin = font_size*0.35 if margin == "vsmall"
		replace y_margin = font_size*0.35 if margin == "vsmall"
		replace x_margin = font_size*0.5 if margin == "small"
		replace y_margin = font_size*0.5 if margin == "small"
		replace x_margin = font_size*0.75 if margin == "medsmall"
		replace y_margin = font_size*0.75 if margin == "medsmall"
		replace x_margin = font_size*1 if margin == "medium"
		replace y_margin = font_size*1 if margin == "medium"
		replace x_margin = font_size*1.25 if margin == "medlarge"
		replace y_margin = font_size*1.25 if margin == "medlarge"
		replace x_margin = font_size*1.5 if margin == "large"
		replace y_margin = font_size*1.5 if margin == "large"
		replace x_margin = font_size*1.75 if margin == "vlarge"
		replace y_margin = font_size*1.75 if margin == "vlarge"
		split margin, generate(margin_)
		capture gen margin_1 = ""
		capture gen margin_2 = ""
		capture gen margin_3 = ""
		capture gen margin_4 = ""
		destring margin_*, replace force
		replace x_margin = margin_1 + margin_2 if margin_1 != . & margin_2 != .
		replace y_margin = margin_3 + margin_4 if margin_3 != . & margin_4 != .
		drop margin_1 margin_2 margin_3 margin_4
		replace x_margin = 0 if x_margin == .
		replace y_margin = 0 if y_margin == .
		replace width = width + x_margin
		/*replace margin = string(x_margin/2) + " " + string(x_margin/2) + " " + ///
			string(y_margin/2) + " " + string(y_margin/2) if inlist(margin, "tiny", ///
			"vsmall", "small", "medsmall", "medium", "medlarge", "large", "vlarge")*/
		***END margins***

		**Reverse the order for how it looks**
		sort parent_id id
		replace parent_id = 0 if parent_id == .
		gen id_inverse = id * -1
		sort parent_id id_inverse
		gen order_alt = _n
		drop parent_id id_inverse id
		gen id = order_alt
		gen parent_id = .
		levelsof name, local(prev_row_name)
		foreach var in `prev_row_name' {
			summ id if name == "`var'"
			replace parent_id = `r(mean)' if parent_name == "`var'"
		}
		sort parent_id id
		**END Reverse the order for how it looks**

		gen visited = 0
		gen left = 0
		replace left = 1 if layout == "msoOrgChartLayoutLeftHanging"
		gen left_sub = 0
		gen order = .
		* Initialize
		local stack 1 // root node
		local counter 1
		summ id
		local max = `r(max)'

		**Depth first search**
		while "`stack'" != "" & `counter' <= `max' {
			*Get the top node from the stack
			tokenize `stack'
			local current = `1'
			gettoken current stack : stack
			* Mark as visited and assign traversal order
			replace visited = 1 if id == `current'
			quietly replace order = `counter' if id == `current'
			local ++counter

			* Find children of this node and add them to the stack
			local children
			levelsof id if parent_id == `current', local(children)
			
			*left hanging
			summ left if id == `current'
			local left_above = `r(max)'
			local left_sub = 0

			* Push children onto stack in reverse order (so first child is popped first)
			foreach child of local children {
				*local stack "`child' `stack'"
				local stack "`child' `stack'"
				replace left = left + `left_above' if id == `child'
				summ left if id == `child'
				local left_sub = `r(max)'
			}
			replace left_sub = `left_sub' if id == `current'
		}
		
		gen parent_node = .
		levelsof name, local(prev_row_name)
		foreach var in `prev_row_name' {
			summ order if name == "`var'"
			replace parent_node = `r(mean)' if parent_name == "`var'"
		}
		sort order
		replace left = left - 1 if layout == "msoOrgChartLayoutLeftHanging"
		**END Depth first search**
		if "`vba'" == "vba" {
			file open vbacode using vbacode.txt, write replace
			file write vbacode "Sub GenOrgChart ()" _n
			file write vbacode "	Dim myShape As Shape" _n
			file write vbacode "	Dim mySmartArt as SmartArt" _n
			file write vbacode "	Set myShape = ActiveDocument.Shapes.AddSmartArt(Application.SmartArtLayouts("
			file write vbacode `"""'
			file write vbacode "urn:microsoft.com/office/officeart/2005/8/layout/orgChart1"
			file write vbacode `"""'
			file write vbacode "), 0, 0, 451, 696)" _n
			file write vbacode "	Set mySmartArt = myShape.SmartArt" _n
			file write vbacode "	mySmartArt.Color = Application.SmartArtColors(1)" _n
			file write vbacode "	mySmartArt.AllNodes(5).Delete" _n
			file write vbacode "	mySmartArt.AllNodes(4).Delete" _n
			file write vbacode "	mySmartArt.AllNodes(3).Delete" _n
			file write vbacode "	mySmartArt.AllNodes(2).Delete" _n
			local i = 1
			local font = font[`i']
			local layout = layout[`i']
			local text = text[`i']
			*Text
			file write vbacode "	mySmartArt.AllNodes(`i').TextFrame2.TextRange.Text =  " 
			file write vbacode `"""' 
			file write vbacode "`text'"
			file write vbacode `"""' _n
			*font
			file write vbacode "    mySmartArt.AllNodes(`i').TextFrame2.TextRange.Font.Name = " 
			file write vbacode `"""' 
			file write vbacode "`font'"
			file write vbacode `"""' _n
			*layout
			file write vbacode "	mySmartArt.AllNodes(`i').OrgChartLayout = `layout'" _n

			summ order
			forval i = 2 / `r(max)' {
				local font = font[`i']
				local layout = layout[`i']
				local text = text[`i']
				local parent_node = parent_node[`i']
				file write vbacode "	mySmartArt.AllNodes(`parent_node').AddNode(msoSmartArtNodeBelow)" _n
				*Text
				file write vbacode "	mySmartArt.AllNodes(`i').TextFrame2.TextRange.Text =  " 
				file write vbacode `"""' 
				file write vbacode "`text'"
				file write vbacode `"""' _n
				*font
				file write vbacode "    mySmartArt.AllNodes(`i').TextFrame2.TextRange.Font.Name = " 
				file write vbacode `"""' 
				file write vbacode "`font'"
				file write vbacode `"""' _n
				*layout
				file write vbacode "	mySmartArt.AllNodes(`i').OrgChartLayout = `layout'" _n
			}
			file write vbacode "End Sub" _n
			file close vbacode
		}
		
		if "`font'" != "" {
			replace font = "`font'"
		}

		replace parent_node = 0 if parent_node == .
		drop order_alt visited
		capture drop children

		gen row = 1
		sort order
		summ order
		forval i = 2/`r(max)' {
			summ parent_node if order == `i'
			local parent_row = `r(min)'
			local parent_layout = layout[`parent_row']
			summ row if order == `parent_row'
			replace row = `r(min)' + 1 if order == `i' & "`parent_layout'" == "msoOrgChartLayoutStandard"
			
			summ id if order == `parent_row'
			local parent_id = `r(min)'
			levelsof id if parent_id == `parent_id', separate(,) local(children)
			summ row if (inlist(id,`children') | id == `parent_id' | inlist(parent_id,`children'))  & order <= `i'
			*replace row = `r(max)' + 1 if order == `i' & "`parent_layout'" == "msoOrgChartLayoutRightHanging"
			replace row = `r(max)' + 1 if order == `i' & inlist("`parent_layout'", "msoOrgChartLayoutRightHanging", ///
				"msoOrgChartLayoutLeftHanging")
		}
		bysort row (order): egen col_total = count(row)
		bysort row (order): gen col = _n
		sort order

		gen row_invert = row * -1

		***get the correct columns***
		bysort parent_id (order): gen child_number = _n
		
		gen blork = .
		gen col_new = .
		local col_new = 1
		sort order
		summ order
		forval i = 1/`r(max)' {
			local layout = layout[`i']
			*Get Parent layout
			summ parent_node if order == `i'
			local parent_row = `r(min)'
			local parent_layout = layout[`parent_row']
			local child_number = child_number[`i']
			di "i = `i' parent_layout = `parent_layout' child_number = `child_number'"
			if "`parent_layout'" == "msoOrgChartLayoutStandard" & `child_number' != 1 {
				local col_new = `col_new' + 1 + 0.125
			}
			if "`parent_layout'" == "msoOrgChartLayoutRightHanging" & `child_number' == 1 {
				local col_new = `col_new' + 0.125
			}
			if "`parent_layout'" == "msoOrgChartLayoutLeftHanging" & `child_number' == 1 {
				replace col_new = col_new + 0.125 if col_new >= `col_new'
				local col_new = `col_new' + 0.125
			}
			summ id if order == `i'
			summ parent_id if parent_id == `r(min)'
			local number_sub = `r(N)'
			*summ left if order == `i'
			*if "`layout'" == "msoOrgChartLayoutLeftHanging" & `number_sub' != 0 & `r(max)' == 0 {
			if "`layout'" == "msoOrgChartLayoutLeftHanging" & `number_sub' != 0 & left[`i'] == 0 {
**# Bookmark #1
				**summ left_sub if order == `i'
				**local col_new = `col_new' + (0.125 * (`r(max)'))
				*local col_new = `col_new' + (0.125 * left_sub[`i'])
				replace blork = `col_new' if order == `i'
				
			}
			/*if "`layout'" == "msoOrgChartLayoutLeftHanging" & child_number[`i'] == 1 {
				replace col_new = col_new + 0.125 if col_new >= `col_new'
			}*/
			
			replace col_new = `col_new' if order == `i'
			/*if "`parent_layout'" == "msoOrgChartLayoutLeftHanging" & `child_number' == 1 {
				replace col_new = `col_new' - 0.125 if order == `i'
			}*/
			*replace col_new = col_new - 0.125*left if order == `i'
			
			if "`parent_layout'" == "msoOrgChartLayoutRightHanging" & `child_number' != 1 {
				summ col_new if parent_node == `parent_row' & child_number == 1 
				replace col_new = `r(min)' if order == `i'
			}
			if "`parent_layout'" == "msoOrgChartLayoutLeftHanging" & `child_number' != 1 {
				summ col_new if parent_node == `parent_row' & child_number == 1 
				replace col_new = `r(min)' if order == `i'
			}
		}
		replace col_new = col_new - left*0.125
		***END get the correct columns***
		
		egen col_max = max(col)
		capture drop count_row
		bysort row (order): egen count_row = count(row)
		sort order
		replace count_row = . if count_row[_n-1] != 1 & _n != 1
		gen col_disp = col_new
		replace col_disp = (col_max - 1)/2+1 if count_row == 1
		
		***Format text***
		*gen smcl_tag = "{fontface " + `"""' + font + `"""' + ":" if font != ""
		gen smcl_tag = "{fontface " + font + ":" if font != ""
		gen smcl_end = "}" if font != ""
		gen text_len = strlen(text)
		gen word_count = wordcount(text)

		gen word = ""
		gen pos = .
		gen word_len = .
		*replace text_form = `"""' if text_row_inputs == 1
		replace text_form = `"""' + smcl_tag if text_row_inputs == 1
		gen str_pos = 0
		gen text_rows = 1
		summ word_count
		forval i = 1/`r(max)' {
			replace word = word(text,`i')
			replace word_len = strlen(word)
			replace pos = strpos(text,word)
			replace str_pos = str_pos + word_len + 1
			/*replace text_form = text_form + `"""' + " " + `"""' if str_pos > 22 & `i' <= word_count & ///
				text_row_inputs == 1*/
			replace text_form = text_form + smcl_end + `"""' + " " + `"""' + smcl_tag if str_pos > 22 & `i' <= word_count & ///
				text_row_inputs == 1
			replace text_rows = text_rows + 1 if str_pos > 22 & `i' <= word_count
			replace str_pos = 0 + word_len + 1 if str_pos > 22
			replace text_form = text_form + word + " " if `i' < word_count & text_row_inputs == 1
			replace text_form = text_form + word  if `i' == word_count & text_row_inputs == 1
		}
		*replace text_form = text_form + `"""' if text_row_inputs == 1 
		replace text_form = text_form + smcl_end + `"""' if text_row_inputs == 1 
		***END Format text***
		
		***Size of box based on text rows***
		bysort row (order): egen max_text_rows = max(text_rows)
		sort order
		local ofset = 0
		gen y_coord = row_invert
		*gen height = max_text_rows*0.4+0.2
		replace height = max_text_rows*0.4+0.2 + y_margin if height == .
		gen above = y_coord if row_invert == -1
		gen below = y_coord - height if row_invert == -1
		summ row_invert
		forval i = -2(-1)`r(min)' {
			local j = `i' + 1
			summ below if row_invert == `j'
			replace above = `r(min)' - 1 if row_invert == `i'
			replace below = above - height if row_invert == `i'
			replace y_coord = above if row_invert == `i'
		}
		***END Size of box based on text rows***
		*br name order row col col_disp row_invert text_rows text_form max_text_rows y_coord above below
		
		***Position of box***
		capture drop dif
		gen dif = .
		sort order
		summ order
		forval i = 1/`r(max)' {
			*Get Parent layout
			summ id if order == `i' & layout == "msoOrgChartLayoutStandard"
			if `r(N)' != 0 {
				local parent_id = `r(min)'
				summ col_disp if parent_id == `parent_id'
				if `r(N)' != 0 {
					replace dif = (`r(max)' - `r(min)')/2 if order == `i' & count_row != 1
				}
			}
		}
		drop count_row
		replace col_disp = col_disp + dif if !inlist(dif,0,.) & layout == "msoOrgChartLayoutStandard"
		drop dif
		
		summ width
		local width_max = `r(max)'
		gen x_in = .
		gen y_in = .
		gen x_in2 = .
		gen y_in2 = .
		gen x_out = .
		gen y_out = below
		gen y_out2 = .
		sort order
		summ order
		forval i = 1/`r(max)' {
			local layout = layout[`i']
			if "`layout'" == "msoOrgChartLayoutStandard" {
				*replace x_out = col_disp + (4.5/2)/5 if order == `i'
				replace x_out = col_disp + 0.5 if order == `i'
				replace y_out2 = below - .5 if order == `i'
			}
			else if "`layout'" == "msoOrgChartLayoutRightHanging" {
				replace x_out = col_disp + .0625 if order == `i'
				di "i `i'"
				summ parent_id if order == `i'
				local parent_id = `r(min)'
				summ y_coord if parent_id == `parent_id'
				local min = `r(min)'
				local numb = `r(N)'
				if `numb' != 0 {
					*di "parent_id `parent_id' di min `min')"
					*summ below if id == `parent_id' 
					*replace y_out2 = `r(mean)'  if order == `i'
					*summ height if order == `i'
					*local height = `r(mean)'
					*replace y_out = y_out + (`height'/2)  if order == `i'
					summ below if order == `i'
					replace y_out = `r(mean)'  if order == `i'
					*summ x_in if parent_id == `i'
					*local y_out2 = `r(min)'
					*replace y_out2 = `y_out2'  if order == `i'
				}
				else {
					*replace y_out2 = y_out2 if order == `i'
					*replace y_out2 = .
				}
			}
			else if "`layout'" == "msoOrgChartLayoutLeftHanging" {
**# Bookmark #1
				*replace x_out = (col_disp + 1 - .0625)  if order == `i'
				replace x_out = (col_disp + (width[`i']/`width_max') - 0.0625) if order == `i'
				di "i `i'"
				summ parent_id if order == `i'
				local parent_id = `r(min)'
				summ y_coord if parent_id == `parent_id'
				local min = `r(min)'
				local numb = `r(N)'
				if `numb' != 0 {
					summ below if order == `i'
					replace y_out = `r(mean)'  if order == `i'
				}
				else {
					*replace y_out2 = y_out2 if order == `i'
					*replace y_out2 = .
				}
			}
			
			summ parent_node if order == `i'
			local parent_row = `r(min)'
			local parent_layout = layout[`parent_row']
			if "`parent_layout'" == "msoOrgChartLayoutStandard"  {
				*replace x_in = col_disp + (4.5/2)/5 if order == `i'
				replace x_in = col_disp + 0.5 if order == `i'
				replace y_in = above if order == `i'
				*replace x_in2 = col_disp + (4.5/2)/5 if order == `i'
				replace x_in2 = col_disp + 0.5 if order == `i'
				replace y_in2 = above + 0.5 if order == `i'
				
			}
			if "`parent_layout'" == "msoOrgChartLayoutRightHanging"  {
				summ parent_id if order == `i'
				summ x_out if id == `r(min)'
				*replace x_in = col_disp - .0625 if order == `i'
				replace x_in = `r(min)' if order == `i'
				replace y_in = y_coord - (height/2) if order == `i'
				replace x_in2 = col_disp if order == `i'
				replace y_in2 = y_coord - (height/2) if order == `i'
			}
			if "`layout'" == "msoOrgChartLayoutRightHanging" {
				if "`parent_layout'" == "msoOrgChartLayoutStandard" {
					replace y_out2 = . if order == `i'
				}
			}
			if "`parent_layout'" == "msoOrgChartLayoutLeftHanging"  {
				summ parent_id if order == `i'
				summ x_out if id == `r(min)'
				*replace x_in = col_disp - .0625 if order == `i'
				replace x_in = `r(min)' if order == `i'
				replace y_in = y_coord - (height/2) if order == `i'
				replace x_in2 = col_disp + (width[`i']/`width_max') if order == `i'
				replace y_in2 = y_coord - (height/2) if order == `i'
			}
			if "`layout'" == "msoOrgChartLayoutLeftHanging" {
				if "`parent_layout'" == "msoOrgChartLayoutStandard" {
					replace y_out2 = . if order == `i'
				}
			}
		}
		sort order
		summ order
		forval i = 1/`r(max)' {
			local layout = layout[`i']
			summ id if order == `i'
			local id = `r(min)'
			if "`layout'" == "msoOrgChartLayoutRightHanging" {
				summ y_coord if parent_id == `id'
				local numb = `r(N)'
				if `numb' != 0 {
					summ y_in if parent_id == `id'
					*local y_out2 = `r(min)'
					replace y_out2 = `r(min)'  if order == `i'
				}
			}
			if "`layout'" == "msoOrgChartLayoutLeftHanging" {
				summ y_coord if parent_id == `id'
				local numb = `r(N)'
				if `numb' != 0 {
					summ y_in if parent_id == `id'
					*local y_out2 = `r(min)'
					replace y_out2 = `r(min)'  if order == `i'
				}
			}
			summ parent_node if order == `i'
			local parent_row = `r(min)'
			local parent_layout = layout[`parent_row']
			if "`layout'" == "msoOrgChartLayoutRightHanging" {
				if "`parent_layout'" == "msoOrgChartLayoutStandard" {
					*replace y_out2 = . if order == `i'
				}
			}
			summ y_out if parent_id == `id'
			local numb = `r(N)'
			if `numb' == 0 {
				replace y_out = . if order == `i'
			}
		}
		gen x_out2 = x_out

		bysort row parent_name (col_disp): egen number_siblings = count(id)
		bysort row parent_name (col_disp): egen x_horizontal = min(x_in) if number_siblings != 1
		bysort row parent_name (col_disp): egen x_horizontal2 = max(x_in) if number_siblings != 1
		bysort row parent_name (col_disp): egen y_horizontal = min(y_in2) if number_siblings != 1
		bysort row parent_name (col_disp): egen y_horizontal2 = max(y_in2) if number_siblings != 1
		
		sort row order
		summ col_total if _n == 1
		local col_total = `r(max)'
		local i = 1
		gen for_shift = .
		while `col_total' == 1 {
			replace for_shift = 1 if _n == `i'
			local i = `i' + 1
			summ col_total if _n == `i'
			local col_total = `r(max)'
		}
		
		summ row if for_shift != 1
		if `r(N)' != 0 {
			local next_row = `r(min)'
			summ col_disp if row == `next_row'
			replace col_disp = (`r(max)' - `r(min)')/2 + `r(min)' if for_shift == 1
			*TODO its probably this
			summ x_in if row == `next_row'
			replace x_out = (`r(max)' - `r(min)')/2 + `r(min)' if for_shift == 1
			
			*summ x_out2 if row == `next_row'
			replace x_out2 = (`r(max)' - `r(min)')/2 + `r(min)' if for_shift == 1
			
			*summ x_in if row == `next_row'
			replace x_in = (`r(max)' - `r(min)')/2 + `r(min)' if for_shift == 1
			
			*summ x_in2 if row == `next_row'
			replace x_in2 = (`r(max)' - `r(min)')/2 + `r(min)' if for_shift == 1
		}
		sort order
		***END Position of box***
		
		***Generate the graph***
		local post = ""
		local post2 = ""
		local post3 = ""
		local post4 = ""
		sort order
		summ order
		forval i = 1/`r(max)' {
			local text = text_form[`i']
			local col = col_disp[`i']
			local row = y_coord[`i']
			local height = height[`i']
			local font = font[`i']
			local tcolor = tcolor[`i']
			local fcolor = fcolor[`i']
			local lcolor = lcolor[`i']
			local width = width[`i']
			*local post = `"`post' text(`row' `col' `"`text'"' ,box width(20) margin(small) size(vsmall))"'
			local post = `"`post' text(`row' `col' `text' ,box width(`width'cm) height(`height'cm) size(.4cm) placement(seast) color(`tcolor') fcolor(`fcolor') )"' //
			*fontface("`font'")
			local x1 = x_out[`i']
			local x2 = x_out2[`i']
			local y1 = y_out[`i']
			local y2 = y_out2[`i']
			local post2 = `"`post2' (pci `y1' `x1' `y2' `x2', color(`lcolor'))"'
			local x1 = x_in[`i']
			local x2 = x_in2[`i']
			local y1 = y_in[`i']
			local y2 = y_in2[`i'] 
			local post3 = `"`post3' (pci `y1' `x1' `y2' `x2', color(`lcolor'))"'
			local x1 = x_horizontal[`i']
			local x2 = x_horizontal2[`i']
			local y1 = y_horizontal[`i']
			local y2 = y_horizontal2[`i'] 
			if `x1' != . {
				local post4 = `"`post4' (pci `y1' `x1' `y2' `x2', color(`lcolor'))"'
			}	
		}

		summ below
		local bottom = floor(`r(min)')
		local ysize = abs(`bottom')
		summ col_disp
		local right = `r(max)'+1
		*summ width
		local width = (`right'-1)*`width_max'
		*1) PCI to draw a box 2) PIC lines coming out of boxes 3) PIC lines going into boxes 4) horizontal arrows 
		twoway  /// 
			(pci . . . ., xscale(range(1 `right') off) yscale(range(-.5 `bottom') off) ///
			ytitle("") xtitle("") xlabel(none) ylabel(none) plotregion(margin(none)) graphregion(margin(zero)) /// xlabel(1, nolabels) ylabel(-1,nogrid)
			ysize(`ysize'cm) xsize(`width'cm) legend(off) `post' `background') ///
			`post2' `post3' `post4'
		***END Generate the graph***	
	}
end
	