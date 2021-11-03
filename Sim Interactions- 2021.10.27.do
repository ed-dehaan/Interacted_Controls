****************************************************************************************
*Title: Control Variables in Interactive Models
*Purpose: To illustrate the use of controls in interacted models using simulated data. This code produces all of the results in DMSSW (2021)
*Date: October 27 2021
*Software: Stata (output in DMSSW 2021 was generated using version 17.0)
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

			* I.b.2) adding size as an additional variable
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

			* I.b.4) respecification with demeaned size
			egen size_mean = mean(size)
			replace size = size - size_mean
			local indvars = "ue size"
			reg car `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'4 = _b[`v']
					scalar t_`v'4 = _b[`v'] / _se[`v']
				}
				scalar r4 = e(r2_a)
				scalar n4 = e(N)
				
			* I.b.5) respecification adding demeaned size interaction with ue
			replace ue_size = size * ue
			local indvars = "ue size ue_size"
			reg car `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'5 = _b[`v']
					scalar t_`v'5 = _b[`v'] / _se[`v']
				}
				scalar r5 = e(r2_a)
				scalar n5 = e(N)
	
			* I.b.6) simple wsj ERC model
			local indvars = "ue wsj ue_wsj"
			reg car `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'6 = _b[`v']
					scalar t_`v'6 = _b[`v'] / _se[`v']
				}
				scalar r6 = e(r2_a)
				scalar n6 = e(N)

			* I.b.7) adding size
			local indvars = "ue wsj ue_wsj size"
			reg car `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'7 = _b[`v']
					scalar t_`v'7 = _b[`v'] / _se[`v']
				}
				scalar r7 = e(r2_a)
				scalar n7 = e(N)
				
			* I.b.8) adding size interacted with ue
			local indvars = "ue wsj ue_wsj size ue_size"
			reg car `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'8 = _b[`v']
					scalar t_`v'8 = _b[`v'] / _se[`v']
				}
				scalar r8 = e(r2_a)
				scalar n8 = e(N)
				
		end
		
	*** 2) run the simulation program (sim1) above with 1000 repetitions 
		simulate  	b_ue1=b_ue1 t_ue1=t_ue1 /// Estimates from I.b.1
					b_ue2=b_ue2 t_ue2=t_ue2 b_size2=b_size2 t_size2=t_size2 /// Estimates from I.b.2
					b_ue3=b_ue3 t_ue3=t_ue3 b_size3=b_size3 t_size3=t_size3 b_ue_size3=b_ue_size3 t_ue_size3=t_ue_size3 /// Estimates from I.b.3
					b_ue4=b_ue4 t_ue4=t_ue4 b_size4=b_size4 t_size4=t_size4 /// Estimates from I.b.4
					b_ue5=b_ue5 t_ue5=t_ue5 b_size5=b_size5 t_size5=t_size5 b_ue_size5=b_ue_size5 t_ue_size5=t_ue_size5 /// Estimates from I.b.5					
					b_ue6=b_ue6 t_ue6=t_ue6 b_wsj6=b_wsj6 t_wsj6=t_wsj6 b_ue_wsj6=b_ue_wsj6 t_ue_wsj6=t_ue_wsj6 /// Estimates from I.b.6
					b_ue7=b_ue7 t_ue7=t_ue7 b_wsj7=b_wsj7 t_wsj7=t_wsj7 b_ue_wsj7=b_ue_wsj7 t_ue_wsj7=t_ue_wsj7 b_size7=b_size7 t_size7=t_size7 /// Estimates from I.b.7
					b_ue8=b_ue8 t_ue8=t_ue8 b_wsj8=b_wsj8 t_wsj8=t_wsj8 b_ue_wsj8=b_ue_wsj8 t_ue_wsj8=t_ue_wsj8 b_size8=b_size8 t_size8=t_size8 b_ue_size8=b_ue_size8 t_ue_size8=t_ue_size8 /// Estimates from I.b.8
					r1=r1 r2=r2 r3=r3 r4=r4 r5=r5 r6=r6 r7=r7 r8=r8 /// R-squared
					n1=n1 n2=n2 n3=n3 n4=n4 n5=n5 n6=n6 n7=n7 n8=n8 /// Observations
					, reps(1000): sim1

		qui: estpost summarize
		esttab, cells("count mean min max")
	
