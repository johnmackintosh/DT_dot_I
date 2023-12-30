library(data.table)

DT <- fread("highdata.csv")

lookup <- fread("https://raw.githubusercontent.com/johnmackintosh/ph_lookups/main/dz_intzone_cp_dz_names.csv")

# names(DT)
# names(lookup)
# Data_Zone needs to join to "DataZone"
# Could set key on both, but this interferes with existing row order

# or specify by hand

DT <- lookup[DT, on = .(DataZone = Data_Zone)]

# keep the existing order by overall Rank
setkey(DT, SIMD2020v2_Rank)


setnames(DT, 
         old = c("SIMD2020v2_Income_Domain_Rank",
                 "SIMD2020_Employment_Domain_Rank",  
                 "SIMD2020_Health_Domain_Rank",
                 "SIMD2020_Education_Domain_Rank", 
                 "SIMD2020_Access_Domain_Rank", 
                 "SIMD2020_Crime_Domain_Rank",    
                 "SIMD2020_Housing_Domain_Rank",
                 "CP_Name"),
         
         new = c("Income", 
                 "Employment", 
                 "Health",  
                 "Education",
                 "Access", 
                 "Crime", 
                 "Housing",
                 "areaname"))


DT[,.I[Income == max(Income)]]

# returns data.table
DT[,.I[Health == max(Health)],.SD]


# returns single element vector
DT[,.I[Health == max(Health)],.SD]$V1


# max Health rank by Area
DT[,.I[Health == max(Health)], areaname] 

# name the new column
# show the i ,j, by on separate lines

DT[, # i - filter data as appropriate (no filtering in this example)
   .(max_health = .I[Health == max(Health)]), # j  = calculation
   areaname] # by - grouping operation


# extract multiple columns
DT[,
   .(min_health = .I[Health == min(Health)], 
     max_health = .I[Health == max(Health)]),
   areaname]

# view details for Inverness
DT[1, Health]  # lowest Health rank is 12
DT[c(1,417), Health] # low / high is 12 / 6615

DT[Health == 6615,]



# returns all columns for all rows extracted above
DT[DT[, .I[Health == max(Health)], by = .(areaname)]$V1]

#results not shown as too many columns

# extract a small subset of the columns instead with .SD

DT[DT[, .I[Health == max(Health)], by = .(areaname)]$V1
   ][,.SD, .SDcols = c("DataZone", "Health", 
                 "DataZone2011Name", "areaname")]

