Documentation for Data Archive for "Measuring Market Inefficiencies in California's Restructured Wholesale Electricity Market" by Severin Borenstein, James Bushnell and Frank Wolak, American Economic Review, 92(December 2002).

This data archive contains three files.  From these files, the results of the paper can be reproduced if one purchases some proprietary data (which we are not permitted to redistribute, but which are available for a reasonable cost).  The proprietary data are daily natural gas prices and similar (though less detailed) data are available free of charge, as discussed below.

We have tried to make this archive user friendly, but to understand the data, you must read both this description and the AER paper and appendix carefully.  Please do so before contacting us with questions.  


1.BBW_Archive.xls
Type: Microsoft Excel 2000 file (version 9.0.2720). Contains 5 sheets:

   Gen Unit Info -- contains data on the 92 instate generating units.  "Fuel Type" tells what type of fuel the units use.  For natural gas plants, it tells which area the plant is in for purposes of determining the local spot price of natural gas.
   
   NOx Prices -- the prices we used for one pound of NOx emissions by month (calculation explained in paper).
   
   NOx Emissions Rates -- the plant NOx emissions rates for those plants located in the SCAQMD pollution control area.  These change by year in some cases.
   
   Oil & Jet Fuel Costs -- monthly costs of these fuels that we used
   
   Nat Gas Costs -- The natural gas prices that we used were purchased from NGI,              http://intelligencepress.com/, and differ by day and by location within California.  Average data by month can be obtained free of charge at  http://www.eia.doe.gov/oil_gas/natural_gas/info_glance/sector.html .  In addition to the gas prices, there is a distribution cost (which is zero for Coolwater).  The distribution costs are in this sheet, but the gas prices have been removed.
   

2.BBW_Archive.dta
Type: Intercooled Stata 7.0 for Windows 95/98/NT.  Contains 21 variables:

   date, year, month, day, hour
    
   pxp($/MWh) -- PX unconstrained market clearing price
   
   MC ($/MWh)-- Calculated MC of marginal unit, ie, competitive price (average of 100 Monte Carlo draws).
   
   ISO_LOAD(MWh/hr)-- Total quantity produced within ISO and imported into ISO
   
   Q_MT(MWh/hr) -- Must-take quantity
   
   deltaTC($/hr) -- described in text (=(ISO_LOAD-Q_MT)*(pxp-MC))
   
   TC($/hr) -- described in text (=(ISO_LOAD-Q_MT)*pxp)
   
   Qinstate(MWh/hr)-- Total quantity produced by 92 observed fossil fuel plants
   
   TPCact($/hr) -- Total "actual" production costs of 92 observed fossil fuel plants producing Qinstate, calculation described in text.
   
   TPCmin($/hr) -- Total production costs if Qinstate production were allocated among 92 plants in cost-minimizing way, calculation described in text.
   
   impmin($/hr)-- In figure 2 of the paper, impmin is the area between q_r and q_r^* up to the MCcomp curve.
   
   impavoid($/hr) -- In figure 2 of the paper, impavoid is the area between q_r and q_r^* up to the Residual Demand curve.  The triangle that is the difference between impavoid and impmin is the production efficiency loss from using imports to fulfill this quantity instead of the producer that would provide it in a competitive market (assuming imports are always provided competitively, as explained in the text.)
   
   Q_imp(MWh/hr) -- actual imports into ISO system
   
   Q_regup(MWh/hr)-- capacity held out by ISO for upward regulation, described in text
   
   Q_impcom(MWh/hr) -- counterfactual import that would have occured if instate producers had behaved perfectly competitively.
   
   TPCPC($/hr)-- TPCmin+impmin+0.5*(MC+0)*Q_impcom, as explained in paper
   
   TPCMP($/hr) -- TPCact+impavoid+0.5*(MC+0)*Q_impcom, as explained in paper
   

BBW_Archive.dat
Type: Flat ASCII, comma delimited file, 1,090,162 records
Layout: Year, Month, Day, Hour, Price($/MWh), Quantity(MWh/hr)

This file gives the residual demand to be met by the 92 instate plants, as described in equation (4) and the surrounding text.  It is a step function for each hour.