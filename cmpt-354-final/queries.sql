-- Queries for Task 2

/*
Q1. Find all competitions (calls for grant proposals) open at a user-specified month, which
already have at least one submitted large proposal. For a proposal to be large, it has to request more
than $20,000 or to have more than 10 participants, including the principle investigator. Return both
IDs and the titles.

Q2.  Next, modify your program for Q1 by allowing the user to specify the areas (e.g., biology
and chemistry) (s)he is interested in, and only displaying the competitions where the submitted large
proposals have principle investigators specified by the user.
*/

-- Assumptions:
-- "competitions" = calls
-- a submitted proposal will include "submitted", "awarded", and "denied" proposals

WITH large_proposal AS (
  SELECT * 
  FROM proposal P
  WHERE (
    amount_requested >= 20000.00 OR
    (SELECT count(id) 
     FROM collaborator 
     WHERE proposalid = P.id) >= 10
  )
)
SELECT C.id AS callid, P.id AS proposalid, title
FROM call C JOIN large_proposal P ON C.id = P.callid
WHERE (
  EXTRACT(MONTH FROM call_date) = 2 AND -- replace with month
  area = any(ARRAY['Engineering']) AND -- replace with area(s)
  pi = any(ARRAY[4]) -- replace with private investigator(s) id
);


/*
Q3. For a user-specified area, find the proposal(s) that request(s) the largest amount of
money.
*/

-- Assumptions:
-- The user will only pick one area

SELECT *
FROM proposal P
WHERE (
  EXISTS (
    SELECT 1 FROM call C 
    WHERE (
      C.id = P.callid AND
      C.area = 'Biology' -- replace with area
    )
  ) AND
  
  amount_requested = (
    SELECT max(amount_requested) FROM proposal
  )
);


/*
Q4. For a user-specified date, find the proposals submitted before that date that are awarded
the largest amount of money.
*/

SELECT id, amount_awarded, proposal_date
FROM proposal P
WHERE (
  proposal_date < '2020-01-02' AND -- replace with date
  amount_awarded = (SELECT max(amount_awarded) FROM proposal)
);
 

/*
Q5. For an area specified by the user, output its average requested/awarded discrepancy,
that is, the absolute value of the difference between the amounts.
*/

SELECT C.area, avg(abs(amount_requested - amount_awarded)) AS discrepancy
FROM proposal P JOIN call C on C.id=P.id
WHERE area = 'Computer Science' -- replace with area
GROUP BY C.area;


/*
Q6 (30 points) Reviewer assignment: Provide the user with the option of assigning a set of reviewers to
review a specific grant application (research proposal), one proposal at a time. The proposal ID
should be specified by the user. Before doing the reviewers assignment, the user should be able to
request and receive a list of reviewers who are not in conflict with the proposal being reviewed,
and who still have not reached the maximum of three proposals to review.
*/

-- Part I: user reviewer assignment
INSERT INTO review VALUES
(DEFAULT,1,1,now() + interval '2 week','f', NULL);
-- 1st entry (fixed): DEFAULT. 2nd entry (variable): reviewer the user wants to assign.
-- 3rd entry (variable): proposal user wants reviewed. 4th entry (fixed): now() + interval '2 week'. 
-- 5th entry (fixed): false. 6th entry (fixed): NULL.


-- Part II: list of non-conflicting reviewers
-- Does not check conflicts with coreviewers or collaborators, just pi and main reviewer
SELECT reviewerid
FROM review

EXCEPT

SELECT DISTINCT(reviewerid)
FROM(
    SELECT *
    FROM (SELECT *
        FROM conflict c JOIN (
            SELECT reviewerid, proposalid, pi
            FROM proposal p JOIN review r ON r.proposalid = p.id
            WHERE proposalid = 1 -- Replace 1 with user's proposal entry
          ) pr 
          ON pr.pi = c.researcher1

        UNION

        SELECT *
        FROM conflict c JOIN (
          SELECT reviewerid, proposalid, pi
          FROM proposal p JOIN review r ON r.proposalid = p.id
          WHERE proposalid = 1 -- Replace 1 with user's proposal entry
        ) pr
        ON pr.pi = c.researcher2) pru
    WHERE researcher1 = reviewerid AND researcher2 = pi
    OR researcher2 = reviewerid AND researcher1 = pi) pru2

EXCEPT
-- Filter out reviewers with 3 or more reviews
SELECT reviewerid
FROM review
GROUP BY reviewerid
HAVING count(*) > 2

EXCEPT
-- Filter out reviewers who review their own proposal
SELECT reviewerid
FROM review JOIN conflict ON reviewerid = researcher1
WHERE researcher1 = researcher2


/*
Q7. Meeting scheduling: Your application should check if the user-entered room is available
at a the user-entered date. If yes, the user should be prompted to enter 3 competitions (calls)
IDs to be discussed and decided on that day. If a competition cannot be scheduled to be discussed
on that day (because some of the reviewers are not available), then the user should be prompted
that scheduling a discussion on that particular competition is impossible on that day (a simplified
version just returns "Impossible"). Here, for a reviewer "not to be available" means that he or she
is scheduled to be in another room on the same day.
*/

-- Assumptions:
-- "room" = meeting
-- if a user-entered date is availiable (AKA, does not conflict with other meetings), 
-- then a new meeting is created automatically (given that all 3 competitions are valid)
-- A date is invalid and cannot be picked if there is < 3 non-conflicting calls to discuss for that date
-- A call can be discussed in multiple meetings, just as long as they're on different dates

-- First part: Check if room is available at user-entered date
-- if below query is empty arr, return true
-- else, return false
SELECT 1
FROM meeting
WHERE date = date; -- replace with date

-- Second part: Check if competitions are schedulable. That is:
-- reviewers for each call aren't in another meeting on the specified day

-- Assumptions, reviewers not availiable do not include co-reviewers

-- Run this query 3 times, once for each call
-- if every query is empty arr, then schedule possible
SELECT 1
FROM call C 
JOIN proposal P on P.callid = C.id
JOIN review R on R.proposalid = P.id
WHERE (
  C.id = 1 AND -- replace with call
  '3/11/2020' = any( -- replace with date
    SELECT date 
    FROM meeting M JOIN participant PA ON PA.meetingid = M.id
    WHERE R.reviewerid = PA.reviewerid
  )
);

-- Step 3: Insert new meeting, new participants
INSERT INTO meeting VALUES
(DEFAULT, '2020-11-03') RETURNING id; -- replace with date


INSERT INTO participant(reviewerid, meetingid)
SELECT R.reviewerid, 1
FROM call C
JOIN proposal P on P.callid = C.id
JOIN review R on P.proposalid = P.id
WHERE C.id = any(ARRAY[1,2,3]);

