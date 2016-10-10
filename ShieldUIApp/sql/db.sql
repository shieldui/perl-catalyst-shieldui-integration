-- sqlite3 schema
CREATE TABLE book (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(256) NOT NULL,
    author VARCHAR(128) NOT NULL,
    rating INTEGER NOT NULL
);

-- load some sample data
INSERT INTO book (title, author, rating) VALUES ('Harry Potter and the Goblet of Fire', 'J.K. Rowling', 5);
INSERT INTO book (title, author, rating) VALUES ('The Hunger Games', '    Suzanne Collins', 3);
INSERT INTO book (title, author, rating) VALUES ('A Song of Ice and Fire', '    George R. R. Martin', 4);
