---
tags: []
title: Thoughts on creating a "contacts" SQL relationship
description: Look back over the past, with its changing empires that rose and fell,
  and you can foresee the future too
date: 2022-01-20T23:00:00Z
draft: false

---
Recently been experimenting with \[Supabase\](https://supabase.com) and it's been a great experience so far. Supabase is a firebase alternative, like AppWrite but it actually uses Postgres under the hood. I've been working on an experimental chat app just to try out some ideas and concepts. The app is written in React not my usual Vue and Supabase. The chat app has a requirement before, two people can communicate at least one of the users in the conversation must have accepted a "contact" request. So basically given two users Rashord and Lingard. If Rashford sends a contact request to Lingard and Lingard accepts it that connection has to be stored in a database table. For this i created a table, `contact` with the following schema:
**NOTE: For brevity i don't include the creation of a user table**

```sql
CREATE TABLE contact (
	id SERIAL PRIMARY KEY,
    user1 INTEGER references "user"(id),
    user2 INTEGER references "user"(id)
)
```

A single table as far as i know is great for this because if Lingard accepts Rashfords request they both become friends and this relationship would display on both accounts friends list and one table row in the `contact` table is enough to establish this relationship.
Something to note though is that this is obviously different from the approach I would probably take if I was trying to create a table to represent a users phone contacts since in that scenario Rashford can save Lingards number but Lingard my not have Rashford's.
Now the next step would be getting the friends for each user, Rashford and Lingard. SQL's `CASE` statement really shines here as we would need to check the id against each column, `user1` and `user2` returning the other if equality is established. So here's the query for that:

```sql
SELECT "user".*
FROM contact
LEFT JOIN "user" ON
	CASE
		WHEN contact.user1 = userId THEN contact.user2 = "user".id
		WHEN contact.user2 = userId THEN contact.user1 = "user".id
	END;
```

The query above has `JOIN`between the `contact` table and the `user` table. The `CASE` statement will return the alternative `user*` column in the `contact` table when matched and will then join that with the `user` table returning the entire `user` row.

This alone is good if i was using a server side language but i'm using Supabase for this so this would have to be a function:

```sql
CREATE OR REPLACE FUNCTION get_friends(userId integer) RETURNS record AS $$
DECLARE
user_contacts "user";
BEGIN
    SELECT "user".*
    FROM contact
    LEFT JOIN "user" ON
        CASE
            WHEN contact.user1 = userId THEN contact.user2 = "user".id
            WHEN contact.user2 = userId THEN contact.user1 = "user".id
        END;
    RETURN user_contacts;
END;
$$ language plpgsql;
```