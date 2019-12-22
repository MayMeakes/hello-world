with user_obj as
(
	select owner,count(*) cnt 
	from t_objects
	group by owner
)
select u.user_id,u.user_name,o.cnt
from t_users u,user_obj o
where u.user_name=o.owner;

