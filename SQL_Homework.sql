use sakila;

-- * 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name from actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name, " ", last_name) as "Actor Name" from actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id, first_name, last_name from actor where first_name = "Joe";

-- * 2b. Find all actors whose last name contain the letters `GEN`:

select * from actor where last_name like "%GEN%";

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

select first_name, last_name from actor where last_name like "%LI%" order by 2, 1;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

select * from country where country.country in ('Afghanistan', 'Bangladesh', 'China');

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

alter table actor
add column description blob AFTER last_name;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

alter table actor
drop column description;

-- * 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, count(last_name) 'last name count' from actor
group by 1
having `last name count` >= 1;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.

select last_name, count(last_name) 'last name count' from actor
group by 1
having `last name count` >= 2; 

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

SET SQL_SAFE_UPDATES = 0;

update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO'
and last_name = 'WILLIAMS';

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO';

select * from actor
where first_name = 'GROUCHO';

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

show create table address;

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

select s.first_name, s.last_name, a.address
from staff s inner join address a
on s.address_id = a.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

select s.first_name, s.last_name, sum(p.amount)
from staff s inner join
payment p
on s.staff_id = p.staff_id
where month(p.payment_date) = 08 and year(p.payment_date) = 2005
group by s.staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

select f.title, count(fa.actor_id) actors
from film_actor fa
inner join film f
on f.film_id = fa.film_id
group by 1
order by 2 desc;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select f.title, count(i.inventory_id) "# of copies"
from film f
inner join inventory i
on f.film_id = i.film_id
where title = 'Hunchback Impossible'
group by 1;

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

select c.first_name, c.last_name, sum(p.amount) 'Total Amount Paid'
from customer c
inner join payment p
on p.customer_id = c.customer_id
group by p.customer_id
order by 2;

--   ![Total amount paid](Images/total_payment.png)

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

select title
from film
where title like 'K%'
or title like 'Q%'

and language_id in
  (
   select language_id
   from language
   where name = 'English');

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

select first_name, last_name
from actor
where actor_id in
  (
    select actor_id
    from film_actor
    where film_id =
    (
       select film_id
       from film
       where title = 'Alone Trip'
      )
   );

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select first_name, last_name, email, country
from customer cus
inner join address a
on (cus.address_id = a.address_id)
inner join city cit
on (a.city_id = cit.city_id)
inner join country ctr
on (cit.country_id = ctr.country_id)
where ctr.country = 'canada';

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

select title, c.name
from film f
inner join film_category fc
on (f.film_id = fc.film_id)
inner join category c
on (c.category_id = fc.category_id)
where name = 'family';

-- * 7e. Display the most frequently rented movies in descending order.

select title, count(title) 'Rentals'
from film
inner join inventory
on (film.film_id = inventory.film_id)
inner join rental
on (inventory.inventory_id = rental.inventory_id)
group by title
order by 2 desc;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.

select s.store_id, sum(amount) Gross
from payment p
inner join rental r
on (p.rental_id = r.rental_id)
inner join inventory i
on (i.inventory_id = r.inventory_id)
inner join store s
on(s.store_id = i.store_id)
group by 1;

-- * 7g. Write a query to display for each store its store ID, city, and country.

select store_id, city, country
from store s
inner join address a
on (s.address_id = a.address_id)
inner join city cit
on (cit.city_id = a.city_id)
inner join country ctr
on (cit.country_id = ctr.country_id);

-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select sum(amount) 'Total Sales', c.name 'Genre'
from payment p
inner join rental r
on (p.rental_id = r.rental_id)
inner join inventory i
on (r.inventory_id = i.inventory_id)
inner join film_category fc
on (i.film_id = fc.film_id)
inner join category c
on (fc.category_id = c.category_id)
group by 2
order by 1 DESC;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_five as
select sum(amount) 'Total Sales', c.name 'Genre'
from payment p
inner join rental r
on (p.rental_id = r.rental_id)
inner join inventory i
on (r.inventory_id = i.inventory_id)
inner join film_category fc
on(i.film_id = fc.film_id)
inner join category c
on (fc.category_id = c.category_id)
group by 2
order by 1 desc
limit 5;

-- * 8b. How would you display the view that you created in 8a?

select *
from top_five;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

drop view top_five;