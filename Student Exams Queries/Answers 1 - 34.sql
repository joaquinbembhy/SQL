-- 1. Id of the students who got at least one 30

select distinct sid from student
natural join exam
where grade = 30;

-- 2. Id, Name and City of origin of the students who got at least one 30

select distinct sid, name, city from student
natural join exam
where grade = 30;

-- 3. The birthdate of the youngest student

select  max(birthdate) from student;

-- 4. The GPA of the student with ID = 107

select sid, avg(grade) GPA from student
natural join exam join course on cid=courseid
-- where sid = 107 (its the same, one or another)
group by sid
having sid = 107;

-- 5. The GPA of each course

select courseid, avg(grade) GPA 
from course join exam on cid=courseid
group by cid
order by cid;

-- 6. The number of Credits acquired by each student   

select sid, sum(credits) from student
natural join exam join course on cid=courseid
group by sid;

-- 6bis.  Also including students with ZERO credits…

-- With outer join
select S.sid, sum(credits), name from course C 
join exam E on courseid=cid
right join student S on  S.sid=E.sid
group by S.sid;

-- With coalesce()
select S.sid, coalesce(sum(credits),0) TotCredits, name from course C 
join exam E on courseid=cid
right join student S on  S.sid=E.sid
group by S.sid;

-- 7. The (weighted) GPA of each student

select sid, name, sum(grade*credits)/sum(credits) WGPA, avg(grade) GPA
from student natural join exam join course on cid=courseid
group by sid;

-- 8. Students who passed at least 2 exams [a. just the Id] 

select sid, count(*) PassedExams from student
natural join exam
group by sid
having PassedExams >= 2
order by PassedExams;

-- b. [also the Name]
select sid, name, count(*) PassedExams from student
natural join exam
group by sid
having PassedExams >= 2
order by PassedExams;

-- 9 Students who passed less than 5 exams [a. just the Id]  

select sid, count(*) PassedExams from student
natural join exam
group by sid
having passedexams < 5;

-- [b. also the Name]
select sid, name, count(cid) PassedExams from student
natural left join exam
group by sid
having passedexams < 5;

-- 10 Students who passed exactly 4 exams [a. just the id]
select sid, count(*) PassedExams from student
natural join exam
group by sid
having PassedExams = 4;

-- [b. also the name]
select sid, name, count(*) PassedExams from student
natural join exam
group by sid
having PassedExams = 4;

-- 11. For each student, the number of passed exams (including those with 0 exams!)
select S.sid, name, count(e.sid) PassedExams
from exam E right join student S on S.sid=E.sid
group by S.sid;

-- 12. Students with a (weighted) GPA that is above 24.5
select sid, name, sum(grade*credits)/sum(credits) WGPA
from student natural join exam join course on cid=courseid
group by sid
having WGPA > 24.5;

-- 13. The “regular” students, i.e., those with a delta of maximum 3 
-- points between their worst and best grade 
select sid, name, max(grade), min(grade), max(grade)-min(grade) DELTA
from student natural join exam
group by sid
having DELTA <= 3;

-- 14. The (weighted) GPA of each student who passed at least 5 exams (statistically meaningful)
select E.sid, name, sum(grade*credits)/sum(credits) WGPA, count(E.sid) PassedE
from student S left join exam E on S.sid=E.sid
join course C on cid=courseid
group by sid
having PassedE > 4;

-- 15. The (weighted) GPA for each year of each student who passed at least 5 
--     exams overall (not 5 exams per year)
select sid, year, sum(grade*credits)/sum(credits), count(cid) WGPA 
from student natural join exam join course on cid=courseid
group by sid, year
having (sid, year) in ( select sid, year from exam
						where count(*) > 4);
                
-- 16 Student who never got more than 21
select sid, name, max(grade)
from student natural join exam
group by sid 
having max(grade) < 22;

-- 17. Id and name of the students who passed exams for a total amount 
--     of at least 20 credits and never got a grade below 28
select sid, name, sum(credits) TotCredits
from student natural join exam join course on cid=courseid
group by sid
having TotCredits > 19
	and sid not in (select sid
					from student natural join exam
                    where grade < 28)
;

-- 18. Students who got the same grade in two or more exams
select sid, name, grade, count(*)
from student S natural join exam E join course C on cid=courseid
group by sid, grade
having count(*) > 1;

-- 19. Students who never got the same grade twice
select sid, name
from student
group by sid
having sid not in (select sid
					from student natural join exam
                    group by sid
                    having count(distinct grade) < count(*));				
;

-- 20. Students who always got the very same grade in all their exams

