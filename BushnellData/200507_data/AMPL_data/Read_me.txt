Description of AMPL model and inputs

The Cournot equilibria for each market is calculated using a model written in AMPL. Information on AMPL can be found at http://www.ampl.com/.  AMPL takes as inputs a model file, here denoted by the suffix .mod, and a data file,
here denoted with the suffix .txt.

The simulation inputs are organized by market, cal, ne, and pjm.  Each market has a .mod file representing the model and 4 .txt files, one each for each of the months simulated.

In each folder, the .txt files contain the parameter values utilized by the .mod file when solving for an equilibrium.  These parameters are described below.

#### Parameter and variable definitions in .mod files

set FIRMS;            		# indexes firms in the simulation
set TFIRMS;			# defines thermal only firms
set THERMLINE;       		# indexes the segments of the piecewise linear cost curve for each firm

The following parameters are used to index time (hours) and allow
flexibility in the number (and identity) of hours simulated

param BT> 0;			# timestamp for first hour
param Tdata integer > 0; 	# Max number of hours
param ST integer <= 1000;	# starting hour
param T integer <= 1000;           # number of time periods
param BOOT_RUN <= 100;		#  individual bootstrap iteration

The following parameters are used to define firm level characteristics

param firmtype    	# fringe if < 2, Cournot if 2

param k          	 # Intercept of marginal cost by cost segment

param mc         	# Slope of marginal cost by cost segment
param maxtherm 		# Maximum capacity by firm and cost segment
param qmr 	 	 # must-run quantity by firm - not included in maxtherm

param a_hat 	# actual total demand
param b           # slope of demand curve
param contractpct  # percentage of actual demand that is under vertical obligation
param p_act 	# actual hourly market price
param q_act 		# actual hourly residual market quantity
param perturb 		# param used to perterb contract position


The following variables are calculated by the simulation

var a         	 # hourly intercept of demand curve
var q 		# Firm level hourly TOTAL quantity
var qth 	 #Firm level hourly quantity by cost segement
var qc 		#Firm level hourly vertical commitment
var psi		     # Dual on thermal capacity by segment and hour
var p 				# market price
var TC		# Hourly Total production cost by Firm

#### data values in the .txt files

Each .txt file contains the specific parameter values described above.

Ampl can read data values in a vector or matrix format.

For example, simple parameters are defined in a single line, such as

param   firmtype :=        AES 2 DUKE 2 DYN 2 MIR  2 REL 2 FR  1     ;

Other multi-dimensional parameters are defined in matrix format, such as

param   k :         AES     DUKE    DYN     MIR     REL     FR   :=
                        	
1	26.2763	26.5773	24.7009	26.8462	24.5551	27.7583
2	26.7315	30.1448	26.4688	27.0669	25.6456	31.8488
3	27.2973	34.7421	28.7443	28.3748	26.7952	34.2444
4	29.3533	47.8607	31.1763	29.0793	27.2972	35.0448
5	30.7142	51.1298	53.8800	35.0739	34.2566	38.9966
;

In some cases, such as production costs, values change monthly, and
a new .txt file is used for each month.   In other cases, such as
market quantity, values change hourly.

#### Solution commands in the .run files

The .run files contain batch solution commands for solving multiple 
problems.  The program can be set to iterate through individual or 
groups of multiple hours.  In the case of the provided .run files, the
batch program also iterates through multiple perterbations of ther vertical
position (contractpct) of each firm.

The .run file also specifies the simulation output through use of the
ampl "display" command.


The remainder of the .mod file contains the equilibrium conditions to be
solved for.  The specific conditions can depend upon the market - for example
the California model contains no contractpct component.





price-caps - in order to represent price caps in the eastern markets, equilibrium prices were truncated at 1000 in both PJM and New England in the results.  In most cases, the equilibrium price was allowed to rise above the capped level in the simulation, but was reset to the capped level for reporting results.  

For purposes of calculating firm production quantities, more detail about an equilibrium at the price cap was needed.  For the case of PJM with no vertical arrangements and  the log-linear residual demand specification, a large fringe production capacity with marginal cost of 1000.01 was added to the supply data.  The presence of this fictional fringe capacity effectively created a horizontal residual demand curve at the capped price. Simulated equilibrium prices for this case never rise above 1000.01.


