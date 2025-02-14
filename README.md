# ttracker
keep track of the number of times you went to the bathroom, count sandwiches you eat, you name it.

This started as a simple list of things i wanted to keep track of over the year.
As things go, I'm too lazy to write when and where certain things happened, but i still want to know.
So, here is the tool for that.

Install the backend and database on your phone or on a webserver.

When you request ttracker.html, the backend generates and delivers an overview of the existing counters.
By submitting the form, counters can be incremented, added or removed.

```
+--------------------+
|   Frontend         |
|--------------------|
| - Display counters |
| - Submit forms     |
+--------------------+
          |
          | (HTTP Request/Response)
          v
+--------------------+
|   Backend          |
|--------------------|
| - Handles routes   |
| - Processes data   |
| - Updates database |
+--------------------+
          |
          | (SQL Queries)
          v
+--------------------+
|   Database         |
|--------------------|
| - stores counters  |
| - stores history   |
| - constraints      |
+--------------------+
```
