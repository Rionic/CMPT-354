-- On-paper assertions in typed form

-- A1
-- Conflicts of interests must be taken into account in reviewer assignments. That is, if currently there
-- is a conflict, the corresponding reviewer cannot be assigned.

CREATE TRIGGER check_conflict INSTEAD OF INSERT ON review
    WITH non_conflict AS( -- this outputs a table of allowed assignments
    SELECT pr.id, pr.reviewerid, pr.proposalid, pr.deadline, pr.submitted, pr.coreviewerid
    FROM(
        SELECT r.id, r.reviewerid, r.proposalid, r.deadline, r.submitted, r.coreviewerid, p.pi
        FROM proposal p JOIN review r ON p.id = r.proposalid ) pr,
        conflict 
    WHERE NOT (((researcher1 = pi) AND (researcher2 = reviewerid))
            OR ((researcher2 = pi) AND (researcher1 = reviewerid)))
    )
    CASE  --  insert only if the row attempting to be inserted is in non_conflict
    	WHEN NEW IN non_conflict THEN INSERT INTO review VALUES
    	(NEW.id, NEW.reviewerid, NEW.proposalid, NEW.deadline, NEW.submitted, NEW.coreviewerid)
    END;



-- A2
-- Reviewers of a proposal must not be collaborators or principle investigators on a proposal submitted
-- for the same grant call.

CREATE ASSERTION invalid_reviewer
CHECK (
  SELECT *
  FROM review R 
  WHERE R.reviewerid = any(
    SELECT researcherid
    FROM proposal P
    JOIN collaborator C ON C.proposalid = P.id
    WHERE R.proposalid = P.id
  )
) <= 0;

-- A3
-- A reviewer cannot be assigned to attend more than one meeting in two consecutive days.

CREATE ASSERTION meeting_limit
CHECK(SELECT *
    FROM( SELECT reviewerid, date
      FROM meeting m JOIN participant p ON m.id = p.meetingid
      GROUP BY reviewerid, avg(date) AS date_distance
        ) 
    WHERE reviewerid > 1
        AND date_distance <= 2
    )


-- A4
-- Meeting attendees must have reviewed proposals for at least one competition (call) discussed on
-- that day.

CREATE ASSERTION invalid_attendee
CHECK (
  SELECT *
  FROM participant P
  JOIN meeting M ON P.meetingid = M.id
  JOIN discussion D ON D.meetingid = M.id
  WHERE P.reviewerid = any(
    SELECT reviewerid
    FROM proposal PO
    JOIN review R ON R.proposalid = PO.id
    JOIN call C ON PO.callid = C.id
    WHERE D.callid = C.id
  )
) > 0;

