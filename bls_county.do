cd "C:\Users\marku\Desktop\bls_county"
*** Import County-Month data from BLS ***
import delimited la.data.county.txt , stringcols(1 3) clear

gen statefip = substr(series_id,1,2)
*gen fipscounty = real(substr(series_id,1,5))
gen fipscounty = substr(series_id,1,5)

gen var = substr(series_id,-1,1)
replace var = "lf" if var=="6"
replace var = "emp" if var=="5"
replace var = "unemp" if var=="4"
replace var = "ur" if var=="3"

drop series_id footnote_
reshape wide value , i(year period fipscounty statefip) j(var) string

foreach var in valueemp valuelf valueunemp valueur {
	gen _`var' = real(`var')
	drop `var'
}	
ren (_valueemp _valuelf _valueunemp _valueur ) (emp elf unemp ur )

* Create date variables for merging *
gen temp1 = real(subinstr(period,"M","",.))
gen mdate = ym(year,temp1)
gen mdate_str = string(ym(year,temp1))
*format mdate %tm
gen q = qofd(dofm(mdate))
format q %tq
gen qdate_str = string(qofd(dofm(mdate)))

preserve 
drop if period!="M13"
drop period temp1 mdate qdate
save bls_la_county_year , replace
restore

drop if period=="M13"
save bls_la_county_month , replace
*** Now collapse to quarterly data 
collapse emp elf unemp ur , by(fipscounty q)
save bls_la_county_quarter , replace
