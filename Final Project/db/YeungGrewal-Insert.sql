INSERT INTO researcher VALUES
(DEFAULT,'Name1','Lastname1','email@sfu.ca','SFU'),
(DEFAULT,'Name2','Lastname2','email@uvic.ca','UVIC'),
(DEFAULT,'Name3','Lastname3','email2@sfu.ca','SFU'),
(DEFAULT,'Name4','Lastname4','email@ubc.ca','UBC'),
(DEFAULT,'Name5','Lastname5','email@utaustin.com','UT');

INSERT INTO call VALUES
(DEFAULT,'Canadian Inovation', now(), now() + interval '2 month',NULL,'Computer Science',DEFAULT),
(DEFAULT,'Some Title', now() - interval '1 month', now() + interval '3 week',NULL,'Biology',DEFAULT),
(DEFAULT,'Reduce Carbon Footprint', now() - interval '2 month', now() + interval '1 month',NULL,'Engineering','closed'),
(DEFAULT,'The Mechatronics of Life', now(), now() + interval '5 month',NULL,'Mechatronics', DEFAULT);

INSERT INTO proposal VALUES 
(DEFAULT,2,3,'submitted',NULL,25000.00, '2020-01-02'),
(DEFAULT,3,4,'denied',NULL,21500.00, '2020-01-01'),
(DEFAULT,1,1,'awarded',5000.00,6000.00, '2020-02-03'),
(DEFAULT,2,2,'submitted',NULL,10000.00, '2020-03-03'),
(DEFAULT,4,5,'submitted',NULL,43500.00, '2019-03-03');

INSERT INTO collaborator VALUES
(DEFAULT,1,3,'t'),
(DEFAULT,1,2,'f'),
(DEFAULT,2,4,'t'),
(DEFAULT,3,1,'t'),
(DEFAULT,4,2,'t'),
(DEFAULT,5,5, 't');

INSERT INTO conflict VALUES
(DEFAULT,1,2,'co-authered paper',now() + interval '2 year'),
(DEFAULT,4,3,'related',NULL),
(DEFAULT,3,1,'Same Department',NULL);

INSERT INTO review VALUES
(DEFAULT,1,1,now(),'t', 4),
(DEFAULT,2,3,now() + interval '2 week','f', NULL),
(DEFAULT,3,2,now() + interval '2 week','t', NULL),
(DEFAULT,3,5,now() + interval '2 week','f', NULL);

INSERT INTO meeting VALUES
(DEFAULT, '2020-08-11'),
(DEFAULT, '2020-02-04');

INSERT INTO participant VALUES
(DEFAULT, 1, 1, 'guest'),
(DEFAULT, 2, 1, 'speaker'),
(DEFAULT, 3, 2, 'guest'),
(DEFAULT, 4, 2, 'speaker');

INSERT INTO discussion VALUES
(DEFAULT, 1, 1),
(DEFAULT, 2, 2),
(DEFAULT, 3, 2);