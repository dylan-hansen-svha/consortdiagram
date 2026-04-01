{smcl}
{* *! version 1.0.0 25mar2026}{...}
{cmd:help consortdiagram_generate}
{hline}

{title:Title}

{phang}
{cmd:consortdiagram_generate} — Generate a CONSORT-style flow diagram from stored node definitions

{hline}

{title:Syntax}

{p 8 17 2}
{cmd:consortdiagram_generate}
[{cmd:,}
{cmd:font(}{it:string}{cmd:)}
{cmd:vba}
{cmd:background(}{it:string}{cmd:)}]

{hline}

{title:Description}

{pstd}
{cmd:consortdiagram_generate} produces a CONSORT-style flow diagram using the node
definitions stored in the frame {cmd:consortDiagramFrame}. 
This frame must have been created previously by either {cmd:consortdiagram} or
{cmd:consortdiagrami}. 

{pstd}
The command computes:

{p 8 12 2}
• traversal order of nodes (depth-first)

{p 8 12 2}
• parent–child relationships

{p 8 12 2}
• row and column positions for each node

{p 8 12 2}
• left-hanging and right-hanging offsets

{p 8 12 2}
• automatic text wrapping and SMCL formatting

{p 8 12 2}
• box sizes based on text content

{p 8 12 2}
• connector line coordinates (vertical, horizontal, and hanging)

{pstd}
The final diagram is drawn using a {cmd:twoway} graph with:

{p 8 12 2}
• {cmd:text()} elements for node boxes 

{p 8 12 2} 
• {cmd:pci} segments for connector lines  

{pstd}
Optionally, the command can export a Microsoft Word SmartArt-compatible VBA script
that recreates the diagram structure in Microsoft Word.

{hline}

{title:Workflow}

{pstd}
A complete workflow consists of:

{p 8 12 2}
1. Define nodes using {cmd:consortdiagram} (automatic)  
   {it:or} {cmd:consortdiagrami} (manual)

{p 8 12 2}
2. Then run {cmd:consortdiagram_generate} to draw the diagram

{pstd}
If {cmd:consortDiagramFrame} does not exist, the command will fail. 
This frame is always created by {cmd:consortdiagram} or {cmd:consortdiagrami}.

{hline}

{title:Options}

{dlgtab:Appearance}

{phang}
{cmd:font(}{it:string}{cmd:)}  
Overrides the font for all nodes in the diagram, regardless of what was stored
in the frame.

{phang}
{cmd:background(}{it:string}{cmd:)}  
Sets the background colour of the diagram by applying  
{cmd:plotregion(fcolor())} to the graph.

{dlgtab:Export}

{phang}
{cmd:vba}  
Exports a Microsoft word SmartArt-compatible VBA script to {cmd:vbacode.txt}. 
The script creates a Microsoft Word SmartArt organisational chart. 
This option does not draw a graph in Stata; it only writes the VBA file.

{hline}

{title:Details}

{pstd}
{cmd:consortdiagram_generate} performs a depth-first traversal of the node tree
to determine the order in which nodes should appear.  
It then computes:

{p 8 12 2}
• {it:row positions} based on traversal depth  

{p 8 12 2}
• {it:column positions} based on sibling structure  

{p 8 12 2}
• {it:left/right offsets} for hanging layouts  

{p 8 12 2}
• {it:box height} based on automatic text wrapping 

{p 8 12 2} 
• {it:connector line coordinates} for parent–child links

{pstd}
Text wrapping is implemented internally using SMCL font tags and word-length
tracking.  
Wrapping works best when node width and height are left at their defaults.

{pstd}
The diagram is rendered using a single {cmd:twoway} command combining:

{p 8 12 2}
• node as text boxes  

{p 8 12 2}
• vertical connectors using PCI 

{p 8 12 2}
• horizontal connectors using PCI  

{p 8 12 2}
• hanging connectors

{hline}

{title:Limitations}

{pstd}
• Automatic text wrapping is implemented, but works best when node width and
height are left at their defaults. 
Changing width or height may cause misalignment.

{pstd}
• Only rectangular boxes are supported.

{pstd}
• Connector lines are straight segments; arrows are not drawn.

{pstd}
• Altering the overall graph size (xsize/ysize) may change spacing and alignment.

{pstd}
• The command requires Stata 17 or later due to the use of frames.

{hline}

{title:Examples}

{pstd}
{bf:Example 1: Using consortdiagram (automatic node generation)}

{cmd}
        sysuse nlsw88.dta, clear

        gen all = 1
	
        label variable all "All data"
	
        label define lbl 1 ""
	
        label value all lbl

        consortdiagram all race married collgrad, right(married) font("Times New Roman")

        consortdiagram_generate
{txt}

{pstd}
{bf:Example 2: Using consortdiagrami (manual node definition)}

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
{cmd:consortdiagram_generate} stores no results in {cmd:r()} or {cmd:e()}.  
All output is graphical (or written to {cmd:vbacode.txt} when {cmd:vba} is used).

{hline}

{title:See also}

{pstd}
{help consortdiagram_suite} — Information on the suite of commands
{p_end}
{pstd}
{help consortdiagram} — Automatically generate node definitions  
{p_end}
{pstd}
{help consortdiagrami} — Manually define individual nodes
{p_end}

{hline}

{title:Author}

{pstd}
Dylan Hansen  
St Vincent's hospital Melbourne, Australia  
{browse "mailto:dylan.hansen@svha.org.au":dylan.hansen@svha.org.au}

{hline}
