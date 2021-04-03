set FIRMS;            		# includes all firms
set TFIRMS;			# defines thermal only firms
set THERMLINE;          	# indexes multiple thermal outputs
param BT> 0;			# timestamp for first hour
param Tdata integer > 0; 	#Max number of hours
param ST integer <= 1000;	# starting hour
param T integer <= 1000;           # number of time periods
param BOOT_RUN <= 100;		#  individual bootstrap iteration
param firmtype {FIRMS};   	# fringe,cournot

set HFIRMS := FIRMS diff TFIRMS;
set COURNOT := {i in FIRMS: firmtype[i] > 1};
set FRINGE := FIRMS diff COURNOT;
set HCOURNOT := {i in HFIRMS: firmtype[i] > 1};
set HFRINGE := HFIRMS diff COURNOT;

param k  {THERMLINE, FIRMS};         # Intercept of marginal cost of multiple thermal 
param mc {THERMLINE, FIRMS};         # Slope of marginal cost of multiple thermal production
param maxtherm {THERMLINE, FIRMS};
param qmr {1..Tdata,FIRMS}; 	  # must-run quantity by firm - not included in maxtherm
param a_hat {1..Tdata};		# actual total demand
param b {1..100};           # slope of demand curve
param contractpct{FIRMS};  # percentage of demand intercept that is under contract
param p_act {1..Tdata};			# actual market price
param q_act {1..Tdata};			# actual residual market quantity

param perturb {i in COURNOT};		#param used to perterb contract position

var totcap {i in FIRMS};

var a {1..Tdata};           # intercept of demand curve
var q {i in FIRMS, t in ST..T};
var qth {i in FIRMS, s in THERMLINE, t in ST..T};
var qc {i in FIRMS, t in ST..T};
var psi{i in FIRMS, s in THERMLINE, t in ST..T};      # Dual on thermal capacity
var p {t in ST..T};
var TC {i in FIRMS, t in ST..T};

subject to I2 {i in FIRMS, t in ST..T}:
	q[i,t] = qmr[t,i] + sum {s in THERMLINE} qth[i,s,t];

subject to I1 {i in COURNOT, t in ST..T}:
	qc[i,t] = contractpct[i]*a_hat[t] + perturb[i]*totcap[i];

subject to I3 {t in ST..T}:
	a[t] = q_act[t] + b[BOOT_RUN]*log(p_act[t]);

subject to I4 {t in ST..T}:
	p[t] = exp((a[t]- (sum {j in FIRMS} q[j,t]))/b[BOOT_RUN]);

subject to I5 {i in FIRMS, t in ST..T}:
	TC[i,t] = sum{s in THERMLINE} (qth[i,s,t]*k[s,i] + .5*mc[s,i]*qth[i,s,t]^2);

subject to I6 {i in FIRMS}:
	totcap[i] = sum {s in THERMLINE} maxtherm[s,i];

	
subject to EQ1 {i in COURNOT, s in THERMLINE, t in ST..T}:
    qth[i,s,t] >= 0 complements
   (1-((q[i,t]-qc[i,t])/b[BOOT_RUN]))*exp((a[t]- (sum {j in FIRMS} q[j,t]))/b[BOOT_RUN]) 
    - k[s,i] - mc[s,i]*qth[i,s,t] - psi[i,s,t] <= 0; 


subject to EQ3 {i in FRINGE, s in THERMLINE, t in ST..T}:
    qth[i,s,t] >= 0 complements
   exp((a[t]- (sum {j in FIRMS} q[j,t]))/b[BOOT_RUN]) 
    - k[s,i] - mc[s,i]*qth[i,s,t] - psi[i,s,t] <= 0; 

subject to g1 {i in FIRMS, s in THERMLINE, t in ST..T}:	
   psi[i,s,t] >= 0 complements
   qth[i,s,t] <= maxtherm[s,i];




    
