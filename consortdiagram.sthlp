{smcl}
{* *! version 1.0.0 25mar2026}{...}
{cmd:help consortdiagram}
{hline}

{title:Title}

{phang}
{cmd:consortdiagram} — Automatically generate node definitions for a CONSORT-style flow diagram

{hline}

{title:Syntax}

{p 8 17 2}
{cmd:consortdiagram} {varlist} [{cmd:if}] [{cmd:in}],  
[{cmd:font(}{it:string}{cmd:)}  
{cmd:right(}{it:varlist}{cmd:)}  
{cmd:left(}{it:varlist}{cmd:)}  
{cmd:tcolor(}{it:string}{cmd:)}    
{cmd:fcolor(}{it:string}{cmd:)}  
{cmd:lcolor(}{it:string}{cmd:)}  
{cmd:margin(}{it:string}{cmd:)}  
{cmd:width(}{it:#}{cmd:)}  
{cmd:height(}{it:#}{cmd:)}]

{p 4 4 2}
The first variable in {varlist} must have exactly one category.

{hline}

{title:Description}

{pstd}
{cmd:consortdiagram} automatically constructs the nodes for a CONSORT-style flow diagram by performing a depth-first search through all combinations of levels of the variables in {varlist}.  
Each unique combination of variable levels with at least 1 row in the dataset becomes a node in the diagram.

{pstd}
The command creates (or replaces) the frame {cmd:consortDiagramFrame} and populates it with:

{p 8 12 2}
• a unique numeric node identifier

{p 8 12 2}
• the identifier of the parent node

{p 8 12 2}
• the text to display inside the node

{p 8 12 2}
• the layout for the node (standard, left-hanging, right-hanging)

{p 8 12 2}
• global font and colour settings

{p 8 12 2}
• box width, height, and text margin

{pstd}
This command {it:does not} draw the diagram. 
After running {cmd:consortdiagram}, use {cmd:consortdiagram_generate} to render the final flow diagram.

{pstd}
All formatting options apply globally to every node.  
Only layout may vary by variable, using the {cmd:left()} and {cmd:right()} options.

{pstd}
The first variable in {varlist} must have exactly one category. 
This variable defines the root node of the diagram.

{hline}

{title:How node text is constructed}

{pstd}
For each variable–value combination, the node text is constructed as:

{p 8 12 2}
{it:variable label}{cmd::} {it:value label}{cmd:: n=}{it:count}

{pstd}
For example, if:

{p 8 12 2}
• variable label = {cmd:Gender}  
• value label = {cmd:Male}  
• count = 42

{pstd}
then the node text becomes:

{p 8 12 2}
{cmd:"Gender: Male: n=42"}

{hline}

{title:Options}

{dlgtab:Layout}

{phang}
{cmd:right(}{it:varlist}{cmd:)}  
Variables listed here will have their nodes arranged using a right-hanging layout  
(vertical alignment offset to the right).

{phang}
{cmd:left(}{it:varlist}{cmd:)}  
Variables listed here will have their nodes arranged using a left-hanging layout  
(vertical alignment offset to the left).

{phang}
Variables not listed in {cmd:left()} or {cmd:right()} use the standard layout  
(horizontal arrangement of children).

{dlgtab:Appearance (global)}

{phang}
{cmd:font(}{it:string}{cmd:)}  
Font family for all nodes. Default is {cmd:Arial}.

{phang}
{cmd:tcolor(}{it:string}{cmd:)}  
Text colour for all nodes. Default is {cmd:black}.

{phang}
{cmd:fcolor(}{it:string}{cmd:)}  
Fill colour for all nodes. Default is {cmd:none}.

{phang}
{cmd:lcolor(}{it:string}{cmd:)}  
Border line colour for all nodes. Default is {cmd:black}.

{phang}
{cmd:margin(}{it:string}{cmd:)}  
Margin between text and the border of each node. Default is {cmd:zero}.

{phang}
{cmd:width(}{it:#}{cmd:)}  
Width of the node's text box in centimetres.  
Default is missing ({cmd:.}), meaning automatic sizing to fit the supplied text.

{phang}
{cmd:height(}{it:#}{cmd:)}  
Height of the node's text box in centimetres.  
Default is missing ({cmd:.}), meaning automatic sizing to fit the supplied text.

{hline}

{title:Details}

{pstd}
{cmd:consortdiagram} performs a depth-first search through the variables in {varlist}. 
At each level, it enumerates all categories of the current variable and counts the number of observations satisfying all previous filters.

{pstd}
The frame {cmd:consortDiagramFrame} is always replaced when this command is run. 
Any node definitions created by {cmd:consortdiagrami} or a previous call to {cmd:consortdiagram} will be lost.

{pstd}
After the frame is populated, run {cmd:consortdiagram_generate} to draw the diagram.

{hline}

{title:Example}

{pstd}
The following example uses the NLSW88 dataset to generate a simple flow diagram:

{cmd}
    sysuse nlsw88.dta, clear
	
    gen all = 1
	
    label variable all "All data"
	
    label define lbl 1 ""
	
    label value all lbl
	
    consortdiagram all race married collgrad, right(married) font("Times New Roman")

    consortdiagram_generate
{txt}

{hline}

{title:Stored results}

{pstd}
{cmd:consortdiagram} stores no results in {cmd:r()} or {cmd:e()}.  
All information is written to the frame {cmd:consortDiagramFrame}.

{hline}

{title:See also}

{pstd}
{help consortdiagram_suite} — Information on the suite of commands
{p_end}
{pstd}
{help consortdiagrami} — Manually define individual nodes 
{p_end}
{pstd}
{help consortdiagram_generate} — Render the CONSORT-style flow diagram
{p_end}


{hline}

{title:Author}

{pstd}
Dylan Hansen  
St Vincent's hospital Melbourne, Australia  
{browse "mailto:dylan.hansen@svha.org.au":dylan.hansen@svha.org.au}

{hline}