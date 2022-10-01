/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT * FROM Facilities WHERE membercost != 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) FROM Facilities WHERE membercost = 0;    /* result 4 */

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance FROM Facilities 
WHERE membercost > 0 AND membercost < (monthlymaintenance * 0.2) 

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM Facilities WHERE facid IN (1, 5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE 
    WHEN monthlymaintenance > 100 THEN 'expensive'
    ELSE 'cheap'
END AS cheap_exp
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname, joindate FROM Members
ORDER BY joindate DESC LIMIT 1
       /* -------------------------  or  -------------------------      */
SELECT firstname, surname  FROM Members 
WHERE joindate = (SELECT MAX(joindate) FROM Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */ 

SELECT  DISTINCT(concat(Members.firstname, " ", Members.surname)) AS Mem_Name, 
Facilities.name  As Fclty_Service
FROM Members, Facilities, Bookings 
WHERE Facilities.facid IN (0, 1) 
ORDER BY  Mem_Name ASC

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT CONCAT(Members.firstname, ' ', Members.surname) AS MemberName, 
	Facilities.name, 
	CASE 
		WHEN Members.memid = 0 THEN Bookings.slots * Facilities.guestcost
		ELSE Bookings.slots * Facilities.membercost
	END AS cost
FROM Members                
INNER JOIN Bookings
ON Members.memid = Bookings.memid
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE 
	Bookings.starttime >= '2012-09-14' AND 
	Bookings.starttime < '2012-09-15' AND (
        (Members.memid = 0 AND Bookings.slots * Facilities.guestcost > 30) OR
		(Members.memid != 0 AND Bookings.slots * Facilities.membercost > 30)
		)
ORDER BY cost DESC;  

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT MemberName, Facility, Cost FROM (
	SELECT
		CONCAT(Members.firstname,' ', Members.surname) AS MemberName,
		Facilities.name AS Facility,
		CASE
			WHEN Members.memid = 0 THEN
				Bookings.slots * Facilities.guestcost
			ELSE
				Bookings.slots * Facilities.membercost
		END AS Cost
	FROM Members
		INNER JOIN Bookings
			ON Members.memid = Bookings.memid
		INNER JOIN Facilities
			ON Bookings.facid = Facilities.facid
	WHERE
		Bookings.starttime >= '2012-09-14' AND
		Bookings.starttime < '2012-09-15'
	)
    AS Bookings
WHERE Cost > 30
ORDER BY Cost desc;         

/* PART 2: SQLite

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

 SELECT f.name, 
    SUM(b.slots * (
	    CASE WHEN b.memid = 0 THEN f.guestcost 
    	ELSE f.membercost END
		)
	) AS Revenue
    FROM Bookings AS b
    INNER JOIN Facilities AS f 
    ON b.facid = f.facid
    GROUP BY f.name
    HAVING revenue < 1000
    ORDER BY Revenue

/* Q11: Produce a report of members and who recommended them in alphabetic surname, firstname order */
    
    SELECT ma.memid AS MemberID, 
            ma.surname, ma.firstname AS Member, 
            mr.memid AS RecommenderID, 
            mr.surname, mr.firstname AS Recommender 
    FROM Members AS ma, Members AS mr 
    WHERE ma.recommendedby = mr.memid AND ma.memid != 0 AND mr.memid != 0 
    ORDER BY ma.surname ASC;

/* Q12: Find the facilities with their usage by member, but not guests */
   
    SELECT b.facid AS FacilityID, 
        sum(b.slots) AS Memberusage 
    FROM Bookings AS b 
    WHERE b.memid != 0 
    GROUP BY b.facid 
    ORDER BY b.facid;

/* Q13: Find the facilities usage by month, but not guests */

    SELECT Date(b.starttime) AS month, 
            sum(b.slots) AS facilityusage 
    FROM bookings as b 
    WHERE b.memid != 0 
    GROUP BY Date(b.starttime) 
    ORDER BY Date(b.starttime);