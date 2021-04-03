set FIRMS;            		# includes all firms
set TFIRMS;			# defines thermal only firms
set THERMLINE;         		 # indexes multiple thermal outputs
param Tdata integer > 0;	# max hours
param T integer <= Tdata;            # number of time periods
param BT >0;			# timestamp
param ST integer <= Tdata;      #start time
param BOOT_RUN <= 100;		#  individual bootstrap iteration
param firmtype {FIRMS};  	 # fringe,cournot

set HFIRMS := FIRMS diff TFIRMS;
set COURNOT := {i in FIRMS: firmtype[i] > 1};
set FRINGE := FIRMS diff COURNOT;
set HCOURNOT := {i in HFIRMS: firmtype[i] > 1};
set HFRINGE := HFIRMS diff COURNOT;

param k  {THERMLINE, FIRMS};         # Intercept of marginal cost of multiple thermal 
param mc {THERMLINE, FIRMS};         # Slope of marginal cost of multiple thermal production
param maxtherm {THERMLINE, FIRMS};
#param qmr {1..Tdata,FIRMS}; 	  # must-run quantity by firm - not included in maxtherm
param b {1..100};           # slope of demand curve
#param contractpct{FIRMS};  # percentage of demand intercept that is under contract
param p_act {1..Tdata};			# actual market price
param q_act {1..Tdata};			# actual residual market demand at p_act			

var a {1..Tdata};           # intercept of demand curve
var q {i in FIRMS, t in 1..T};
var qth {i in FIRMS, s in THERMLINE, t in 1..T};
#var qc {i in FIRMS, t in 1..T};
var psi{i in FIRMS, s in THERMLINE, t in 1..T};      # Dual on thermal capacity
var TC {i in FIRMS, t in 1..T};			# total production cost at time t
var p {t in 1..T};

subject to I2 {i in FIRMS, t in 1..T}:
	q[i,t] = sum {s in THERMLINE} qth[i,s,t];

subject to I3 {t in 1..T}:
	a[t] = q_act[t] + b[BOOT_RUN]*log(p_act[t]);

subject to I4 {i in FIRMS, t in 1..T}:
	TC[i,t] = sum{s in THERMLINE} (qth[i,s,t]*k[s,i] + .5*mc[s,i]*qth[i,s,t]^2);

subject to I1 {t in 1..T}:
	p[t] = exp((a[t]- (sum {j in FIRMS} q[j,t]))/b[BOOT_RUN]);

subject to EQ1 {i in COURNOT, s in THERMLINE, t in 1..T}:
    qth[i,s,t] >= 0 complements
   (1-(q[i,t])/b[BOOT_RUN])*exp((a[t]- (sum {j in FIRMS} q[j,t]))/b[BOOT_RUN]) 
    - k[s,i] - mc[s,i]*qth[i,s,t] - psi[i,s,t] <= 0; 


subject to EQ3 {i in FRINGE, s in THERMLINE, t in 1..T}:
    qth[i,s,t] >= 0 complements
   exp((a[t]- (sum {j in FIRMS} q[j,t]))/b[BOOT_RUN]) 
    - k[s,i] - mc[s,i]*qth[i,s,t] - psi[i,s,t] <= 0; 

subject to g1 {i in FIRMS, s in THERMLINE, t in 1..T}:	
   psi[i,s,t] >= 0 complements
   qth[i,s,t] <= maxtherm[s,i];




    
