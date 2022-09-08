--- Create Database Project_PLA;
-- Use Project_PLA;

-- Select * from host_austin_df;
-- Select * from listing_austin_df;
-- Select * from df_austin_availability;
-- Select * from review_austin_df;

-- Select * from host_dallas_df;
-- Select * from listing_dallas_df;
-- Select * from df_dallas_availability;
-- Select * from review_dallas_df;

---a. Analyze different metrices to draw the distinction between the different types of property along with their price listings(bucketize them within 3-4 categories basis your understanding): To achieve this, you can use the following metrics and explore a few yourself as well. Availability within 15,30,45,etc. days, Acceptance Rate, Average no of bookings, reviews, etc.

--TYPES OF PROPERTY WITH PRICING BUCKETS BASES ON AVERAGE PRICE:
Create view PT_Budget as
Select *, Case when Avg_Price< =100 Then 'Affordable'
when Avg_Price > 1000 Then 'Luxurious'
when Avg_Price between 500 and 1000 Then 'Ultra Premium'
else 'Premium' 
end as 'Stay' 
FROM
(Select Property_Type, Avg(Avg_) as Avg_Price from (Select Property_Type, avg(price) as Avg_ from listing_dallas_df  group by property_type 
UNION
Select Property_Type, avg(price) as Avg_Price from listing_austin_df  group by property_type)Ap group by property_type )Avg_price;

Select * from PT_Budget;

--ACCEPTANCE RATE ACROSS PROPERTY TYPES:
Select * from Avg_ACR;

Select *, Case when Avg_AcpR between 90 and 100 then 'Great'
when Avg_AcpR between 70 and 89 then 'Good'
when Avg_AcpR between 40 and 89 then 'Average'
when Avg_AcpR < 40 then 'Poor'
Else 'N.A.'
End as Acceptance
from
(Select B.*,A.Avg_AcpR from PT_Budget as B
join Avg_ACR as A
ON B.property_type=A.property_type)AR;

--OR--

Select * from (Select B.Stay,A.Avg_AcpR from PT_Budget as B
join Avg_ACR as A
ON B.property_type=A.property_type)B_Acr
pivot(avg(Avg_AcpR) for Stay in ([Ultra Premium],[Premium],[Luxurious],[Affordable])) as ACR_Pivot;

--RATING BUCKETS ON PROPERTY TYPES:
Select *, Case when Avg_of_rating = 5 then 'Extraodinary'
when Avg_of_rating > 4.5 then 'Excellent'
when Avg_of_rating > 4 then 'Good'
when Avg_of_rating > 3 then 'Average'
when Avg_of_rating <= 3 then 'Poor'
else 'N.A.'
eND as 'Rating'
from
(Select Property_Type, Avg(Avg_) as Avg_of_rating from 
(Select Property_Type, Avg(review_scores_accuracy) as Avg_ from listing_austin_df group by Property_Type
UNION
Select Property_Type, Avg(review_scores_accuracy) as Avg_ from listing_dallas_df group by Property_Type)Av_R
Group by Property_Type)Avg_Rate;

--BOOKING VOLUMES CATEGORIZATION ON PROPERTY TYPE:
Select *, Case when Number_of_bookings> 100000 then 'Most Bookings'
when Number_of_bookings < 10000 then 'Least Bookings'
else 'Moderate Bookings'
end as Bookings
from
(Select Property_Type, Sum(No_of_bookings) as Number_of_bookings from
(Select listA.property_type,count(available) as No_of_bookings from listing_austin_df as listA
join df_austin_availability as AvailA
on listA.id=AvailA.listing_id
where AvailA.available=0
Group by listA.property_type
UNION
Select listD.property_type,count(available) as No_of_bookings from listing_dallas_df as listD
join df_dallas_availability as AvailD
on listD.id=AvailD.listing_id
where AvailD.available=0
Group by listD.property_type)B
GROUP BY Property_Type)Bookings;


