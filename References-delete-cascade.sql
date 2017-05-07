/*
ALTER TABLE [dbo].[bm_BookmarkLabels]  WITH CHECK 
	ADD CONSTRAINT [FK_BookmarkLabels_Bookmarks] FOREIGN KEY([BookmarkId])
	REFERENCES [dbo].[bm_Bookmarks] ([BookmarkId])
	ON DELETE CASCADE
*/


drop table table1
drop table table2

create table table1 (	T1id int not null ,	T1val char(5) )
create table table2 (	T2id int not null ,	T2T1id int,	T2val char(5) )

alter table table1 with check add constraint pk_t1 primary key (T1id)
alter table table2 with check add constraint pk_t2 primary key (T2id)

alter table table2 with check add constraint fk_t2 foreign key (T2T1id)
	references table1(T1id)
	on delete cascade


select * from table1
select * from table2

insert into table1 values (1, 'a')
insert into table1 values (2, 'b')
insert into table1 values (3, 'c')

insert into table2 values (1, 1, 'a')
insert into table2 values (2, 1, 'b')
insert into table2 values (3, 5, 'c') -- nao deixa incluir pois nao tem 5 na tabela 1


delete from table2 where t2id = 2

delete from table1 where t1id = 1

-- se deletar em 1, remove tambem em 2!!!