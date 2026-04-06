{smcl}
{* *! version 1.0.0 25mar2026}{...}
{cmd:help consortdiagrami}
{hline}

{title:Title}

{phang}
{cmd:consortdiagrami} — Define a node for a CONSORT-style flow diagram

{hline}

{title:Syntax}

{p 8 17 2}
{cmd:consortdiagrami} {it:text} ,
{cmd:name(}{it:nodeid}{cmd:)}
[{cmd:parent(}{it:parentid}{cmd:)} {cmd:start}
{cmd:font(}{it:string}{cmd:)}
{cmd:standard} {cmd:left} {cmd:right}
{cmd:tcolor(}{it:string}{cmd:)}
{cmd:fcolor(}{it:string}{cmd:)}
{cmd:lcolor(}{it:string}{cmd:)}
{cmd:margin(}{it:string}{cmd:)}
{cmd:width(}{it:#}{cmd:)}
{cmd:height(}{it:#}{cmd:)}]

{p 4 4 2}
where {it:text} is one or more quoted strings containing the text to be displayed inside the node.

{hline}

{title:Description}

{pstd}
{cmd:consortdiagrami} defines a single node in a CONSORT-style flow diagram.  
Each call adds one row to the frame {cmd:consortDiagramFrame}, which stores:

{p 8 12 2}
• the node's unique identifier

{p 8 12 2}
• the parent node's identifier

{p 8 12 2}
• the text to display inside the node

{p 8 12 2}
• layout (standard, left-hanging, right-hanging)

{p 8 12 2}
• font and colour settings

{p 8 12 2}
• box width, height, and text margin

{pstd}
This command {it:does not} draw the diagram.  
After all nodes have been defined, use {cmd:consortdiagram_generate} to render the final flow diagram.

{pstd}
Exactly one node must be declared as the root using the {cmd:start} option.  
All other nodes must specify a parent using {cmd:parent()}.

{pstd}
Node identifiers supplied in {cmd:name()} must be unique.

{hline}

{title:Options}

{dlgtab:Required}

{phang}
{cmd:name(}{it:nodeid}{cmd:)}  
Specifies the unique identifier for this node.  
This identifier is used to link parent and child nodes.  
It is not displayed in the diagram.

{dlgtab:Parenting}

{phang}
{cmd:parent(}{it:parentid}{cmd:)}  
Specifies the identifier of the parent node.  
The parent must have been previously defined.

{phang}
{cmd:start}  
Declares this node as the root of the diagram.  
Exactly one node must specify {cmd:start}.  
A start node must not specify {cmd:parent()}.

{dlgtab:Layout}

{phang}
{cmd:standard}  
Children are arranged horizontally beneath the node (default).

{phang}
{cmd:left}  
Children are arranged vertically beneath the node and offset to the left  
(similar to "left hanging" in Microsoft Word hierarchy charts).

{phang}
{cmd:right}  
Children are arranged vertically beneath the node and offset to the right  
(similar to "right hanging" in Microsoft Word hierarchy charts).

{dlgtab:Appearance}

{phang}
{cmd:font(}{it:string}{cmd:)}  
Font family for the node text. Default is {cmd:Arial}.

{phang}
{cmd:tcolor(}{it:string}{cmd:)}  
Text colour. Default is {cmd:black}.

{phang}
{cmd:fcolor(}{it:string}{cmd:)}  
Fill colour for the node. Default is {cmd:none}.

{phang}
{cmd:lcolor(}{it:string}{cmd:)}  
Border line colour. Default is {cmd:black}.

{phang}
{cmd:margin(}{it:string}{cmd:)}  
Margin between the text and the border of the node box.  
Default is {cmd:zero}.

{dlgtab:Dimensions}

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
{cmd:consortdiagrami} creates (if necessary) and appends to the frame:

{p 8 12 2}
{cmd:consortDiagramFrame}

{pstd}
This frame contains one row per node and is used by  
{cmd:consortdiagram_generate} to construct the final diagram.

{hline}

{title:Example}

{pstd}
The following example defines a series of nodes for a CONSORT-style flow diagram:

{cmd}
        capture frame drop consortDiagramFrame
	
        consortdiagrami "Total patients n=1000",  name(start) start font("stSerif")
	
        consortdiagrami "Met ACR/EULAR Criteria n=950",  name(acr_eular) parent(start) font("Helvetica") 
	
        consortdiagrami "Placebo n=500",  name(placebo) parent(acr_eular) 
	
        consortdiagrami "Treatment n=450",  name(treatment) parent(acr_eular) 
	
        consortdiagrami "Male n=100",  name(placebo_male) parent(placebo) left
	
        consortdiagrami "Limited SSc n=75",  name(placebo_male_lim) parent(placebo_male)
	
        consortdiagrami "Diffuse SSc n=25",  name(placebo_male_dif) parent(placebo_male)
	
        consortdiagrami "Female n=400",  name(placebo_female) parent(placebo) right
	
        consortdiagrami "Limited SSc n=350",  name(placebo_male_lim) parent(placebo_female)
	
        consortdiagrami "Diffuse SSc n=50",  name(placebo_male_dif) parent(placebo_female)
	
        consortdiagrami "Male n=52",  name(treatment_male) parent(treatment) left
	
        consortdiagrami "Limited SSc n=45",  name(treatment_male_lim) parent(treatment_male)
	
        consortdiagrami "Diffuse SSc n=7",  name(treatment_male_dif) parent(treatment_male)
	
        consortdiagrami "Female n=398",  name(treatment_female) parent(treatment) right
	
        consortdiagrami "Limited SSc n=340",  name(treatment_male_lim) parent(treatment_female)
	
        consortdiagrami "Diffuse SSc n=58",  name(treatment_male_dif) parent(treatment_female)
	
        consortdiagram_generate
{txt}

{hline}

{title:Stored results}

{pstd}
{cmd:consortdiagrami} stores no results in {cmd:r()} or {cmd:e()}.  
All information is written to the frame {cmd:consortDiagramFrame}.

{hline}

{title:See also}

{pstd}
{help consortdiagram_suite} — Information on the suite of commands
{p_end}
{pstd}
{help consortdiagram} — Automatically define individual nodes from a varlist
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

