# This statement is using the "USE" command to switch to a specific database within the MySQL server. The database being selected is "project". 
# This statement ensures that all the subsequent SQL statements will be executed on the "project" database until a new "USE" statement is executed.
USE project;

# This statement will return all the rows and columns from the "earthquake" table.
SELECT * from earthquake;

# This query will return the data type and column name of all columns in the "earthquake" table located in the "project" schema from the "information_schema.columns" view.
SELECT DATA_TYPE, column_name from information_schema.columns
where table_schema = 'project' and table_name = 'earthquake';

# This query is checking if the length of the date column is not equal to 10 or 9 or 8, then it will select that date column. 
# On a quick look at column date, format of date will either be in format : 1/12/2022, 10/1/2022 or 10/10/2022
SELECT date from earthquake
WHERE length(date) != 10 and length(date) != 9 and length(date) != 8;

# It is showing 3 values with length > 10 
# For example : '1975-02-23T02:58:41.000Z', 

select left(Date, 10) from earthquake;

# Updating the Date column so that only first 10 from left will be considered in the Column "Date"
UPDATE earthquake
SET Date = LEFT(Date, 10);

# Rechecking whether any values are present with record greater than 10
select date from earthquake
where length(date) != 10 and length(date) != 9 and length(date) != 8;


# We Need to Standardize Date column
# Since we have updated the length of the "Date" column, we now need to standardise the datatype
# Creating a new column named "Date2" with 'Date datatype'
# STR_TO_DATE() function : converts a string to a date in a specified format.
ALTER TABLE earthquake
ADD column Date2 date after Date;

UPDATE earthquake
SET Date2 = str_to_date(Date, '%d/%m/%Y');
# Got error while running this command as '02-01-1995' is in Incorrect datetime value

SELECT * FROM earthquake 
WHERE date NOT REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' 
AND date NOT REGEXP '^[0-9]{1}/[0-9]{2}/[0-9]{4}$'
AND date NOT REGEXP '^[0-9]{1}/[0-9]{1}/[0-9]{4}$' 
AND date NOT REGEXP '^[0-9]{1}/[0-9]{2}/[0-9]{4}$'
AND date NOT REGEXP '^[0-9]{2}/[0-9]{1}/[0-9]{4}$';

# To know the cause of error
SELECT date, str_to_date(Date, '%d-%m-%Y') from earthquake
where str_to_date(Date, '%d-%m-%Y') is null; 
# This query returns 3 rows
# 1975-02-23 , 1985-04-28, 2011-03-13 is in different date format

# Using UPDATE and REPLACE function
UPDATE earthquake
SET Date = replace(date,'1975-02-23', '23-02-1975');
UPDATE earthquake
SET Date = replace(date,'1985-04-28', '28-04-1985');
UPDATE earthquake
SET Date = replace(date,'2011-03-13', '13-03-2011');

SELECT * FROM earthquake 
WHERE date NOT REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' 
AND date NOT REGEXP '^[0-9]{1}/[0-9]{2}/[0-9]{4}$'
AND date NOT REGEXP '^[0-9]{1}/[0-9]{1}/[0-9]{4}$' 
AND date NOT REGEXP '^[0-9]{1}/[0-9]{2}/[0-9]{4}$'
AND date NOT REGEXP '^[0-9]{2}/[0-9]{1}/[0-9]{4}$';

# After rectifying the error, standardising the date format
UPDATE earthquake
SET Date2 = str_to_date(Date, '%m/%d/%Y');

select date, date2
from earthquake;

# Standardize the column "Time"
# Column "Time 2 is created
# cast function is used to convert text values to time format
SELECT cast(time as time)
FROM earthquake;

ALTER table earthquake
add Time2 time after time;

UPDATE earthquake
SET Time2 = cast(time as time);
# It gave an error
# Truncated incorrect time value: '1975-02-23T02:58:41.000Z' 
# Got to know that some values have different length and in different format


SELECT time, length(time) 
FROM earthquake;
# We got to know that length is 8 in most of the cases

SELECT time, length(time) 
FROM earthquake
WHERE length(time) > 8 ;
# 3 rows have length > 8

# To fix the error, we use UPDATE, REPLACE, SUBSTR function
UPDATE earthquake
SET time = replace(time, '1975-02-23T02:58:41.000Z', substr(12, 8)); 
UPDATE earthquake
SET time = replace(time, '1985-04-28T02:53:41.530Z', substr(12, 8)); 
UPDATE earthquake
SET time = replace(time, '2011-03-13T02:23:34.520Z', substr(12, 8));

# Checking whether any time with length value other than 8 or 24
SELECT time, length(time) 
FROM earthquake
WHERE length(time) != 8 and length(time) != 24; 
# Turns out, there are rows with length = 7, which is fine

# Updating the column "Time2" with 'time' datatype
UPDATE earthquake
set Time2 = Time;


# CHECKING BLANK VALUES
SELECT * from earthquake
WHERE depth = ' ';

SELECT count(depth)
FROM earthquake
WHERE depth = ' ';

UPDATE earthquake
SET depth = case
when depth = ' ' then 0.0
else depth
END;

