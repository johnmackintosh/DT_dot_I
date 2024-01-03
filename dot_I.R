#https://github.com/johnmackintosh/DT_dot_I

library(data.table)
DT <- fread("highdata.csv")
lookup <- fread("https://raw.githubusercontent.com/johnmackintosh/ph_lookups/main/dz_intzone_cp_dz_names.csv")

# names(DT)
# names(lookup)

# Data_Zone needs to join to "DataZone"
# Could set key on both, but this interferes with existing row order
# so specify join "by hand"

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


DT[,.I[Income == max(Income)]] # 437

# returns data.table
DT[,.I[Health == max(Health)],.SD] # 424


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

# view details for Inverness, with indices of 1 & 417
DT[1, Health]  # lowest Health rank is 12
DT[c(1,417), Health] # low / high is 12 / 6615

DT[Health == 6615,]



## what happens if we do something in i, then .I?
# note new Inverness indices compared to 1 & 417 previously

DT[ areaname == "Inverness",  .(min_health = .I[Health == min(Health)], # still 1
                                max_health = .I[Health == max(Health)])] # now 94



# returns all columns for all rows extracted above
DT[DT[, .I[Health == max(Health)], by = .(areaname)]$V1]

#results not shown as too many columns

# extract a small subset of the columns instead with .SD

DT[DT[, .I[Health == max(Health)], by = .(areaname)]$V1
   ][,.SD, .SDcols = c("DataZone", "Health", 
                 "DataZone2011Name", "areaname")]

setkey(DT, DataZone)
# now the indices will change
DT[,.I[Income == max(Income)]] # now 108, was 437

# returns data.table
DT[,.I[Health == max(Health)],.SD]  # now 95, was 424


# https://stackoverflow.com/questions/73506180/select-rows-based-on-conditions-in-r
id <- c(rep(102,9),rep(103,5),rep(104,4))
status <- rep(c('single','relationship','relationship','single','single','single'),3)
status <- factor(status, levels = c("single" ,"relationship"), ordered = TRUE)
age <- c(17:19,22,23,26,28,32,33,21:25,21:24)
DT <- data.table(id, status, age)

newdata <- DT[c(1,2,7,8,13,14,18),]



DT2 <- DT[DT[,.I[status == "single" & age == max(age) |  
                   status == "relationship" & age == min(age)], 
             .(rleid(status),id)]$V1
          ][,rn := rleid(status),id
            ][]

#anti join

#DT2[!DT2[,.I[(rn == 1 & status == "relationship")]]]

DT2 <- DT2[!DT2[,.I[(rn == 1 & status == "relationship")]]
           ][,rn := seq(.N), .(id, status)][]

all.equal(DT2[,1:3], newdata)
dcast(DT2,  
      id ~   rn + status, 
      value.var = "age")
   



