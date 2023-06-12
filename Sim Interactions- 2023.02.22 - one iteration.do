****************************************************************************************
*Title: Control Variables in Interactive Models
*Purpose: To illustrate the use of controls in interacted models using simulated data. This code produces one iteration of the simulation in DMSSW (2021)
*Date: January 30, 2023
*Software: Stata
*Dependencies: none
*Authors: Ed deHaan and Quinn Swanquist
****************************************************************************************
	
*** Simulation 1: ERC setting

	clear all
	set seed 42 /// set seed for reproducibility

*** I.a: the data generating process (DGP)

	* set the dataset size (Step 1) (note - set sample size to 1 million to improve stability of single iteration)
	set obs 1000000

	* generate an unexpected earnings (ue) variable as a random draw from a normal distribution with a mean of 0 and a standard deviation of 2 (Step 2)
	gen ue = rnormal(0,2)
		
	* generate a company size (size) variable as a random draw from a normal distribution with a mean of 8 and a standard deviation of 2 (Step 3)
	gen size = rnormal(8,2)
			
	* create an interaction term between ue and size 
	gen ue_size = ue * size
			
	* generate cumulative abnormal returns (Step 4)
	gen car = (10 * ue) + (0 * size) + (10 * ue_size) + rnormal(0, 100)
						
	* generate a Wall Street Journal coverage variable (wsj) which equals 1 for firms above the median for size and 0 otherwise (Step 5)
	egen wsj = cut(size), group(2)

	* create an interaction term between ue and wsj 
	gen ue_wsj = ue * wsj

*** I.b: analysis	
	* I.b.1) simple ERC model (descriptions following each line are only shown for the first iteration but the process is repeated below)
	local indvars = "ue" /*specify independent variables*/
	reg car `indvars' /*estimate regression*/

	* I.b.2) adding size
	local indvars = "ue size"
	reg car `indvars'

	* I.b.3) adding size interacted with ue
	local indvars = "ue size ue_size"
	reg car `indvars'
				
	* I.b.4) respecification adding demeaned size interaction with ue
	egen size_mean = mean(size)
	replace size = size - size_mean
	replace ue_size = size * ue
	local indvars = "ue size ue_size"
	reg car `indvars'
			
	* I.b.5) simple wsj ERC model
	local indvars = "ue wsj ue_wsj"
	reg car `indvars'

	* I.b.6) adding size
	local indvars = "ue size wsj ue_wsj"
	reg car `indvars'
				
	* I.b.7) adding size interacted with ue
	local indvars = "ue size ue_size wsj ue_wsj"
	reg car `indvars'