# Some column names have spaces in between, resolving the issue
ALTER TABLE earthquake RENAME COLUMN `Azimuthal Gap` TO `AzimuthalGap`;
ALTER TABLE earthquake RENAME COLUMN `Root Mean Square` TO `Root_Mean_Square`;
ALTER TABLE earthquake RENAME COLUMN `Magnitude Seismic Stations` TO `Magnitude_Seismic_Stations`;
ALTER TABLE earthquake RENAME COLUMN `Horizontal Distance` TO `Horizontal_Distance`;
ALTER TABLE earthquake RENAME COLUMN `Magnitude Error` TO `Magnitude_Error`;
ALTER TABLE earthquake RENAME COLUMN `Horizontal Error` TO `Horizontal_Error`;
ALTER TABLE earthquake RENAME COLUMN `Depth Error` TO `Depth_Error`;
ALTER TABLE earthquake RENAME COLUMN `Depth Seismic Stations` TO `Depth_Seismic_Stations`;

UPDATE earthquake
SET Depth_Error = case
when Depth_Error = ' ' then 0.0
else Depth_Error
END;

# Rechecking the blanks
select count(Depth_Error) FROM earthquake
where Depth_Error = ' ';

# CONVERING NUMERICAL DATA INTO DOUBLE FROM TEXT FORMAT
ALTER table earthquake
modify column Magnitude_Seismic_Stations double;
# 0Error Code: 1265. Data truncated for column 'Magnitude_Seismic_Stations' 

# So, using cast, alter , add and update functions to make new column with double datatype
SELECT cast(AzimuthalGap as double) from earthquake;
ALTER table earthquake add Azimuthal_Gap double after AzimuthalGap;
UPDATE earthquake
SET AzimuthalGap = cast(Azimuthal_Gap as double);

SELECT cast(Depth_Seismic_Stations as double) from earthquake;
ALTER table earthquake add DepthSeismicStations double after Depth_Seismic_Stations;
UPDATE earthquake
SET Depth_Seismic_Stations = cast(DepthSeismicStations as double);

SELECT cast(Root_Mean_Square as double) from earthquake;
ALTER table earthquake add RootMeanSquare double after Root_Mean_Square;
UPDATE earthquake
SET Root_Mean_Square = cast(RootMeanSquare as double);

SELECT cast(Horizontal_Error as double) from earthquake;
ALTER table earthquake add HorizontalError double after Horizontal_Error;
UPDATE earthquake
SET Horizontal_Error = cast(HorizontalError as double);

SELECT cast(Horizontal_Distance as double) from earthquake;
ALTER table earthquake add HorizontalDistance double after Horizontal_Distance;
UPDATE earthquake
SET Horizontal_Distance = cast(HorizontalDistance as double);

SELECT cast(Magnitude_Seismic_Stations as double) from earthquake;
ALTER table earthquake add MagnitudeSeismicStations double after Magnitude_Seismic_Stations;
UPDATE earthquake
SET Magnitude_Seismic_Stations = cast(MagnitudeSeismicStations as double);

SELECT cast(Magnitude_Error as double) from earthquake;
ALTER table earthquake add MagnitudeError double after Magnitude_Error;
UPDATE earthquake
SET Magnitude_Error = cast(MagnitudeError as double);

# Getting to know the table Earthquake
SELECT * from earthquake;

# DROPPING UNWANTED COLUMNS
ALTER table earthquake DROP column Date;
ALTER table earthquake DROP column Time;
ALTER table earthquake DROP Depth_Error;
ALTER table earthquake DROP Depth_Seismic_Stations;
ALTER table earthquake DROP Horizontal_Distance;
ALTER table earthquake DROP Horizontal_Error;
ALTER table earthquake DROP AzimuthalGap;
ALTER table earthquake DROP Magnitude_Seismic_Stations;
ALTER table earthquake DROP Root_Mean_Square;
ALTER table earthquake DROP Magnitude_Error;

# Rechecking all the columns
SELECT * from earthquake;

# CHECKING FOR DUPLICATES USING CTE and ROWNUM

with t1
as
(SELECT *, row_number() over(partition by Date2, Time2, Latitude, Longitude order by ID) rownum
from earthquake)
SELECT count(*) from t1
WHERE rownum > 1;
# We can see that no duplicates are present

# EXTRACTING YEAR, MONTH, WEEK, DAY OF THE WEEk
# Using alter function to add columns
# Using EXTRACT function to extract year, week.. 
ALTER table earthquake
ADD column year int after time2;
UPDATE earthquake SET Year = extract(Year from Date2);

ALTER table earthquake
ADD column Month int after Year;
UPDATE earthquake SET Month = extract(Month from Date2);

ALTER table earthquake
ADD column week int after month;
UPDATE earthquake SET Week = week(Date2,0);

ALTER table earthquake
ADD column day char(17) after week;
UPDATE earthquake SET day = dayname(Date2);

# Checking to know whether new columns are properly created
select * from earthquake;

# CHECK WHETHER ANY DATA IS PRESENT OUTSIDE OF RANGE BETWEEN 1965 and 2016
SELECT year from earthquake
WHERE Year < 1965 or Year >2016;

SELECT Magnitude from earthquake
WHERE Magnitude < 5.5;





