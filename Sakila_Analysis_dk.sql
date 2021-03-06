USE sakila;
-- 1a: Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b: Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name,' ', last_name) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
	WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN
SELECT last_name FROM actor
	WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor
	WHERE last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
	WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor.
-- You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT COUNT(last_name), last_name FROM actor
	GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT COUNT(last_name), last_name FROM actor
	GROUP BY last_name
	HAVING COUNT(last_name) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
	SET first_name = 'HARPO'
	WHERE first_name = 'GROUCHO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO.
-- It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET first_name = 'GROUCHO' WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
-- Running this returns a single row with the table properties. Right clicking and opening the value in a viewer provides the script below which is commented out.

--  CREATE TABLE `address` (
--  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
--  `address` varchar(50) NOT NULL,
--  `address2` varchar(50) DEFAULT NULL,
--  `district` varchar(20) NOT NULL,
--  `city_id` smallint(5) unsigned NOT NULL,
--  `postal_code` varchar(10) DEFAULT NULL,
--  `phone` varchar(20) NOT NULL,
--  `location` geometry NOT NULL,
--  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--  PRIMARY KEY (`address_id`),
--  KEY `idx_fk_city_id` (`city_id`),
--  SPATIAL KEY `idx_location` (`location`),
--  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
--  ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
	FROM staff
    INNER JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, SUM(payment.amount)
	FROM staff
    INNER JOIN payment ON staff.staff_id = payment.staff_id
    WHERE payment_date BETWEEN '2005-08-01' AND '2005-08-31'
    GROUP BY staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id)
	FROM film
    INNER JOIN film_actor ON film.film_id = film_actor.film_id
    GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id)
FROM inventory
WHERE film_id IN(
	SELECT film_id
    FROM film WHERE title = 'Hunchback Impossible');
    
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.last_name, SUM(payment.amount)
	FROM customer,
		payment
        WHERE customer.customer_id = payment.customer_id
			GROUP BY customer.last_name
			ORDER BY customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence,
-- films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT film.title
	FROM film
    -- LEFT JOIN language on film.language_id = language.language_id
    WHERE film.title IN ('K%', 'Q%') AND film.language_id = 1;

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
-- Film Actor -> Film ID -> Film Title
SELECT first_name, last_name
FROM actor
	WHERE actor_id IN(
		SELECT actor_id
        from film_actor
			WHERE film_id IN(
				SELECT film_id
				from film WHERE title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.
-- customer.email -> customer.address_id -> address.city_id -> city.country_id -> country.country
SELECT customer.first_name, customer.last_name, customer.email
	FROM customer,
		address,
        city,
        country
        WHERE customer.address_id = address.address_id
        AND address.city_id = city.city_id
        AND city.country_id = country.country_id
			AND country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.
-- film.title -> film.film_id -> film_category.id -> film_category.category_id -> category.category_id -> category.name
SELECT film.title, category.name
	FROM film,
		film_category,
        category
        WHERE film.film_id = film_category.film_id
        AND film_category.category_id = category.category_id
		AND category.name = 'Family';


-- 7e. Display the most frequently rented movies in descending order.
-- film.title -> (film.film_id -> inventory.film_id) -> (inventory.inventory_id -> rental.inventory_id) -> group by film.title -> desending order
Select film.title, COUNT(rental.inventory_id)
	FROM film,
		inventory,
        rental
        WHERE film.film_id = inventory.film_id
        AND inventory.inventory_id = rental.inventory_id
			GROUP BY film.title
				ORDER BY COUNT(rental.inventory_id) DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- staff.store_id -> payment.store_id - count and group by
SELECT staff.store_id, SUM(payment.amount)
	FROM staff,
		payment
		WHERE staff.staff_id = payment.staff_id
			Group By staff.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
-- store.store_id -> (store.address_id -> address.address_id) -> (address.city_id -> city.city_id) -> (city.country_id -> country.country_id) -> country.name


SELECT store.store_id, city.city, country.country
	FROM store,
		address, city,
        country
		Where store.address_id = address.address_id
		AND address.city_id = city.city_id
		AND city.country_id = country.country_id;
                


-- 7h. List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- SELECT( CATEGORY NAME, GROSS REVENUE)
-- (category.category_id -> film_category.category_id) -> (film_category.film_id ->  inventory.film_id) ->
-- 												(inventory.inventory_id -> rental-inventory_id) ->
-- 												(rental.rental_id -> payment.rental_id)
SELECT category.name, SUM(payment.amount)
	FROM category,
		film_category,
		inventory,
        rental,
        payment
		WHERE category.category_id = film_category.category_id
        AND film_category.film_id = inventory.film_id
        AND inventory.inventory_id = rental.inventory_id
        AND rental.rental_id = payment.rental_id
			GROUP BY category.name
				ORDER BY SUM(payment.amount) DESC;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

Create View top_five_genres as
SELECT category.name, SUM(payment.amount)
	FROM category,
		film_category,
		inventory,
        rental,
        payment
		WHERE category.category_id = film_category.category_id
        AND film_category.film_id = inventory.film_id
        AND inventory.inventory_id = rental.inventory_id
        AND rental.rental_id = payment.rental_id
			GROUP BY category.name
				ORDER BY SUM(payment.amount) DESC
				LIMIT 5;
-- 8b. How would you display the view that you created in 8a?

SELECT * FROM sakila.top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres;