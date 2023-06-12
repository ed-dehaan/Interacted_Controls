****************************************************************************************
*Title: Control Variables in Interactive Models
*Purpose: To illustrate the use of controls in interacted models using simulated data. This code produces all of the results in DMSSW (2023)
*Date: February 22, 2023
*Software: Stata (output in DMSSW 2023 was generated using version 17.0)
*Dependencies: estout
*Authors: Ed deHaan and Quinn Swanquist
****************************************************************************************
	
*** Simulation 1: ERC setting

	clear all
	set seed 42 /// set seed for reproducibility
	
	*** I.) create the simulation program (sim1)
		program define sim1

			drop _all
		
		*** I.a: the data generating process (DGP)

			* set the dataset size (Step 1)
			set obs 10000

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
				foreach v of varlist `indvars' { /*loop to retain coefficients and tstats for independent variables*/
					scalar b_`v'1 = _b[`v']
					scalar t_`v'1 = _b[`v'] / _se[`v']
				} 
				scalar r1 = e(r2_a) /*retain adjusted r-squared*/
				scalar n1 = e(N) /*retain sample size*/

			* I.b.2) adding size
			local indvars = "ue size"
			reg car `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'2 = _b[`v']
					scalar t_`v'2 = _b[`v'] / _se[`v']
				}
				scalar r2 = e(r2_a)	
				scalar n2 = e(N)

			* I.b.3) adding size interacted with ue
			local indvars = "ue size ue_size"
			reg car `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'3 = _b[`v']
					scalar t_`v'3 = _b[`v'] / _se[`v']
				}
				scalar r3 = e(r2_a)
				scalar n3 = e(N)
				
			* I.b.4) respecification adding demeaned size interaction with ue
			egen size_mean = mean(size)
			replace size = size - size_mean
			replace ue_size = size * ue
			local indvars = "ue size ue_size"
			reg car `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'4 = _b[`v']
					scalar t_`v'4 = _b[`v'] / _se[`v']
				}
				scalar r4 = e(r2_a)
				scalar n4 = e(N)
	
			* I.b.5) simple wsj ERC model
			local indvars = "ue wsj ue_wsj"
			reg car `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'5 = _b[`v']
					scalar t_`v'5 = _b[`v'] / _se[`v']
				}
				scalar r5 = e(r2_a)
				scalar n5 = e(N)

			* I.b.6) adding size
			local indvars = "ue size wsj ue_wsj"
			reg car `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'6 = _b[`v']
					scalar t_`v'6 = _b[`v'] / _se[`v']
				}
				scalar r6 = e(r2_a)
				scalar n6 = e(N)
				
			* I.b.7) adding size interacted with ue
			local indvars = "ue size ue_size wsj ue_wsj"
			reg car `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'7 = _b[`v']
					scalar t_`v'7 = _b[`v'] / _se[`v']
				}
				scalar r7 = e(r2_a)
				scalar n7 = e(N)
				
		end
		
	*** 2) run the simulation program (sim1) above with 1000 repetitions 
		simulate  	b_ue1=b_ue1 t_ue1=t_ue1 /// Estimates from I.b.1
					b_ue2=b_ue2 t_ue2=t_ue2 b_size2=b_size2 t_size2=t_size2 /// Estimates from I.b.2
					b_ue3=b_ue3 t_ue3=t_ue3 b_size3=b_size3 t_size3=t_size3 b_ue_size3=b_ue_size3 t_ue_size3=t_ue_size3 /// Estimates from I.b.3
					b_ue4=b_ue4 t_ue4=t_ue4 b_size4=b_size4 t_size4=t_size4 b_ue_size4=b_ue_size4 t_ue_size4=t_ue_size4 /// Estimates from I.b.4					
					b_ue5=b_ue5 t_ue5=t_ue5 b_wsj5=b_wsj5 t_wsj5=t_wsj5 b_ue_wsj5=b_ue_wsj5 t_ue_wsj5=t_ue_wsj5 /// Estimates from I.b.5
					b_ue6=b_ue6 t_ue6=t_ue6 b_size6=b_size6 t_size6=t_size6 b_wsj6=b_wsj6 t_wsj6=t_wsj6 b_ue_wsj6=b_ue_wsj6 t_ue_wsj6=t_ue_wsj6 /// Estimates from I.b.6
					b_ue7=b_ue7 t_ue7=t_ue7 b_size7=b_size7 t_size7=t_size7 b_ue_size7=b_ue_size7 t_ue_size7=t_ue_size7 b_wsj7=b_wsj7 t_wsj7=t_wsj7 b_ue_wsj7=b_ue_wsj7 t_ue_wsj7=t_ue_wsj7 /// Estimates from I.b.7
					r1=r1 r2=r2 r3=r3 r4=r4 r5=r5 r6=r6 r7=r7 /// R-squared
					n1=n1 n2=n2 n3=n3 n4=n4 n5=n5 n6=n6 n7=n7 /// Observations
					, reps(1000): sim1

		qui: estpost summarize
		esttab, cells("count mean min max")