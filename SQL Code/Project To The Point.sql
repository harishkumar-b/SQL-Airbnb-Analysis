---- Create Database Project_PLA;

-- Use Project_PLA;

-- Select * from host_austin_df;
-- Select * from listing_austin_df;
-- Select * from df_austin_availability;
-- Select * from review_austin_df;

-- Select * from host_dallas_df;
-- Select * from listing_dallas_df;
-- Select * from df_dallas_availability;
-- Select * from review_dallas_df;


---a
--TYPES OF PROPERTY WITH PRICING BUCKETS BASES ON AVERAGE PRICE:
Select * from PT_Budget;

--ACCEPTANCE RATE ACROSS PROPERTY TYPES:
--Select * from PT_Budget;
Select * from Avg_ACR;

Select Property_Type,Avg_AcpR, Case when Avg_AcpR between 90 and 100 then 'Great'
when Avg_AcpR between 70 and 89 then 'Good'
when Avg_AcpR between 40 and 89 then 'Average'
when Avg_AcpR < 40 then 'Poor'
Else 'N.A.'
End as Acceptance
from
(Select B.*,A.Avg_AcpR from PT_Budget as B
join Avg_ACR as A
ON B.property_type=A.property_type)AR;


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
(Select Property_Type, Avg(review_scores_rating) as Avg_ from listing_austin_df group by Property_Type
UNION
Select Property_Type, Avg(review_scores_rating) as Avg_ from listing_dallas_df group by Property_Type)Av_R
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


---b

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


---c
Select B.*,R.Avg_of_rating,R.Rating from PT_Budget as B
join PT_Ratings as R
on b.property_type=r.property_type;

---d
--REVIEW ANALYSIS THROUGH COMMENT KEYWORDS:
Select Room_Type, Sum(Postive_comments) as Postive_comments, Sum(Negative_Comments) as Negative_Comments
from
(Select * from d_comments 
UNION
Select * from a_comments)C
Group by Room_Type;

---e
Select Property_Type, Month_Year, Sum(available_listings) as No_of_Listing_Availability from (Select * from PT_Monthly_Availability)PMA 
Group by Property_Type, Month_Year
Order by Property_Type;

---f
--PEAK
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

--OFF PEAK
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


---g
--BEST PERFORMING CATEGORY:

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
