CREATE TABLE researcher(
  id SERIAL PRIMARY KEY,
  firstname VARCHAR(30) NOT NULL,
  lastname VARCHAR(30) NOT NULL,
  email VARCHAR(50) UNIQUE NOT NULL,
  organization VARCHAR(10)
);

CREATE TYPE callstatus AS ENUM('open','closed','paused','cancelled'); 

CREATE TABLE call(
  id SERIAL PRIMARY KEY,
  title VARCHAR(50) NOT NULL,
  call_date DATE NOT NULL,
  deadline DATE NOT NULL,
  description VARCHAR(250),
  area VARCHAR(30) NOT NULL,
  status callstatus DEFAULT 'open'
);

CREATE TYPE appstatus AS ENUM('submitted','awarded','denied');

CREATE TABLE proposal(
  id SERIAL PRIMARY KEY,
  callid INT REFERENCES call(id) NOT NULL,
  pi INT REFERENCES researcher(id) NOT NULL,
  status appstatus DEFAULT 'submitted' NOT NULL,
  amount_awarded NUMERIC(14,2),
  amount_requested NUMERIC(14,2),
  proposal_date DATE
); 

CREATE TABLE collaborator(
  id SERIAL PRIMARY KEY,
  proposalid INT REFERENCES proposal(id) NOT NULL,
  researcherid INT REFERENCES researcher(id) NOT NULL,
  ispi BOOLEAN DEFAULT 'false' NOT NULL
);

CREATE TABLE conflict(
  id SERIAL PRIMARY KEY,
  researcher1 INT REFERENCES researcher(id) NOT NULL,
  researcher2 INT REFERENCES researcher(id) NOT NULL,
  reason VARCHAR(50),
  expiry DATE
);

CREATE TABLE review(
  id SERIAL PRIMARY KEY,
  reviewerid INT REFERENCES researcher(id) NOT NULL,
  proposalid INT REFERENCES proposal(id) NOT NULL,
  deadline DATE NOT NULL,
  submitted BOOLEAN DEFAULT 'false' NOT NULL,
  coreviewerid INT REFERENCES researcher(id)
);

CREATE TABLE meeting(
  id SERIAL PRIMARY KEY,
  date DATE NOT NULL
);

CREATE TYPE parttype AS ENUM('guest','speaker');

CREATE TABLE participant(
  id SERIAL PRIMARY KEY,
  reviewerid INT REFERENCES researcher(id) NOT NULL,
  meetingid INT REFERENCES meeting(id) NOT NULL,
  type parttype DEFAULT 'guest' NOT NULL
);

CREATE TABLE discussion(
  id SERIAL PRIMARY KEY,
  callid INT REFERENCES call(id) NOT NULL,
  meetingid INT REFERENCES meeting(id) NOT NULL
);


