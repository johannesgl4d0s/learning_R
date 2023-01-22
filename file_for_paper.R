install.packages("reshape")
library(bReeze)
#We want the correct power curve here
pow_curve = bReeze::pc("Enercon_E126_7.5MW.pow")
pow_curve_df = data.frame(cbind(pow_curve$v, pow_curve$P))
colnames(pow_curve_df) = c("speed", "power")

plot(pow_curve_df$power)


calculate_wind_outputs <-function(windspeeds, measured_height, hub_height, power_curve, cutin_speed, cutout_speed, terrain)
{
  #First, we calculate what the wind speed would be at the hub height of the given turbine
  #We can use a simple linear adjustment and just increase the speeds by the correct amount
  
  if(terrain == "onshore")
  {
    hellman_exponent = 1/7
  }
  
  else if(terrain == "offshore")
  {
    hellman_exponent = 1/9
  }
  adjustment_factor = (hub_height/measured_height)^hellman_exponent
  adjusted_wind_speeds = windspeeds*adjustment_factor
  
  #Let's create a vector which has the same length as the wind speeds
  power_output = adjusted_wind_speeds
  
  for(i in 1:length(power_output))
  {
    if(adjusted_wind_speeds[i] > cutin_speed & adjusted_wind_speeds[i] < cutout_speed)
    {
      for(j in 1:nrow(power_curve))
      {
        #Just make sure that this is working
        if(adjusted_wind_speeds[i] >= power_curve$speed[j] & adjusted_wind_speeds[i] < power_curve$speed[j+1])
        {
          #We want the power output to match the power curve so long as the wind speed is the same as or greater than
          # the power curve's predicting variable and below the one above
          power_output[i] = power_curve$power[j]
        }
      }
    }
    
    #You get no power output if your wind speed is either below the cut-in or above the cut-out speed
    else if(adjusted_wind_speeds[i] < cutin_speed | adjusted_wind_speeds[i] >= cutout_speed)
    {
      power_output[i] = 0 
    }
  }
  
  
  #In keeping with good practice--a function should return only one variable
  return(power_output)
}

#The power coefficient of the wind is the ratio of 
# wind power electricity to the power in the wind 
area_of_turbine = pi*(0.5*127)^2
wind_sppeds = pow_curve_df$speed
density_of_air = 1.225

#Keep in mind that the expression for kinetic energy was in J, not kWh
#So we first multiply by 1/1000
#Notice though that we are assuming both that the energy is constant
#throughout the hour and therefore that the wind turbine keeps going 
kinetic_energy_in_wind = 0.001*0.5*area_of_turbine*density_of_air*wind_sppeds^3
power_coefficient = pow_curve_df$power/kinetic_energy_in_wind

plot(power_coefficient)


#The first thing we do is to download the hourly wind data from NASA POWER
#We want to get the wind speeds at both 10m and 50m
hourly_wind_data = nasapower::get_power(community = "re", pars = c("WS10M", "WS50M"), temporal_api = "HOURLY", 
                                        lonlat = c(11.1421496, 48.7716291), dates = c("2008-12-31", "2010-01-01"))

#As usual, we want to make sure we have a dataframe, which is the easiest way to work with this kind of thing in R
#The original data download is a tibble, with some metadata which we can discard here
hourly_wind_data = data.frame(hourly_wind_data)

#Put it through the works for the Enercon E-126
#I'm going to use the windspeeds from the 50m hub height, for fun
#Please note that as a decent member of the human race, I only use metric/SI units if at all possible
hourly_wind_energy = calculate_wind_outputs(windspeeds = hourly_wind_data$WS50M, measured_height = 50, hub_height = 135, cutin_speed = 3, cutout_speed = 25, power_curve = pow_curve_df, terrain = "onshore")
#What kind of capacity factor does this give us?
#Convert to MWh
#Then take into account that the total possible energy generated is 7.5 MW * 8760 hours in a year
capacity_factor_rough = 0.001*sum(hourly_wind_energy)/(7.5*8760)

capacity_factor_rough

# ______________________________________________________________________

