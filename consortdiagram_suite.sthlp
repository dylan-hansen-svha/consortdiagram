{smcl}
{* *! version 1.0.0 25mar2026}{...}
{cmd:help consortdiagram_suite}
{hline}

{title:Title}

{phang}
The {cmd:consortdiagram} suite — Tools for creating CONSORT-style flow diagrams in Stata

{hline}

{title:Description}

{pstd}
The {cmd:consortdiagram} suite provides a complete workflow for constructing
CONSORT-style flow diagrams in Stata.  
It supports both:

{p 8 12 2}
• {it:automatic} node generation from categorical variables, and  

{p 8 12 2}
• {it:manual} node specification for full user control.

{pstd}
All commands in the suite store node definitions in the frame
{cmd:consortDiagramFrame}, and the final diagram is produced using
{cmd:consortdiagram_generate}.

{pstd}
Stata 17 or later is required because the suite uses frames.

{hline}

{title:Commands in the suite}

{pstd}
The suite consists of three commands:

{dlgtab:Node creation}

{phang}
{help consortdiagram}  
Automatically generates node definitions from a varlist of categorical variables
using a depth-first search. 
Ideal for quickly producing flow diagrams from structured datasets.

{phang}
{help consortdiagrami}  
Manually defines a single node. 
Allows full control over node text, layout, and formatting. 
Useful for diagrams that do not map cleanly onto categorical variables.

{dlgtab:Diagram generation}

{phang}
{help consortdiagram_generate}  
Reads the node definitions stored in {cmd:consortDiagramFrame} and produces a
CONSORT-style flow diagram using a {cmd:twoway} graph. 
Optionally exports a SmartArt-compatible VBA script for Microsoft Word.

{hline}

{title:Workflow}

{pstd}
A typical workflow consists of:

{p 8 12 2}
1. Create node definitions using either:

{p 12 16 2}
• {cmd:consortdiagram} — automatic generation, or  

{p 12 16 2}
• {cmd:consortdiagrami} — manual specification

{p 8 12 2}
2. Then run {cmd:consortdiagram_generate} to draw the diagram.

{pstd}
Both node-creation commands write to the same frame:
{cmd:consortDiagramFrame}. 
This frame must exist before running {cmd:consortdiagram_generate}.

{hline}

{title:Examples}

{pstd}
{bf:Automatic node generation}

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
{bf:Manual node specification}

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

{title:Files created}

{pstd}
The suite creates or uses the following files:

{p 8 12 2}
• {cmd:consortDiagramFrame} — internal frame storing node definitions 

{p 8 12 2} 
• {cmd:vbacode.txt} — optional SmartArt VBA script (when {cmd:vba} is used)

{hline}

{title:See also}

{pstd}
{help consortdiagram} — Automatic node generation  
{p_end}
{pstd}
{help consortdiagrami} — Manual node definition  
{p_end}
{pstd}
{help consortdiagram_generate} — Render the flow diagram
{p_end}

{hline}

{title:Author}

{pstd}
Dylan Hansen  
St Vincent's hospital Melbourne, Australia  
{browse "mailto:dylan.hansen@svha.org.au":dylan.hansen@svha.org.au}

{hline}