---b. Study the trends of the different categories and provide insights on same
--PRICE TRENDS ACROSS PROPERTY TYPES:
Select Property_Type, Min(Min_P) as Min_Price, Max(Max_P) as Max_Price, Avg(Avg_P) as Avg_Price from
(Select Property_Type, min(price) as Min_P, max(price) as Max_P, avg(price) as Avg_P from listing_dallas_df  group by property_type 
UNION
Select Property_Type, min(price) as Min_P, max(price) as Max_P, avg(price) as Avg_Price from listing_austin_df  group by property_type)PT 
Group by Property_Type;

--PRICE TRENDS ACROSS LISTING CATEGORIES:
Select Room_Type, Min(Min_P) as Min_Price, Max(Max_P) as Max_Price, Avg(Avg_P) as Avg_Price from
(Select Room_Type, min(price) as Min_P, max(price) as Max_P, avg(price) as Avg_P from listing_dallas_df  group by room_type 
UNION
Select Room_Type, min(price) as Min_P, max(price) as Max_P, avg(price) as Avg_P from listing_austin_df  group by room_type)PT 
Group by Room_Type;

--ACCEPTANCE TRENDS ACROSS LISTING CATEGORIES:
Select Room_Type, Avg(Avg_) as Avg_AR from 
(Select listD.Room_Type, AVG(hostD.host_acceptance_rate) as Avg_ from listing_dallas_df as listD
join host_dallas_df as hostD
ON listD.host_id = hostD.host_id
GROUP BY listD.Room_Type
UNION
Select listA.Room_Type, AVG(hostA.host_acceptance_rate) as Avg_ from listing_austin_df as listA
join host_austin_df as hostA
ON listA.host_id = hostA.host_id
GROUP BY listA.Room_Type)Acr_RT
Group by Room_Type;


---c. Using the above analysis, identify top 2 crucial metrics which makes different property types along their listing price stand ahead of other categories 

Create View PT_Ratings as
Select *, Case when Avg_of_rating > 4.5 then 'Excellent'
when Avg_of_rating > 4 then 'Good'
when Avg_of_rating > 3 then 'Average'
else 'Poor'
eND as 'Rating'
from
(Select Property_Type, Avg(Avg_) as Avg_of_rating from 
(Select Property_Type, Avg(review_scores_accuracy) as Avg_ from listing_austin_df group by Property_Type
UNION
Select Property_Type, Avg(review_scores_accuracy) as Avg_ from listing_dallas_df group by Property_Type)Av_R
Group by Property_Type)Avg_Rate;

Select B.*,R.Avg_of_rating,R.Rating from PT_Budget as B
join PT_Ratings as R
on b.property_type=r.property_type;


---d. Analyze how does the comments of reviewers vary for listings of distinct categories (Extract words from the comments provided by the reviewers)

--REVIEW ANALYSIS THROUGH COMMENT KEYWORDS:
Create view list_revA as 
Select listA.room_type, revA.comments from listing_austin_df as listA
join review_austin_df as revA
on listA.id=revA.listing_id; 

Select * from list_revA

Create View a_comments as 
WITH P_A as 
(Select Room_Type, count(comments) as Postive_comments  from list_revA where 
comments like '%excellent%' or comments like '%great%' or 
comments like '%Awesome%' or comments like '%Good%' and comments like '%Comfort%'
group by Room_Type),
N_A as
(Select Room_Type, count(comments) as Negative_comments  from list_revA where 
comments like '%Bad%' or comments like '%Worst%' 
or comments like '%Not good%' or comments like '%Unsatisfac%'
group by Room_Type)
Select P_A.*,N_A.Negative_Comments from P_A
full outer join N_A
ON P_A.Room_Type=N_A.Room_Type;


Select * from a_comments

Create view list_revD as 
Select listD.room_type, revD.comments from listing_dallas_df as listD
join review_dallas_df as revD
on listD.id=revD.listing_id; 

