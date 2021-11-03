****************************************************************************************
*Title: Control Variables in Interactive Models
*Purpose: To illustrate the use of controls in interacted models using simulated data. This code produces one iteration of the simulation in DMSSW (2021)
*Date: October 27 2021
*Software: Stata
*Dependencies: none
*Authors: Ed deHaan and Quinn Swanquist
****************************************************************************************
	
*** Simulation 1: ERC setting

	clear all
	set seed 42 /// set seed for reproducibility

*** I.a: the data generating process (DGP)

	* set the dataset size (Step 1) (note - set sample size to 1M to improve stability of single iteration)
	set obs 1000000

	* generate an unexpected earnings (ue) variable as a random draw from a normal distribution with a mean of 0 and a standard deviation of 2 (Step 2)
	gen ue = rnormal(0,2)
		
	* generate a company size (size) variable as a random draw from a normal distribution with a mean of 8 and a standard deviation of 2 (Step 3)
	gen size = rnormal(8,2)			
			
	* create an interaction term between ue and size 
	gen ue_size = ue * size
			
	* calculate cumulative abnormal returns (Step 4)
	gen car = (10 * ue) + (0 * size) + (10 * ue_size) + rnormal(0, 100)
						
	* generate a Wall Street Journal coverage variable (wsj) which equals 1 for firms above the median for size and 0 otherwise (Step 5)
	egen wsj = cut(size), group(2)

	* create an interaction term between ue and wsj 
	gen ue_wsj = ue * wsj

*** I.b: analysis	
	* I.b.1) simple ERC model 
	local indvars = "ue" /*specify independent variables*/
	reg car ue /*estimate regression*/

	* I.b.2) adding size as an additional variable
	local indvars = "ue size"
	reg car `indvars'
				
	* I.b.3) adding size interacted with ue
	local indvars = "ue size ue_size"
	reg car `indvars'

	* I.b.4) respecification with demeaned size
	egen size_mean = mean(size)
	replace size = size - size_mean
	local indvars = "ue size"
	reg car `indvars'
				
	* I.b.5) respecification adding demeaned size interaction with ue
	replace ue_size = size * ue
	local indvars = "ue size ue_size"
	reg car `indvars'
			
	* I.b.6) simple wsj ERC model
	local indvars = "ue wsj ue_wsj"
	reg car `indvars'

	* I.b.7) adding size
	local indvars = "ue wsj ue_wsj size"
	reg car `indvars'
				
	* I.b.8) adding size interacted with ue
	local indvars = "ue wsj ue_wsj size ue_size"
	reg car `indvars'

*** Simulation 2: Forecast and liquidity setting
	
	clear all
	set seed 42 /// set seed for reproducibility
	
*** II.a: the data generating process (DGP)

	* set the dataset size (Step 1) (note - set sample size to 1M to improve stability of single iteration)
	set obs 1000000
					
	* generate a firm size (size) variable as a random draw from a normal distribution with a mean of 0 and a standard deviation of 2 (Step 2)
	gen size = rnormal(0, 2)	
			
	* generate a management forecast variable (forecast) which equals 1 for firms above the median for size and 0 otherwise
	egen forecast = cut(size), group(2)

	* generate an algorithmic trading ban variable (algo_ban) as a binary variable equal to 1 randomly assigned to half of the observations, and 0 otherwise (Step 4)
	gen algo_ban = _n > (_N / 2)
			
	* create interaction terms 
	gen forecast_algo_ban = forecast * algo_ban
	gen size_algo_ban = size * algo_ban

	* calculate liquidity (Step 5)
	gen liquidity = (0.5 * forecast) + (0.4 * size) + (-0.5 * algo_ban) + (0 * forecast_algo_ban) + (0.05 * size_algo_ban) + rnormal(0, 1)
			
*** II.b: analysis	
	* II.b.1) univariate forecast model 
	local indvars = "forecast" 
	reg liquidity `indvars' 

	* II.b.2) adding a control for size
	local indvars = "forecast size"
	reg liquidity `indvars'
				
	* II.b.3) adding the interaction of forecast and algo_ban
	local indvars = "forecast size algo_ban forecast_algo_ban"
	reg liquidity `indvars'
				
	* II.b.4) adding the interaction of size and algo_ban
	local indvars = "forecast size algo_ban forecast_algo_ban size_algo_ban"
	reg liquidity `indvars'

	* II.b.5) algo_ban = 0 partition 
	local indvars = "forecast size"
	reg liquidity `indvars' if algo_ban == 0
	est sto one

	* II.b.6) algo_ban = 1 partition 
	local indvars = "forecast size"
	reg liquidity `indvars' if algo_ban == 1
	est sto two
			
	suest one two
	test [two_mean]forecast = [one_mean]forecast
	test [two_mean]size = [one_mean]size