-- this one doesn't count the one with 0 exams
select sid, name
from student natural join exam
group by sid
having count(distinct grade) = 1;

-- or | this one counts the student with no exams
select sid, name
from student
group by sid
having sid not in ( select sid
					from student natural join exam
                    group by sid
                    having count(distinct grade) <> 1);
                    
-- 21. The name of the youngest student
select sid, name, birthdate
from student
where birthdate in (select max(birthdate)
					from student);
                
-- 22.  Students who got all possible distinct grades
-- How much distinct grades are there?
select count(distinct grade) from exam;

-- 13 ==> therefore we structure the query
select sid, name, count(distinct grade)
from student natural join exam
group by sid
having count(distinct grade) = 13;

-- 23. Students who never passed any exam
select sid, name, count(grade)
from student natural left join exam
group by sid
having count(grade)=0;

-- or (better)
select sid, name
from student
where sid not in (select sid from exam);

-- 24.  Students who never got an 18
select sid, name
from student
group by sid
having sid not in (select sid
					from exam
                    where grade=18);
                    
-- 25. Code and Title of the courses with the minimum number of credits
select courseid, title, credits
from course 
where credits in (select min(credits)
					from course);
                    
-- 26. Code and Title of the courses of the first year with the minimum number of credits
select courseid, title, credits, year
from course
where year = 1
	and 
	credits = (select min(credits)
				from course
                where year=1)
;

-- 27. Code and Title of the courses with the minimum number of credits of each year
select courseid, year, title, credits
from course
where (year,credits) in (select year, min(credits)
						   from course
                           group by year)
order by year
;

-- 28. Id and Name of the students who passed more exams from the second year than exams from the first year
-- Year 1 exams
create view ExamsYear1(sid, Name, ExYear1) as
	select sid, Name, count(grade)
    from student natural join exam join course on cid=courseid
    group by sid, year
    having year = 1;

	select * from ExamsYear1;

-- Year 2 exams
create view ExamsYear2(sid, Name, ExYear2) as
	select sid, Name, count(grade)
    from student natural join exam join course on cid=courseid
    group by sid, year
    having year = 2;
    
    select * from ExamsYear2;
    
-- Compare both
select sid, name, ExYear1, ExYear2
from ExamsYear1 e1 natural join ExamsYear2
where ExYear1<ExYear2;

-- 29. The student(s) with best weighted GPA
create view WGPAs(sid, name, WGPA) as
	select sid, name, sum(grade*credits)/sum(credits) as WGPA
	from student natural join exam join course on cid=courseid
	group by sid
;

select * from WGPAs;

select sid, name, WGPA 
from WGPAs
where WGPA in (select max(wgpa)
			  from WGPAs);

-- 30. The course with the worst GPA
drop view GPAs;
create view GPAs(courseid, title, GPA) as
	select courseid, title, avg(grade)
	from course join exam on cid=courseid
	group by cid;
    
select courseid, title, GPA
from GPAs
where GPA in (select min(gpa)
			  from GPAs); 

-- 31. Students with a GPA that is at least 2 points above the overall college GPA 
-- (I actually did it with WGPA)
select * from WGPAs
where WGPA+2 > (select avg(WGPA)
			    from WGPA);

-- 32. For each student, their best year in terms of GPA
create view GPAs_per_year(sid, name, year, GPA) as   
   select sid, name, year, avg(grade) GPA
	from student natural join exam join course on cid=courseid
	group by sid, year
	order by sid;

select * from GPAs_per_year;

select * from StudentGPAs;

create view MaxGPAs(sid, year, MaxGPAs) as
	select sid, year, max(gpa)
	from GPAs_per_year
	group by sid, year;


select sid, year, MaxGPAs
from MaxGPAs
where (sid, MaxGPAs) in (select sid, max(GPA)
						 from GPAs_per_year
                         group by sid)
	;


-- 33. The most “regular” students, i.e., those with the minimum delta between their worst and best grade
drop view MinMax;
create view MinMax(sid, name, MinGrade, MaxGrade, Delta) as
	select sid, name, min(grade) MinGrade, max(grade) MaxGrade, max(grade)-min(grade) Delta
	from student natural join exam
	group by sid;
    
    select * from minmax;

select sid, name, delta
from MinMax
where delta = (select min(maxgrade-mingrade) 
				from minmax)
group by sid;


-- 34. Students with a weighted GPA that is above the “average weighted GPA” of all the students
select sid, name, WGPA
from WGPAs
where WGPA > (select avg(WGPA)
			  from WGPAs)
              ;

select * from WGPAs;
select avg(WGPA) from WGPAs;