Select * from list_revD

Create View d_comments as 
WITH P_D as 
(Select Room_Type, count(comments) as Postive_comments  from list_revD where 
comments like '%excellent%' or comments like '%great%' or 
comments like '%Awesome%' or comments like '%Good%' and comments like '%Comfort%'
group by Room_Type),
N_D as
(Select Room_Type, count(comments) as Negative_comments  from list_revD where 
comments like '%Bad%' or comments like '%Worst%' 
or comments like '%Not good%' or comments like '%Unsatisfac%'
group by Room_Type)
Select P_D.*,N_D.Negative_Comments from P_D
full outer join N_D
ON P_D.Room_Type=N_D.Room_Type;

Select Room_Type, Sum(Postive_comments) as Comments_Positive, Sum(Negative_Comments) as Comments_Negative
from
(Select * from d_comments 
UNION
Select * from a_comments)C
Group by Room_Type;

---e. Analyze if there is any correlation between property type and their availability across the months

Create view list_availA as
Select listA.*, availA.available, availA.date from listing_austin_df as listA
join df_austin_availability as availA
on listA.id=availA.listing_id;

Create view list_availD as
Select listD.*, availD.available, availD.date from listing_dallas_df as listD
join df_dallas_availability as availD
on listD.id=availD.listing_id;

Create view PT_Monthly_Availability as 
With m_A as
(Select property_type, concat_ws('-',datename(month,date), year(date)) as Month_Year, count(available) as available_listings from list_availA 
where available=1 
group by property_type,concat_ws('-',datename(month,date), year(date))),
m_D as
(Select property_type, concat_ws('-',datename(month,date), year(date)) as Month_Year, count(available) as available_listings from list_availD 
where available=1 
group by property_type, concat_ws('-',datename(month,date), year(date)))
Select * from m_A 
union 
Select * from m_D;

Select Property_Type, Month_Year, Sum(available_listings) as No_Listings from (Select * from PT_Monthly_Availability)PMA 
Group by Property_Type, Month_Year
Order by Property_Type;


---f. Analyze what are the peak and off-peak time for the different categories of property type and their listings. Do we see some commonalities in the trend or is it dependent on the category

--PEAK TIME ANALYSIS
Select room_type, Month , Year, Sum(Av) as Peak_Counts from 
(
Select room_type, datepart(month,date) as Month , year(date) as Year, count(available) as Av from list_availA 
where available=0 group by room_type, datepart(month,date),year(date)
UNION
Select room_type, datepart(month,date) as month, year(date) as Year, count(available) Av from list_availD 
where available=0 group by room_type, datepart(month,date),year(date)
)Avail
group by room_type, Month , Year
order by room_type;

--OFF PEAK ANALYSIS
Select room_type, Month , Year, Sum(Av) as Off_Peak_Counts from 
(
Select room_type, datepart(month,date) as Month , year(date) as Year, count(available) as Av from list_availA 
where available=1 group by room_type, datepart(month,date),year(date)
UNION
Select room_type, datepart(month,date) as month, year(date) as Year, count(available) Av from list_availD 
where available=1 group by room_type, datepart(month,date),year(date)
)Avail
group by room_type, Month , Year
order by room_type;


---g. Using the above analysis, suggest what is the best performing category for the company

Select  room_type, Sum(Peak_Counts) as No_of_Booking from
(Select room_type, Month , Year, Sum(Av) as Peak_Counts from 
(
Select room_type, datepart(month,date) as Month , year(date) as Year, count(available) as Av from list_availA 
where available=0 group by room_type, datepart(month,date),year(date)
UNION
Select room_type, datepart(month,date) as month, year(date) as Year, count(available) Av from list_availD 
where available=0 group by room_type, datepart(month,date),year(date)
)Avail
group by room_type, Month , Year)Cat_Analysis
group by room_type
order by Sum(Peak_Counts) desc;