*** Simulation 2: Forecast and liquidity setting
	
	clear all
	set seed 42 ///set seed for reproducibility
	
	*** II.) create the simulation program (sim2)
		program define sim2

			drop _all
		
		*** II.a: the data generating process (DGP)

			* set the dataset size (Step 1)
			set obs 10000
					
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
			* II.b.1) univariate forecast model (descriptions following each line are only shown for the first iteration but the process is repeated below)
			local indvars = "forecast" 
			reg liquidity `indvars' 
				foreach v of varlist `indvars' {
					scalar b_`v'1 = _b[`v']
					scalar t_`v'1 = _b[`v'] / _se[`v']
				} 
				scalar r1 = e(r2_a)
				scalar n1 = e(N) 

			* II.b.2) adding a control for size
			local indvars = "forecast size"
			reg liquidity `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'2 = _b[`v']
					scalar t_`v'2 = _b[`v'] / _se[`v']
				}
				scalar r2 = e(r2_a)	
				scalar n2 = e(N)
				
			* II.b.3) adding the interaction of forecast and algo_ban
			local indvars = "forecast size algo_ban forecast_algo_ban"
			reg liquidity `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'3 = _b[`v']
					scalar t_`v'3 = _b[`v'] / _se[`v']
				}
				scalar r3 = e(r2_a)	
				scalar n3 = e(N)
				
			* II.b.4) adding the interaction of size and algo_ban
			local indvars = "forecast size algo_ban forecast_algo_ban size_algo_ban"
			reg liquidity `indvars'
				foreach v of varlist `indvars' {
					scalar b_`v'4 = _b[`v']
					scalar t_`v'4 = _b[`v'] / _se[`v']
				}
				scalar r4 = e(r2_a)
				scalar n4 = e(N)		
	
			* II.b.5) algo_ban = 0 partition 
			local indvars = "forecast size"
			reg liquidity `indvars' if algo_ban == 0
			est sto one
				foreach v of varlist `indvars' {
					scalar b_`v'5 = _b[`v']
					scalar t_`v'5 = _b[`v'] / _se[`v']
				}
				scalar r5 = e(r2_a)
				scalar n5 = e(N)

			* II.b.6) algo_ban = 1 partition 
			local indvars = "forecast size"
			reg liquidity `indvars' if algo_ban == 1
			est sto two
				foreach v of varlist `indvars' {
					scalar b_`v'6 = _b[`v']
					scalar t_`v'6 = _b[`v'] / _se[`v']
				}
				scalar r6 = e(r2_a)
				scalar n6 = e(N)
			
			suest one two
			test [two_mean]forecast = [one_mean]forecast
			scalar diff_algo_ban = [two_mean]forecast - [one_mean]forecast
			scalar chi2_algo_ban = r(chi2)
			test [two_mean]size = [one_mean]size
			scalar diff_size = [two_mean]size - [one_mean]size
			scalar chi2_size = r(chi2) 

		end
		
	*** 2) run the simulation program (sim1) above with 1000 repetitions 
		simulate  	b_forecast1=b_forecast1 t_forecast1=t_forecast1 /// Estimates from II.b.1
					b_forecast2=b_forecast2 t_forecast2=t_forecast2 b_size2=b_size2 t_size2=t_size2 /// Estimates from II.b.2
					b_forecast3=b_forecast3 t_forecast3=t_forecast3 b_size3=b_size3 t_size3=t_size3 b_algo_ban3=b_algo_ban3 t_algo_ban3=t_algo_ban3 b_forecast_algo_ban3=b_forecast_algo_ban3 t_forecast_algo_ban3=t_forecast_algo_ban3 /// Estimates from II.b.3
					b_forecast4=b_forecast4 t_forecast4=t_forecast4 b_size4=b_size4 t_size4=t_size4 b_algo_ban4=b_algo_ban4 t_algo_ban4=t_algo_ban4 b_forecast_algo_ban4=b_forecast_algo_ban4 t_forecast_algo_ban4=t_forecast_algo_ban4 b_size_algo_ban4=b_size_algo_ban4 t_size_algo_ban4=t_size_algo_ban4 /// Estimates from II.b.4
					b_forecast5=b_forecast5 t_forecast5=t_forecast5 b_size5=b_size5 t_size5=t_size5  /// Estimates from II.b.5
					b_forecast6=b_forecast6 t_forecast6=t_forecast6 b_size6=b_size6 t_size6=t_size6  /// Estimates from II.b.6
					r1=r1 r2=r2 r3=r3 r4=r4 r5=r5 r6=r6 /// R-squared
					n1=n1 n2=n2 n3=n3 n4=n4 n5=n5 n6=n6 /// Observations
					diff_algo_ban=diff_algo_ban chi2_algo_ban=chi2_algo_ban diff_size=diff_size chi2_size=chi2_size /// Differences and chi2
					, reps(1000): sim2

		qui: estpost summarize
		esttab, cells("count mean min max")
