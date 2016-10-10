# Perl Catalyst Shield UI Integration


## Introduction

The Catalyst MVC framework is a great tool to use for implementing small and big web projects using the Perl programming language. 
It provides a lot of useful functionality like session handling, authorization and request chaining, out of the box. 

This tutorial will show you how to create a Catalyst project for managing a list of books stored in a database. 
You will learn how to add a database to your application, create a RESTful controller that implements CRUD operations on the Book resource and
adding a template for rendering an index page containing a [Shield UI JavaScript Grid](https://www.shieldui.com/products/grid) component configured to work with your REST controller. 


## Prerequisites

It is required that you have experience writing web applications with Perl and understanding of the MVC architectural pattern. 

The first step is to install Perl and Catalyst on your PC. More information can be found on the [Catalyst wiki](http://wiki.catalystframework.org/wiki/installingcatalyst).


## Creating the Project

To create your Catalyst project, with the name ShieldUIApp, you should use the helper catalyst.pl script:

```bash
$ catalyst.pl ShieldUIApp
created "ShieldUIApp"
created "ShieldUIApp\script"
created "ShieldUIApp\lib"
...
created "ShieldUIApp\script\shielduiapp_create.pl"
Change to application directory and Run "perl Makefile.PL" to make sure your install is complete

$ cd ShieldUIApp
```


## Running the Project

At this point you should have a default project created, that you can run with the following command (assuming you run it from the ShieldUIApp directory):

```bash
$ perl script/shielduiapp_server.pl -r
```

Running the above command will start the Catalyst application server and show an output ending like this:

```bash
[info] ShieldUIApp powered by Catalyst 5.90105
HTTP::Server::PSGI: Accepting connections at http://0:3000/
```

Point your web browser to [http://localhost:3000/](http://localhost:3000/) (substituting the host and port parts if you used anything else) and you will see the Catalyst Welcome screen. 

**NOTE:** To stop the server at any time, you can press ```Ctrl-C``` on the same console. 


## Adding the Database

This sample application will make use of a database server for persisting data. We will use [SQLite](http://www.sqlite.org), a popular database that is lightweight and easy to use. Be sure to get at least version 3. 

Create a directory sql and a file ```sql/db.sql``` inside it, with the following contents, which will create the database schema and initialize it with some sample data: 

```sql
-- sqlite3 schema
CREATE TABLE book (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(256) NOT NULL,
    author VARCHAR(128) NOT NULL,
    rating INTEGER NOT NULL
);

-- load some sample data
INSERT INTO book (title, author, rating) VALUES ('Harry Potter and the Goblet of Fire', 'J.K. Rowling', 5);
INSERT INTO book (title, author, rating) VALUES ('The Hunger Games', 'Suzanne Collins', 3);
INSERT INTO book (title, author, rating) VALUES ('A Song of Ice and Fire', 'George R. R. Martin', 4);
```

Then use the following command to create the SQLite database:

```bash
$ sqlite3 app.db < sql/db.sql
```

At this point the ```app.db``` file should be created in your main application folder. If created elsewhere, delete it and re-run the above command from the ShieldUIApp directory. 

You can see what is in your database by executing:

```bash
$ sqlite3 app.db
sqlite> select * from book;
1|Harry Potter and the Goblet of Fire|J.K. Rowling|5
2|The Hunger Games|     Suzanne Collins|3
3|A Song of Ice and Fire|       George R. R. Martin|4
sqlite>
```

To exit the sqlite3 interactive mode, type ```.q``` and press ```Enter```, or just press ```Ctrl-C```.

Before you continue, make sure your ```app.db``` database file is in the application's topmost directory. 
Now use the model helper with the ```create=static``` option to read the database with [DBIx::Class::Schema::Loader](http://search.cpan.org/perldoc?DBIx%3A%3AClass%3A%3ASchema%3A%3ALoader) 
and automatically build the required files for us:

```bash
$ perl script/shielduiapp_create.pl model DB DBIC::Schema ShieldUIApp::Schema create=static dbi:SQLite:app.db
```

More information about the parameters for that helper script and the generated files, you can see 
[this tutorial](http://search.cpan.org/~ether/Catalyst-Manual-5.9009/lib/Catalyst/Manual/Tutorial/03_MoreCatalystBasics.pod#Create_Static_DBIx::Class_Schema_Files).


## Adding the Book REST Controller

Next we need to create a RESTful controller that will implement CRUD operations on the Book entity. 

We start with creating a simple controller with the following command:

```bash
$ perl script/shielduiapp_create.pl controller Book
```

This will generate the controller code in the ```lib/ShieldUIApp/Controller/Book.pm``` file. Open the file with a text editor and do the changes below, to implement all required actions. 

Make the controller inherit [Catalyst::Controller::REST](http://search.cpan.org/~jjnapiork/Catalyst-Action-REST-1.20/lib/Catalyst/Controller/REST.pm) by updating the BEGIN line at the top to:

```perl
BEGIN { extends 'Catalyst::Controller::REST'; }
```

The next steps are to define the ```/book``` resource and a ```GET``` action handler for it:

```perl
# the /book resource
sub book : Path('/book') : Args(0) : ActionClass('REST') {}

# GET /book
sub book_GET
{
	my ($self, $c) = @_;

	my @books = ();

	foreach my $book ($c->model('DB::Book')->all) {
		push(@books, {
			id => $book->id,
			title => $book->title,
			author => $book->author,
			rating => $book->rating
		});
	}

	return $self->status_ok($c, entity => \@books);
}
```

The rest of the file includes the code for the other resources and actions. 
Its complete version can be seen in the (lib/ShieldUIApp/Controller/Book.pm)[lib/ShieldUIApp/Controller/Book.pm] file. 


## Adding Views

A View in Catalyst is not the actual page or template used for rendering, but rather the module that determines the type of rendering - like HTML, PDF, XML, etc. 
For the thing that generates the content of that view (such as a Template Toolkit template file), the actual templates go under the ```root``` directory. 

To create a TT view, run the following command:

```bash
$ perl script/shielduiapp_create.pl view HTML TT
```

This creates a view called HTML (the first argument) in a file called HTML.pm that uses [Catalyst::View::TT](https://metacpan.org/pod/Catalyst::View::TT) (the second argument) as the "rendering engine".

It is now up to you to decide how you want to structure your view layout. For this tutorial, we will use one TT template, located in the root folder - 
```root/index.tt```, which should be used for rendering the contents of the root resource of your web application. 

To make the index template run, you should edit the root controller of the application to remove the welcome message output by default. 
Open the ```lib/ShieldUIApp/Controller/Root.pm``` file in your editor, find the ```index``` function and comment out the welcome message output as shown below:

```perl
sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    #$c->response->body( $c->welcome_message );
}
```

This should be enough for Catalyst to use the ```root/index.tt``` template when rendering the output for the action with the same name. 

The content of the ```root/index.tt``` template is straightforward - it initializes a [Shield UI Grid](http://www.shieldui.com/products/grid) widget and 
configures it to work with the remote endpoints we implemented in the Book REST controller. 

**NOTE:** The sample project uses the trial version of the [Shield UI JavaScript library](http://www.shieldui.com), accessible on their website. 
As an alternative, you can use the [Shield UI Lite](https://github.com/shieldui/shieldui-lite) open source package, which contains some of the Shield UI components, including the Grid. 


## Final Testing

To test the final version of the application, run it with:

```bash
$ perl script/shielduiapp_server.pl -r
```

Then point your web browser to the following URL: [http://localhost:3000/](http://localhost:3000/). 

This should show a Shield UI Grid component that contains the books currently stored in the database. 
Book management operations (creation, deletion, update) performed via the Grid should be reflected on the server-side and stored in the database. 


## Conclusion

This tutorial described how to create a Catalyst project from scratch, add a database to it and implement a CRUD RESTful controller for manipulating that database. 
It also included a powerful Grid component from the [Shield UI for JavaScript and HTML5](http://www.shieldui.com/products/javascript) library that was used for 
rendering the user interface that calls the server-side controller code. By ebmedding powerful user interface widgets like the ones included in the Shield UI suite, 
developers save time, cost and concerns about client-side peculiarities like responsiveness, cross-browser support and unified product vision.

All the components included in the Shield UI framework can be seen in action [here](http://demos.shieldui.com).


## License Information

The Shield UI Lite library is licensed under the MIT license, details of which can be found [here](https://github.com/shieldui/shieldui-lite/blob/master/LICENSE.txt).

For more details about Shield UI licensing, see the [Shield UI License Agreement](https://www.shieldui.com/eula) page at [www.shieldui.com](https://www.shieldui.com).
Shield UI Commercial support information can be found on [this page](https://www.shieldui.com/support.options)

