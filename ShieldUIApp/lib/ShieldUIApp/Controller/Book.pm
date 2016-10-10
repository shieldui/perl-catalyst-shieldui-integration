package ShieldUIApp::Controller::Book;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

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

# POST /book
sub book_POST
{
	my ($self, $c) = @_;

	my $data = $c->req->data;

	if (!$data) {
		return $self->status_bad_request($c, message => "No book data");
	}

	my $book = $c->model('DB::Book')->create({
		title => $data->{title},
		author => $data->{author},
		rating => $data->{rating}
	});

	if ($book) {
		return $self->status_created(
			$c,
			location => '/book/' . $book->id(),
			entity => {
				id => $book->id,
				title => $book->title,
				author => $book->author,
				rating => $book->rating
			}
		);
	}
	else {
		return $self->status_bad_request($c, message => "Cannot create book");
	}
}

# the book/{id} resource
sub single_book : Path('/book') : Args(1) : ActionClass('REST')
{
	my ($self, $c, $id) = @_;

	# load a book from the database, given its id
	$c->stash->{'book'} = $c->model('DB::Book')->find({id => $id});
}

# GET /book/{id}
sub single_book_GET
{
	my ($self, $c) = @_;

	my $book = $c->stash->{'book'};

	if ($book) {
		# return the currently loaded book
		return $self->status_ok(
			$c, 
			entity => {
				id => $book->id,
				title => $book->title,
				author => $book->author,
				rating => $book->rating
			}
		);
	}
	else {
		return $self->status_not_found($c, message => "Not Found");
	}
}

# PUT /book/{id}
sub single_book_PUT
{
	my ($self, $c) = @_;

	my $book = $c->stash->{'book'};

	if ($book) {
		# update the currently loaded book
		my $data = $c->req->data;

		if ($data) {
			$book->title($data->{title});
			$book->author($data->{author});
			$book->rating($data->{rating});
			$book->update();

			# returns the currently loaded book
			return $self->single_book_GET($c);
		}
		else {
			return $self->status_bad_request($c, message => "No action data");
		}
	}
	else {
		return $self->status_not_found($c, message => "Not Found");
	}
}

# DELETE /book/{id}
sub single_book_DELETE
{
	my ($self, $c) = @_;

	my $book = $c->stash->{'book'};

	if ($book) {
		# delete the currently loaded book
		$book->delete();
	}

	return $self->status_no_content($c);
}


__PACKAGE__->meta->make_immutable;

1;