#How to calculate it in bReeze
#We already did this using our manual method but we will leave out the re-naming of the columns
# and the conversion to a DF--bReeze uses these objects as they are
pow_curve = bReeze::pc("Enercon_E126_7.5MW.pow")
#Let's also get the wind speed data which is bunlded with bReeze
data("winddata", package = "bReeze")
data_from_breeze = winddata

#To calculate the annual energy output from bReeze, we would simply run the following code
annual_energy_from_breeze_40= bReeze::aep(profile = our_wind_profile, hub.h = 40, pc = pow_curve)
annual_energy_from_breeze_40$capacity

#You can see that we are keeping that hub height and power curve from last time
# but we also now need to create a wind profile, shown below

#Our first sub-task is going to be to extract the wind speeds and standard deviations measured at 40 m
measured_40_speed = data_from_breeze$v1_40m_avg
measured_40_std = data_from_breeze$v1_40m_std
direction_from_breeze_set = data_from_breeze$dir1_40m_avg
#We combine the average wind speed, standard deviation of that wind speed and
# its direction into a "set"
set40m = bReeze::set(height = 40, v.avg = measured_40_speed, v.std = measured_40_std, dir.avg = direction_from_breeze_set)
#The next thing to do is to build a "mast" object, which combines a set of wind data
# together with timestamps
#Note that for this to work, we need to format the timestampes correctly
#For the sake of completeness, I am going to give the timestaps a CET timezone
timestamp_from_breeze = bReeze::timestamp(data_from_breeze$date_time, tz = "CET")
mast_for_breeze = bReeze::mast(timestamp = timestamp_from_breeze, set40m)
#So now we have a mast object which ties together a set of wind speed data to date time elements
# We build a "wind profile" which is correctly formatted to use with our function in bReeze
our_wind_profile = bReeze::windprofile(mast = mast_for_breeze, v.set = 1, dir.set = 1)
#Note that I have chosen to use the first (and only) wind speed and direction sets
#Now let's go back to our earlier line of code
annual_energy_from_breeze = bReeze::aep(profile = our_wind_profile, hub.h = 135, pc = pow_curve)
#We can now access the capacity factor--18%
annual_energy_from_breeze$capacity

#______________________
# Ich denke hier liegt ein denk Fehler vor:

plot(hourly_wind_data$WS50M, type = "l")
#Vermutung: die Windstärksten Monate liegen im ersten und letzten Quartal des Jahres 

library(dplyr)
# Erzeuge einenen Dataframe mit den Monatsmittelwerten
month_data = hourly_wind_data %>% group_by(MO) %>% 
  summarise(Mean_month=mean(WS50M),
            .groups = 'drop') %>% as.data.frame()

#Plote einen Barplot mit den Monatsmittelwerten
data_bar = month_data$Mean_month
names(data_bar) = month_data$MO
barplot(data_bar, main = 'Mittlere Monatliche Windgeschwindigkeit', 
        xlab = 'Monate', ylab = 'Windgeschwindigkeit [m/s]')
# Vermutung scheint korrekt zu sein. Das ergibt folgendes Problem:
# der Dataframe "winddata" liefert 10 Minuten Daten im Zeitraum Mai (5) 
# und 31. Jänner das heißt um den Wirkungsgrad richtig auszurechnen müssen
#die selben Zeiten verglichen werden. 

hourly_wind_data_jm = nasapower::get_power(community = "re", pars = c("WS10M", "WS50M"), temporal_api = "HOURLY", 
                                        lonlat = c(11.1421496, 48.7716291), dates = c("2009-05-06", "2010-01-31")) # neuer Zeithorizont 
# 8760 Std entsprechen einen Jahr => neuer Stunden zwischen Mai und Jänner müssen gefunden werden

date_1 = as.Date("2009-05-06")
date_2 = as.Date("2010-01-31")

diff_days = as.numeric(difftime(date_2,date_1, units = "days"))

std_ofyear = diff_days * 24

# wie oben ist der orginale Df ein tribble

hourly_wind_data_jm = data.frame(hourly_wind_data_jm)

#mit einer Enercon E-126 Windkraftwerk berechnet ergibt folgende Leistung: 

hourly_wind_energy_jm = calculate_wind_outputs(windspeeds = hourly_wind_data_jm$WS50M, measured_height = 50, hub_height = 135, cutin_speed = 3, cutout_speed = 25, power_curve = pow_curve_df, terrain = "onshore")
plot(hourly_wind_energy_jm, type = 'l', xlab = 'Stunden des Jahres', ylab = 'Leistung')
#What kind of capacity factor does this give us?

capacity_factor_rough_jm = 0.001*sum(hourly_wind_energy_jm)/(7.5*std_ofyear)

# Schauen wir uns die Erbebisse an: 
c(capacity_factor_rough_jm, capacity_factor_rough, annual_energy_from_breeze$capacity)

# Hmm der Abstand zwischen den Wirkungsgraden wird größer und nicht kleiner (wenig überraschend)

# Wo liegt der Unterschied?
# erst einmal müssen winddata aufbereitet werden für calculate_wind_outputs
#Was für ein Format ist date_time
class(winddata$date_time)
#Charakters 


#Ändere das Format zu datetime : 
winddata$date_time = as_datetime(winddata$date_time,format =  "%d.%m.%Y %H")


hourly_data = winddata %>% group_by(date_time) %>% 
  summarise(Mean_hour=mean(v1_40m_avg),
            .groups = 'drop') %>% as.data.frame()
hourly_wind_energy_jm2 = calculate_wind_outputs(windspeeds = hourly_data$Mean_hour, measured_height = 40, hub_height = 135, cutin_speed = 3, cutout_speed = 25, power_curve = pow_curve_df, terrain = "onshore")
capacity_factor_rough_jm2 = 0.001*sum(hourly_wind_energy_jm2)/(7.5*length(hourly_data$Mean_hour))
capacity_factor_rough_jm2

# die Berechnung zeigt, dass der Wirkungsgrad stark unterschiedlich ist. 
#das liegt einerseit wahrscheinlich an den ungenaueren Daten, andererseits an der Gruppierung

#schauen wir uns den Energieoutput näher an: 

library(ggplot2)
library(reshape)

data_line = data.frame(hour = seq(1:6093), nasa_data = hourly_wind_energy_jm[1:6093],bReeze_data = hourly_wind_energy_jm2)
Molten <- melt(data_line, id.vars = "hour")
ggplot(Molten, aes(x = hour, y = value, colour = variable)) + geom_line()

# in Summe ergibt das:
Summendarstellung = c(sum(hourly_wind_energy_jm[1:6093]),sum(hourly_wind_energy_jm2))
Summendarstellung

Diff_proz = sum(hourly_wind_energy_jm2)/sum(hourly_wind_energy_jm[1:6093])
Diff_proz
# in Summe weisen die bReeze Daten 12% weniger Wind in der Funktionsberechnung aus. 
#Liegt das an einem Umrechnungsfaktor in der Funktion oder an den Windenergiedaten?

data_line_wd = data.frame(hour = seq(1:6093), nasa_data = hourly_wind_data_jm$WS50M[1:6093],bReeze_data = hourly_data$Mean_hour)
Molten <- melt(data_line_wd, id.vars = "hour")
ggplot(Molten, aes(x = hour, y = value, colour = variable)) + geom_line()
# die Nasa Daten wirken geglätteter  

summary(data_line_wd)
Summen_Windpower = c(sum(hourly_wind_data_jm$WS50M[1:6093]), sum(hourly_data$Mean_hour))

Summen_Windpower

diff_windpower = sum(hourly_data$Mean_hour)/sum(hourly_wind_data_jm$WS50M[1:6093])
diff_windpower

#der unterschied in der Windpower ist größer als nach der Umrechnung in Elektrische Leistung - das ist recht spannend. 
#Es ist möglich das diese Verschiebung durch die Hellmankonstante auftritt 

#der Grundsätzliche Unterschied in den Wirkungsgraden ist aber in der Datenbasis zu finden. 
